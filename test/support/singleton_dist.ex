defmodule Singleton.Dist do
  defmodule TestServer do
    use GenServer
    require Logger

    def init([]) do
      Logger.warning("TestServer start: #{inspect(self())}")
      {:ok, nil}
    end
  end

  def setup do
    Application.start(:singleton)
    Singleton.start_child(TestServer, [], TestServer)
  end
end
