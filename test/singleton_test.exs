defmodule SingletonTest do
  use ExUnit.Case
  # doctest Singleton

  defmodule Foo do
    use GenServer
    require Logger

    def init([_]) do
      {:ok, 1}
    end
  end

  test "manager" do
    assert {:ok, _} = Singleton.start_child(Foo, [1], Foo)
    assert {:error, {:already_started, _}} = Singleton.start_child(Foo, [1], Foo)

    assert is_pid(:global.whereis_name(Foo))

    assert :ok = Singleton.stop_child(Foo, [1])
    assert {:error, :not_found} = Singleton.stop_child(Foo, [1])

    assert :undefined = :global.whereis_name(Foo)

    assert {:ok, _} = Singleton.start_child(Foo, [1], Foo)
    assert is_pid(:global.whereis_name(Foo))

  end


  test "manager exit strategy" do
    assert {:ok, _} = Singleton.start_child(Foo, [2], Foo2, :random_notify)
  end

  # FIXME test multi-node scenario

end
