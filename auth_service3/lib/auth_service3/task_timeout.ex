defmodule AuthService3.TaskTimeout do
  use GenServer
  import Plug.Conn
  require Logger

  def start_link(timer_length, conn) do
    timer_number = System.unique_integer([:positive, :monotonic])
    timer_ref = start_timer(timer_length)
    state = %{timer_ref: timer_ref, connection: conn, timer_number: timer_number}
    GenServer.start_link(__MODULE__, state, name: String.to_atom("timer_#{timer_number}"))
  end

  def start_timer(timer_length) do
    Process.send_after(self(), :timer, timer_length)
  end

  def stop_timer(timer_pid) do
    GenServer.cast(timer_pid, :stop_timer)
  end

#  def get_timer_state(timer_pid) do
#    :sys.get_state(timer_pid)
#  end

  def init(state) do
    {:ok, state}
  end

  def handle_info(:timeout, state) do
    conn = state.conn
    send_resp(conn, 408, "Request Timeout")
    halt(conn)
    {:stop, :normal, state}
  end

  def handle_cast(:stop_timer, state) do
    Process.cancel_timer(state.timer_ref)
    {:stop, :normal, state}
  end
end
