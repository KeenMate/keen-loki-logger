# keen_loki_logger - Elixir Logger backend for Loki service

keen_loki_logger is an Elixir logger backend, based on original [LokiLogger](https://github.com/wardbekker/LokiLogger), which development is dead from 2019, providing support for Logging to [Grafana Loki](https://github.com/grafana/loki)

[![Hex.pm Version](http://img.shields.io/hexpm/v/keen_loki_logger.svg?style=flat)](https://hex.pm/packages/keen_loki_logger)

## Known issues

* "works-on-my-machine" level of quality, but we use it in a big enterprise company. Post a feedback in the repo's Github issues.

## Features (and TODO)

Some of the features were reworked, some implemented and some are still missing. The main part is there though.

* [x] Elixir Logger formatting
* [x] Elixir Logger metadata
* [x] Loki Scope-Org-Id header for multi-tenancy
* [x] Timezone aware
* [X] Snappy compressed proto format in the HTTP Body  
* [X] Async http call to backend. _This needs to be properly tested and reviewed, though._
* [ ] Proper unit tests.
* [ ] HTTP post retry strategy on temporary loki backend failure or network hiccups.
* [X] Authentication with basic auth.
* [ ] Authentication with Oauth2 reverse proxy


## Installation

The package can be installed by adding `keen_loki_logger` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:keen_loki_logger, "~> 0.5.1"}
  ]
end
```

### STRUGGLES ON WINDOWS MACHINES

On Windows machines you might have issues compiling your project because of `snappyer` package that requires C/++ code compilation.
Use these steps to be able to compile it without issues:

- Use command line and not PowerShell!
- Install [Microsoft C++ toolset](https://learn.microsoft.com/en-us/cpp/build/building-on-the-command-line?view=msvc-170#download-and-install-the-tools], you don't have to go full C++ development, just the compilation toolset is fine
- Add this `c:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.37.32822\bin\Hostx64\x64\` or similar path (based on your installed version) to PATH environment variable, this will add `cl.exe` to path
- Before compilation run `"C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"` which you should have by now. This setups all environment variables needed for compilation of C/++ code, including standard `.h` files

We have this script in our project to setup the environment.

`setup.bat`
```bat
call "c:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

mix deps.get && mix deps.compile
```

> If you still have issues
> - run `mix` in debug mode of `mix` by setting environment variable `MIX_DEBUG=1`
> - and debug mode of `rebar3` by setting environment variable `DIAGNOSTIC=1`

## Configuration

### Elixir Project

Loki Logger's behavior is controlled using the application configuration environment:

* __loki_host__ : [OPTIONAL] the hostname of the syslog server, default `http://localhost:3100`
* __loki_path__ : [OPTIONAL] path to the endpoint, default `/loki/api/v1/push`
* __loki_labels__ : [OPTIONAL] the Loki log labels used to select the log stream in, default `%{application: "loki_logger_library"}`
* __loki_scope_org_id__: [OPTIONAL] optional tenant ID for multitenancy, default `fake`, which is a standard Loki value when you have just one tenant
* __level__: [OPTIONAL] logging threshold. Messages "above" this threshold will be discarded. The supported levels, ordered by precedence are :debug, :info, :warn, :error.
* __format__: [OPTIONAL] the format message used to print logs. Defaults to: "$metadata level=$level $levelpad$message". It may also be a {module, function} tuple that is invoked with the log level, the message, the current timestamp and the metadata.
* __metadata__: [OPTIONAL] the metadata to be printed by $metadata. Defaults to :all, which prints all metadata to the message.
* __max_buffer__: [OPTIONAL] the amount of entries to buffer before posting to the Loki REST api. Defaults to 32.  

* __finch_protocols__: [OPTIONAL] the HTTP protocol to use when communicating with Loki, supported values are `:http1` and `:http2`, default `:http1`.
* __finch_pool_size__: [OPTIONAL] the amount of HTTP connection pools to create, applicable only for HTTP1, for HTTP2 the value is always set to 1, because HTTP2 is by itself multiplexed, default 16.
* __finch_pool_count__: [OPTIONAL] the amount of HTTP connection pools to create, default `4`.
* __finch_pool_max_idle_time__: [OPTIONAL] I have no idea what this does :-)
* __mint_conn_opts__: [OPTIONAL] Mint is the low-level HTTP client library and this is the way to set it up. We use it, for example, to setup CA certificate for internal servers.


For example, the following `config/config.exs` file sets up Loki Logger using
level debug, with `application` label `loki_logger_library`. 

`config.exs`
```elixir
use Mix.Config

config :logger,
       backends: [LokiLogger]

config :logger, :keen_loki_logger,
  level: :debug,
  format: "$metadata level=$level $message",
  metadata: [:erl_level, :application, :file, :module, :function],
  max_buffer: 300,
  loki_host: "https://1.2.3.4:3100",
  basic_auth_user: "lokiuser",
  basic_auth_password: "lokipassword",
  finch_protocols: [:http2],
  mint_conn_opts: [transport_opts: [cacerts: :public_key.cacerts_get()]]
```

`runtime.exs`
```elixir
config :logger, :keen_loki_logger,
  loki_labels: %{app: "dummy_logging_service", env: System.get_env("APP_ENV"), host: System.get_env("COMPUTER_NAME")}
```

# Protobuff lib regeneration

only needed for development 

```shell script
protoc --proto_path=./lib/proto --elixir_out=./lib lib/proto/loki.proto 
```

## License

The source code is released under the Apache v2.0 License.

Check [LICENSE](LICENSE) for more information.

