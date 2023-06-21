# Singleton

[![Build Status](https://travis-ci.com/arjan/singleton.svg?branch=master)](https://travis-ci.com/arjan/singleton)
[![Hex pm](http://img.shields.io/hexpm/v/singleton.svg?style=flat)](https://hex.pm/packages/singleton)

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

Use `Singleton.start_child/3` to start a unique GenServer process.

    Singleton.start_child(MyServer, [1], {:myserver, 1})

Execute this command on all nodes. The `MyServer` GenServer is now
globally registered under the name `{:global, {:myserver, 1}}`.

As soon as you connect nodes together, you'll see logger messages
like:

    04:56:29.003 [info]  global: Name conflict terminating {MyServer, #PID<12501.68.0>}

When you now stop (or disconnect) the node on which the singleton
process runs, you'll see it get started on one of the other nodes.

## Troubleshooting

### More than 3 singleton processes `[info]  Application singleton exited: shutdown`

In case you run more than 3 singleton you'll need to increase the
`max_restarts` of `DynamicSupervisor`.

```elixir
config :singleton,
  dynamic_supervisor: [max_restarts: 100]
```
