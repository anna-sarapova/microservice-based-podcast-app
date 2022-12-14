defmodule AuthService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
#    RegisteringService.start_link()
    children = [
      {
        Plug.Cowboy,
        scheme: :http,
        plug: AuthService.Router,
        options: [port: Application.get_env(:auth_service, :port)]
      },
      {
        Mongo,
        [
          name: :mongo,
          database: Application.get_env(:auth_service, :database),
          seeds: Application.get_env(:auth_service, :seeds),
          pool_size: Application.get_env(:auth_service, :pool_size)
        ]
      },
      %{
        id: RegisteringService,
        start: {RegisteringService, :start_link, []}
      }
    ]
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AuthService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
