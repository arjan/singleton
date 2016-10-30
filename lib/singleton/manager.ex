defmodule Singleton.Manager do
  @moduledoc """

  Singleton watchdog process

  Each node that the singleton runs on, runs this process. It is
  responsible for starting the singleton process (with the help of
  Erlang's 'global' module).

  When starting the singleton process fails, it instead monitors the
  process, so that in case it dies, it will try to start it locally.

  The singleton process is started using the `GenServer.start_link`
  call, with the given module and args.

  """

  use GenServer

  require Logger

  @doc """
  Start the manager process, registering it under a unique name.
  """
  def start_link(mod, args, name, child_name) do
    GenServer.start_link(__MODULE__, [mod, args, name], name: child_name)
  end

  @moduledoc false
  defmodule State do
    defstruct pid: nil, mod: nil, args: nil, name: nil
  end

  @doc false
  def init([mod, args, name]) do
    state = %State{mod: mod,
                   args: args,
                   name: name}
    {:ok, restart(state)}
  end

  @doc false
  def handle_info({:DOWN, _, :process, pid, _}, state = %State{pid: pid}) do
    {:noreply, restart(state)}
  end

  defp restart(state) do
    start_result = GenServer.start_link(state.mod, state.args, name: {:global, state.name})
    case start_result do
      {:ok, pid} ->
        %State{state | pid: pid}
      {:error, {:already_started, pid}} ->
        Process.monitor(pid)
        %State{state | pid: pid}
    end
  end

end
