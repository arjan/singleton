defmodule SingletonTest do
  use ExUnit.Case
  # doctest Singleton

  defmodule Foo do
    use GenServer
    require Logger

    def init([]) do
      Logger.warn "Foo start: #{inspect self}"
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

  # FIXME test multi-node scenario

end
