# Singleton

Convenience wrapper library around Erlang's `global` module to ensure
a single instance of a process is kept running on a cluster of nodes.


## Installation

The package can be installed as:

  1. Add `singleton` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:singleton, "~> 1.0.0"}]
    end
    ```

  2. Ensure `singleton` is started before your application:

    ```elixir
    def application do
      [applications: [:singleton]]
    end
    ```

## Usage

Use `Singleton.start_child/3` to start a unique process.

    Singleton.start_child(MyServer, [1], {:myserver, 1})

Execute this command on all nodes. As soon as nodes connect, you'll
see logger messages like:

    04:56:29.003 [info]  global: Name conflict terminating {MyServer, #PID<12501.68.0>}

When you now stop (or disconnect) the node on which the singleton
process runs, you'll see it get started on one of the other nodes.
