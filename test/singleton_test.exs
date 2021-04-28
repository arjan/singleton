defmodule SingletonTest do
  use ExUnit.Case

  # doctest Singleton

  defmodule Foo do
    use GenServer
    require Logger

    def init([]) do
      {:ok, 1}
    end
  end

  test "manager" do
    assert {:ok, _} = Singleton.start_child(Foo, [], Foo)
    assert {:error, {:already_started, _}} = Singleton.start_child(Foo, [], Foo)

    assert is_pid(:global.whereis_name(Foo))

    assert :ok = Singleton.stop_child(Foo, [])
    assert {:error, :not_found} = Singleton.stop_child(Foo, [])

    assert :undefined = :global.whereis_name(Foo)

    assert {:ok, _} = Singleton.start_child(Foo, [], Foo)
    assert is_pid(:global.whereis_name(Foo))
  end

  defmodule ExitingServer do
    use GenServer
    require Logger

    def init([]) do
      {:ok, 1}
    end

    def handle_call(:stop, _from, state) do
      {:stop, :normal, :ok, state}
    end
  end

  test "child process normal exit" do
    assert {:ok, _} = Singleton.start_child(ExitingServer, [], ExitingServer)
    assert is_pid(:global.whereis_name(ExitingServer))

    GenServer.call({:global, ExitingServer}, :stop)
    :timer.sleep(10)

    assert {:ok, singleton} =
             Singleton.start_child(ExitingServer, [], ExitingServer)

    assert is_pid(:global.whereis_name(ExitingServer))

    # not keep process after test
    DynamicSupervisor.stop(singleton)

    :timer.sleep(10)
  end

  test "child process normal exit, keep permanent" do
    assert {:ok, singleton} =
             Singleton.start_child(
               ExitingServer,
               [],
               ExitingServer,
               fn -> nil end,
               true
             )

    assert is_pid(:global.whereis_name(ExitingServer))

    GenServer.call({:global, ExitingServer}, :stop)
    :timer.sleep(10)

    assert {:error, {:already_started, _}} =
             Singleton.start_child(ExitingServer, [], ExitingServer)

    DynamicSupervisor.stop(singleton)
    :timer.sleep(10)
  end

  # FIXME test multi-node scenario
end
