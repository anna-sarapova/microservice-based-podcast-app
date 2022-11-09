defmodule AuthService3.Application do
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
        plug: AuthService3.Router,
        options: [port: Application.get_env(:auth_service3, :port)]
      },
      {
        Mongo,
        [
          name: :mongo,
          database: Application.get_env(:auth_service3, :database),
          pool_size: Application.get_env(:auth_service3, :pool_size)
        ]
      },
      %{
        id: RegisteringService,
        start: {RegisteringService, :start_link, []}
      }
    ]
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AuthService3.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
