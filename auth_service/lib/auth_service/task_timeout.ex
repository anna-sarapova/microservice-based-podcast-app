defmodule TaskTimeout do
  require Logger
  use GenServer

  def start_link(timeout, connection) do
    timer_ref = start_timer(timeout)
    state = %{timer_ref: timer_ref, timeout: timeout, connection: connection}
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def start_timer(timeout) do
    Process.send_after(self(), :timeout, timeout)
  end

  def stop_timer() do
    GenServer.cast(__MODULE__, :stop_timer)
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_info(:timeout, state) do
    response = "Request Timeout"
    AuthService.Router.get_timeout(response, state.connection)
    {:stop, :normal, state}
  end

  def handle_cast(:stop_timer, state) do
    timer_ref = state.timer_ref
    Process.cancel_timer(timer_ref)
    {:noreply, state}
  end
end