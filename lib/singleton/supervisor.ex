defmodule Singleton.Supervisor do
  @moduledoc """
  Singleton supervisor.
  """

  use DynamicSupervisor

  require Logger

  def start_link(override_opts \\ []) do
    DynamicSupervisor.start_link(
      __MODULE__,
      [],
      dynamic_supervisor_options(override_opts)
    )
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  defp dynamic_supervisor_options(override_opts) do
    [strategy: :one_for_one]
    |> Keyword.merge(Application.get_env(:singleton, :dynamic_supervisor, []))
    |> Keyword.merge(override_opts)
  end
end
