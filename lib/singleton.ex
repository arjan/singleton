defmodule Singleton do
  @moduledoc """
  Singleton.

  The top supervisor of singleton is a DynamicSupervisor, started in
  your application's own OTP tree. Singleton can manage many singleton
  processes at the same time. Each singleton is identified by its
  unique `name` term.
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
  def start_child(module, args, name, on_conflict \\ fn -> nil end) do
    child_name = name(module, args)

    spec =
      {Singleton.Manager,
       [
         mod: module,
         args: args,
         name: child_name,
         child_name: name,
         on_conflict: on_conflict
       ]}

    case Process.whereis(Singleton.Supervisor) do
      nil ->
        raise("""
        Singleton.Supervisor must be added to your application's supervision tree.

        If your application includes a supervision tree in `application.ex`, you can
        simply add `Singleton.Supervisor` to the list of children.

            children = [
              ...,
              Singleton.Supervisor
            ]

            supervisor = Supervisor.start_link(children, opts)
        """)

      _pid ->
        DynamicSupervisor.start_child(Singleton.Supervisor, spec)
    end
  end

  def stop_child(module, args) do
    child_name = name(module, args)

    case Process.whereis(child_name) do
      nil -> {:error, :not_found}
      pid -> DynamicSupervisor.terminate_child(Singleton.Supervisor, pid)
    end
  end

  defp name(module, args) do
    bin = :crypto.hash(:sha, :erlang.term_to_binary({module, args}))
    String.to_atom("singleton_" <> Base.encode64(bin, padding: false))
  end

  defp dynamic_supervisor_options() do
    [
      strategy: :one_for_one,
      name: Singleton.Supervisor
    ]
    |> Keyword.merge(Application.get_env(:singleton, :dynamic_supervisor, []))
  end
end
