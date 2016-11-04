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
  def start_link(mod, args, name, child_name, exit_strategy \\ :random_exit) do
    GenServer.start_link(__MODULE__, [mod, args, name, exit_strategy], name: child_name)
  end

  defmodule State do
    @moduledoc false
    defstruct pid: nil, mod: nil, args: nil, name: nil, exit_strategy: nil
  end

  @doc false
  def init([mod, args, name, exit_strategy]) do
    state = %State{mod: mod,
                   args: args,
                   name: name,
                   exit_strategy: exit_strategy}
    {:ok, restart(state)}
  end

  @doc false
  def handle_info({:DOWN, _, :process, pid, _}, state = %State{pid: pid}) do
    {:noreply, restart(state)}
  end

  defp restart(state) do
    start_result = GenServer.start_link(state.mod, state.args, name: {:via, Singleton, {state.name, state.exit_strategy}})
    case start_result do
      {:ok, pid} ->
        %State{state | pid: pid}
      {:error, {:already_started, pid}} ->
        Process.monitor(pid)
        %State{state | pid: pid}
    end
  end

end
