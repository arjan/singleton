defmodule Singleton do
  @moduledoc """
  Singleton.

  The top supervisor of singleton is a DynamicSupervisor. Singleton
  can manage many singleton processes at the same time. Each singleton
  is identified by its unique `name` term.
  """

  @doc """
  Start a new singleton process. Optionally provide the `on_conflict`
  parameter which will be called whenever a singleton process shuts
  down due to another instance being present in the cluster.

  This function needs to be executed on all nodes where the singleton
  process is allowed to live. The actual process will be started only
  once; a manager process is started on each node for each singleton
  to ensure that the process continues on (possibly) another node in
  case of node disconnects or crashes.

  """
  def start_child(supervisor_name, module, args, name, on_conflict \\ fn -> nil end) do
    child_name = name(module, args)

    spec =
      {Singleton.Manager,
       [
         mod: module,
         args: args,
         name: name,
         child_name: child_name,
         on_conflict: on_conflict
       ]}

    case Process.whereis(supervisor_name) do
      nil ->
        raise("""
        No process found with name #{supervisor_name}.

        Singleton.Supervisor must be added to your application's supervision tree.

        If your application includes a supervision tree in `application.ex`, you can
        simply add `Singleton.Supervisor` to the list of children.

            children = [
              ...,
              {Singleton.Supervisor, name: MyApp.Sinlgeton}
            ]

            supervisor = Supervisor.start_link(children, opts)
        """)

      _pid ->
        DynamicSupervisor.start_child(supervisor_name, spec)
    end
  end

  def stop_child(supervisor_name, module, args) do
    child_name = name(module, args)

    case Process.whereis(child_name) do
      nil -> {:error, :not_found}
      pid -> DynamicSupervisor.terminate_child(supervisor_name, pid)
    end
  end

  defp name(module, args) do
    bin = :crypto.hash(:sha, :erlang.term_to_binary({module, args}))
    String.to_atom("singleton_" <> Base.encode64(bin, padding: false))
  end
end
