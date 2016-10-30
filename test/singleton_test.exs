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

    p = :global.whereis_name(Foo)
    assert is_pid(p)
    Process.exit(p, :kill)

    :timer.sleep(200)

    p = :global.whereis_name(Foo)
    assert is_pid(p)

  end

  # FIXME test multi-node scenario

end
