defmodule AuthService2.Application do
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
        plug: AuthService2.Router,
        options: [port: Application.get_env(:auth_service2, :port)]
      },
      {
        Mongo,
        [
          name: :mongo,
          database: Application.get_env(:auth_service2, :database),
          seeds: Application.get_env(:auth_service2, :seeds),
          pool_size: Application.get_env(:auth_service2, :pool_size)
        ]
      },
      %{
        id: RegisteringService,
        start: {RegisteringService, :start_link, []}
      }
    ]
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AuthService2.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
