# Singleton

[![Build Status](https://github.com/arjan/singleton/workflows/test/badge.svg)](https://github.com/arjan/singleton)
[![Module Version](https://img.shields.io/hexpm/v/singleton.svg)](https://hex.pm/packages/singleton)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/singleton/)
[![Total Download](https://img.shields.io/hexpm/dt/singleton.svg)](https://hex.pm/packages/singleton)
[![License](https://img.shields.io/hexpm/l/singleton.svg)](https://github.com/arjan/singleton/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/arjan/singleton.svg)](https://github.com/arjan/singleton/commits/master)

Convenience wrapper library around Erlang's `global` module to ensure
a single instance of a process is kept running on a cluster of nodes.

## Installation

The package can be installed as:

1. Add `singleton` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:singleton, "~> 1.0"}]
end
```

2. Ensure `Singleton.Supervisor` is added to your application's supervision tree:

If your application includes a supervision tree in `application.ex`, you can simply add `Singleton.Supervisor` to the list of children.

```elixir
children = [
  # ...,
  {Singleton.Supervisor, name: MyApp.Singleton}
]

supervisor = Supervisor.start_link(children, opts)
```

## Usage

Use `Singleton.start_child/3` to start a unique GenServer process.

```elixir
Singleton.start_child(MyApp.Singleton, MyServer, [1], {:myserver, 1})
```

Execute this command on all nodes. The `MyServer` GenServer is now
globally registered under the name `{:global, {:myserver, 1}}`.

As soon as you connect nodes together, you'll see logger messages
like:

    04:56:29.003 [info]  global: Name conflict terminating {MyServer, #PID<12501.68.0>}

When you now stop (or disconnect) the node on which the singleton
process runs, you'll see it get started on one of the other nodes.

## Troubleshooting

### More than 3 singleton processes `[info] Application singleton exited: shutdown`

In case you run more than 3 singleton you'll need to increase the
`max_restarts` of `DynamicSupervisor`.

```elixir
config :singleton,
  dynamic_supervisor: [max_restarts: 100]
```

or add `max_restarts` to your singleton supervisor spec:

```
  {Singleton.Supervisor, name: MyApp.Singleton, max_restarts: 100}
```
