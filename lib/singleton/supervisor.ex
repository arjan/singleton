defmodule Singleton.Supervisor do
  @moduledoc """
  Singleton supervisor.
  """

  use DynamicSupervisor

  require Logger

  def start_link(name: name) do
    DynamicSupervisor.start_link(__MODULE__, [], name: name)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
