defmodule Singleton.Dist do
  defmodule TestServer do
    use GenServer
    require Logger

    def init([]) do
      Logger.warn("TestServer start: #{inspect(self())}")
      {:ok, nil}
    end
  end

  def setup do
    {:ok, _pid} = Singleton.Supervisor.start_link(name: Singleton.Supervisor)
    Singleton.start_child(Singleton.Supervisor, TestServer, [], TestServer)
  end
end
