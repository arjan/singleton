defmodule Singleton do
  @moduledoc """
  Singleton application.

  The top supervisor of singleton is a `:simple_one_for_one`
  supervisor. Singleton can manage many singleton processes at the
  same time. Each singleton is identified by its unique `name` term.

  """

  use Application

  require Logger

  def start(_, _) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Singleton.Manager, [], restart: :permanent),
    ]

    opts = [strategy: :simple_one_for_one, name: Singleton.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Start a new singleton process.

  This function needs to be executed on all nodes where the singleton
  process is allowed to live. The actual process will be started only
  once; a manager process is started on each node for each singleton
  to ensure that the process continues on (possibly) another node in
  case of node disconnects or crashes.

  """
  def start_child(module, args, name, exit_strategy \\ :random_exit) do
    child_name = name(module, args)
    Supervisor.start_child(Singleton.Supervisor, [module, args, name, child_name, exit_strategy])
  end

  def stop_child(module, args) do
    child_name = name(module, args)
    case Process.whereis(child_name) do
      nil -> {:error, :not_found}
      pid -> Supervisor.terminate_child(Singleton.Supervisor, pid)
    end
  end

  defp name(module, args) do
    bin = :crypto.hash(:sha, :erlang.term_to_binary({module, args}))
    String.to_atom("singleton_" <> Base.encode64(bin, padding: false))
  end

  def whereis_name({name, _strategy}) do
    :global.whereis_name(name)
  end

  def register_name({name, strategy}, pid) do
    :global.register_name(name, pid, map_strategy(strategy))
  end

  def unregister_name({name, _strategy}) do
    :global.unregister_name(name)
  end

  defp map_strategy(:random_exit), do: &:global.random_exit_name/3
  defp map_strategy(:random_notify), do: &:global.random_notify_name/3
  defp map_strategy(:notify_all), do: &:global.notify_all_name/3
  defp map_strategy(strategy) when is_function(strategy), do: strategy

end
