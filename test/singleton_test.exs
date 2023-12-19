defmodule SingletonTest do
  use ExUnit.Case

  setup do
    {:ok, pid} = Singleton.Supervisor.start_link(name: SingletonTest.Supervisor)
    {:ok, pid: pid}
  end

  # doctest Singleton

  defmodule Foo do
    use GenServer
    require Logger

    def init([]) do
      {:ok, 1}
    end
  end

  test "manager" do
    assert {:ok, _} =
             Singleton.start_child(SingletonTest.Supervisor, Foo, [], Foo)

    assert {:error, {:already_started, _}} =
             Singleton.start_child(SingletonTest.Supervisor, Foo, [], Foo)

    assert is_pid(:global.whereis_name(Foo))

    assert :ok = Singleton.stop_child(SingletonTest.Supervisor, Foo, [])

    assert {:error, :not_found} =
             Singleton.stop_child(SingletonTest.Supervisor, Foo, [])

    assert :undefined = :global.whereis_name(Foo)

    assert {:ok, _} =
             Singleton.start_child(SingletonTest.Supervisor, Foo, [], Foo)

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
    assert {:ok, _} =
             Singleton.start_child(
               SingletonTest.Supervisor,
               ExitingServer,
               [],
               ExitingServer
             )

    assert is_pid(:global.whereis_name(ExitingServer))

    GenServer.call({:global, ExitingServer}, :stop)
    :timer.sleep(10)

    assert {:ok, _} =
             Singleton.start_child(
               SingletonTest.Supervisor,
               ExitingServer,
               [],
               ExitingServer
             )

    assert is_pid(:global.whereis_name(ExitingServer))
  end

  test "no started singleton supervisor raises error" do
    assert_raise RuntimeError, fn ->
      Singleton.start_child(
        SingletonTest.NoSupervisor,
        ExitingServer,
        [],
        ExitingServer
      )
    end
  end

  # FIXME test multi-node scenario
end
