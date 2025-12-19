defmodule LokiLogger.Exporter do
  use GenServer

  defmodule State do
    @type t :: %__MODULE__{
            tesla_client: any(),
            loki_url: bitstring(),
            loki_labels: any(),
            buffers: list(any()),
            task_ref: any()
          }

    defstruct tesla_client: nil,
              loki_url: nil,
              loki_labels: nil,
              buffers: [],
              task_ref: nil
  end

  def submit(data) do
    GenServer.call(__MODULE__, {:submit, data})
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(config) do
    tesla_client = config |> Keyword.get(:tesla_client)
    loki_url = config |> Keyword.get(:loki_url)
    loki_labels = config |> Keyword.get(:loki_labels)
    state = %State{tesla_client: tesla_client, loki_url: loki_url, loki_labels: loki_labels}

    {:ok, state}
  end

  @impl true
  def handle_call(
        {:submit, data},
        _from,
        state = %State{}
      ) do
    state.task_ref
    |> case do
      nil ->
        state
        |> push(data)

      _ ->
        buffers = [data | state.buffers] |> Enum.reverse()
        %{state | buffers: buffers}
    end
    |> then(fn state ->
      {:reply, :ok, state}
    end)
  end

  @impl true
  def handle_info({ref, _}, state = %State{task_ref: ref}) do
    # We don't care about the DOWN message now, so let's demonitor and flush it
    Process.demonitor(ref, [:flush])

    state
    |> next_task()
    |> then(fn state ->
      {:noreply, state}
    end)
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, %{task_ref: ref} = state) do
    state
    |> next_task()
    |> then(fn state ->
      {:noreply, state}
    end)
  end

  @impl true
  def handle_info(_, state) do
    {:noreply, state}
  end

  defp generate_bin_push_request(loki_labels, output) do
    labels =
      Enum.map(loki_labels, fn {k, v} -> "#{k}=\"#{v}\"" end)
      |> Enum.join(",")

    labels = "{" <> labels <> "}"

    # sort entries on epoch seconds as first element of tuple, to prevent out-of-order entries
    sorted_entries =
      output
      |> List.keysort(0)
      |> Enum.map(fn {ts, line} ->
        seconds = Kernel.trunc(ts / 1_000_000_000)
        nanos = ts - seconds * 1_000_000_000

        %Logproto.EntryAdapter{
          timestamp: %Google.Protobuf.Timestamp{seconds: seconds, nanos: nanos},
          line: line
        }
      end)

    request =
      %Logproto.PushRequest{
        streams: [
          %Logproto.StreamAdapter{
            labels: labels,
            entries: sorted_entries
          }
        ]
      }

    {:ok, bin_push_request} =
      Logproto.PushRequest.encode(request)
      |> :snappyer.compress()

    bin_push_request
  end

  defp next_task(state = %State{}) do
    state.buffers
    |> case do
      [] ->
        %{state | task_ref: nil}

      [data | buffers] ->
        %{state | buffers: buffers}
        |> push(data)
    end
  end

  defp push(
         state = %State{tesla_client: tesla_client, loki_url: loki_url, loki_labels: loki_labels},
         data
       ) do
    task =
      Task.Supervisor.async_nolink(LokiLogger.TaskSupervisor, fn ->
        tesla_client
        |> Tesla.post(loki_url, generate_bin_push_request(loki_labels, data))
        |> case do
          {:ok, %Tesla.Env{status: 204}} ->
            :noop

          {:ok, %Tesla.Env{status: status, body: body}} ->
            "Unexpected status code from loki backend #{status}" |> IO.puts()
            body |> inspect() |> IO.puts()

          v ->
            "Unable to connect to Loki service #{inspect(v)}" |> IO.puts()
        end
      end)

    %{state | task_ref: task.ref}
  end
end
