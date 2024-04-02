import Config

config :logger,
  backends: [LokiLogger]

config :logger, :loki_logger,
  level: :debug,
  format: "$time $metadata[$level] $message\n",
  metadata: :all,
  max_buffer: 300,
  loki_labels: %{application: "loki_logger_library", elixir_node: node()},
  loki_host: "http://localhost:3100",
  loki_scope_org_id: "fake"

import_config "#{config_env()}.exs"
