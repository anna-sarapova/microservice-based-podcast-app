defmodule GatewayService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {
        Plug.Cowboy,
        scheme: :http,
        plug: GatewayService.Router,
        options: [port: Application.get_env(:gateway_service, :port)
        ]
      }
    ]
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GatewayService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
