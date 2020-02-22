defmodule Singleton.Mixfile do
  use Mix.Project

  def project do
    [
      app: :singleton,
      version: "1.2.0",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      source_url: "https://github.com/arjan/singleton",
      homepage_url: "https://github.com/arjan/singleton",
      deps: deps()
    ]
  end

  defp description do
    "Global, supervised singleton processes for Elixir"
  end

  defp package do
    %{
      files: ["lib", "mix.exs", "*.md", "LICENSE"],
      maintainers: ["Arjan Scherpenisse"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/arjan/singleton"}
    }
  end

  # Configuration for the OTP application
  def application do
    [applications: [:logger], mod: {Singleton, {}}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    []
  end
end
