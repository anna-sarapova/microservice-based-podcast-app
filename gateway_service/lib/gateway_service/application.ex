defmodule GatewayService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @fuse_name :gateway_circuit_breaker
  @fuse_options [
#    Tolerate 5 failures for every 1 second time window
    fuse_strategy: {:standard, 5, 1_000},
#    Reset the fuse 5 seconds after it is blown
    fuse_refresh: 5_000,
#    Limit to 100 calls per second
    rate_limit: {100, 1_000}
  ]

  @impl true
  def start(_type, _args) do
    ExternalService.start(@fuse_name, @fuse_options)
    children = [
      {
        Plug.Cowboy,
        scheme: :http,
        plug: GatewayService.Router,
        options: [
          port: Application.get_env(:gateway_service, :port)
        ]
      }
    ]
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GatewayService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
