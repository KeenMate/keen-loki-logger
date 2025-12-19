defmodule LokiLogger do
  @behaviour :gen_event
  @moduledoc false

  @default_loki_host "http://localhost:3100"

  defstruct buffer: [],
            buffer_size: 0,
            format: nil,
            level: nil,
            max_buffer: nil,
            metadata: nil,
            supervisor: nil

  def init(LokiLogger) do
    config = Application.get_env(:logger, :keen_loki_logger) || [level: :info]
    {:ok, init(config, %__MODULE__{})}
  end

  def init({__MODULE__, opts}) when is_list(opts) do
    config = configure_merge(Application.get_env(:logger, :keen_loki_logger), opts)
    {:ok, init(config, %__MODULE__{})}
  end

  def handle_call({:configure, options}, state) do
    {:ok, :ok, configure(options, state)}
  end

  def handle_event({level, _gl, {Logger, msg, ts, md}}, state) do
    %{level: log_level, buffer_size: buffer_size, max_buffer: max_buffer} = state

    cond do
      not meet_level?(level, log_level) ->
        {:ok, state}

      buffer_size < max_buffer ->
        {:ok, buffer_event(level, msg, ts, md, state)}

      buffer_size === max_buffer ->
        state = buffer_event(level, msg, ts, md, state)
        {:ok, flush(state)}
    end
  end

  def handle_event(:flush, state) do
    {:ok, flush(state)}
  end

  def handle_event(_, state) do
    {:ok, state}
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  def code_change(_old_vsn, state, _extra) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  ## Helpers

  defp meet_level?(_lvl, nil), do: true

  defp meet_level?(lvl, min) do
    Logger.compare_levels(lvl, min) != :lt
  end

  defp configure(options, state) do
    config = configure_merge(Application.get_env(:logger, :keen_loki_logger), options)
    Application.put_env(:logger, :keen_loki_logger, config)

    init(config, state)
  end

  defp init(config, state) do
    level = Keyword.get(config, :level, :info)

    format =
      Logger.Formatter.compile(Keyword.get(config, :format, "$time $metadata[$level] $message\n"))

    loki_url =
      Keyword.get(config, :loki_host, "http://localhost:3100") <>
        Keyword.get(config, :loki_path, "/loki/api/v1/push")

    finch_protocols = Keyword.get(config, :finch_protocols, [:http1])
    finch_pool_size = Keyword.get(config, :finch_pool_size, 16)
    finch_pool_count = Keyword.get(config, :finch_pool_count, 4)
    finch_pool_max_idle_time = Keyword.get(config, :finch_pool_max_idle_time, 10_000)
    mint_conn_opts = Keyword.get(config, :mint_conn_opts, [])

    loki_labels = Keyword.get(config, :loki_labels, %{application: "loki_logger_library"})

    {:ok, supervisor_pid} =
      Supervisor.start_link(
        [
          {
            Finch,
            # :public_key.cacerts_get()
            name: LokiLogger.Finch,
            pools: %{
              "#{loki_url}" => [
                protocols: finch_protocols,
                size: finch_pool_size,
                count: finch_pool_count,
                pool_max_idle_time: finch_pool_max_idle_time,
                conn_opts: mint_conn_opts
              ]
            }
          },
          {Task.Supervisor, name: LokiLogger.TaskSupervisor},
          {LokiLogger.Exporter,
           loki_labels: loki_labels, loki_url: loki_url, tesla_client: config |> tesla_client()}
        ],
        strategy: :one_for_one
      )

    %{
      state
      | format: format,
        metadata:
          Keyword.get(config, :metadata, :all)
          |> configure_metadata(),
        level: level,
        max_buffer: Keyword.get(config, :max_buffer, 32),
        supervisor: supervisor_pid
    }
  end

  defp get_loki_host_config({_, _, _}), do: @default_loki_host
  defp get_loki_host_config(loki_host), do: loki_host

  defp configure_metadata(:all), do: :all
  defp configure_metadata(metadata), do: Enum.reverse(metadata)

  defp configure_merge(env, options) do
    Keyword.merge(
      env,
      options,
      fn
        _, _v1, v2 -> v2
      end
    )
  end

  defp buffer_event(level, msg, ts = {date, {hour, minute, second, milli}}, md, state) do
    %{buffer: buffer, buffer_size: buffer_size} = state

    epoch_nano =
      :calendar.local_time_to_universal_time_dst({date, {hour, minute, second}})
      |> case do
        [] -> {date, {hour, minute, second}}
        [dt_utc] -> dt_utc
        [_, dt_utc] -> dt_utc
      end
      |> NaiveDateTime.from_erl!({round(milli * 1000), 6})
      |> NaiveDateTime.diff(~N[1970-01-01 00:00:00], :nanosecond)

    buffer = buffer ++ [{epoch_nano, format_event(level, msg, ts, md, state)}]
    %{state | buffer: buffer, buffer_size: buffer_size + 1}
  end

  defp async_io(output) do
    output
    |> LokiLogger.Exporter.submit()
  end

  defp format_event(level, msg, ts, md, %{format: format, metadata: keys} = _state) do
    List.to_string(Logger.Formatter.format(format, level, msg, ts, take_metadata(md, keys)))
  end

  defp take_metadata(metadata, :all) do
    Keyword.drop(metadata, [:crash_reason, :ancestors, :callers])
  end

  defp take_metadata(metadata, keys) do
    Enum.reduce(
      keys,
      [],
      fn key, acc ->
        case Keyword.fetch(metadata, key) do
          {:ok, val} -> [{key, val} | acc]
          :error -> acc
        end
      end
    )
  end

  defp log_buffer(%{buffer_size: 0, buffer: []} = state), do: state

  defp log_buffer(state) do
    state.buffer |> async_io()

    %{state | buffer: [], buffer_size: 0}
  end

  defp flush(state) do
    log_buffer(state)
  end

  defp tesla_client(config) do
    req_opts = Keyword.get(config, :req_opts, [])

    http_headers = [
      {"Content-Type", "application/x-protobuf"},
      {"X-Scope-OrgID", Keyword.get(config, :loki_scope_org_id, "fake")}
    ]

    basic_auth_user = Keyword.get(config, :basic_auth_user)
    basic_auth_password = Keyword.get(config, :basic_auth_password)

    case not is_nil(basic_auth_user) and not is_nil(basic_auth_password) do
      true ->
        [
          {Tesla.Middleware.Headers, http_headers},
          {Tesla.Middleware.BasicAuth,
           %{username: basic_auth_user, password: basic_auth_password}}
        ]

      false ->
        [
          {Tesla.Middleware.Headers, http_headers}
        ]
    end
    |> Tesla.client({Tesla.Adapter.Finch, name: LokiLogger.Finch, opts: req_opts})
  end
end
