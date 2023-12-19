defmodule Singleton.Mixfile do
  use Mix.Project

  def project do
    [
      app: :singleton,
      version: File.read!("VERSION"),
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      source_url: "https://github.com/arjan/singleton",
      homepage_url: "https://github.com/arjan/singleton",
      deps: deps(),
      aliases: aliases(),
      preferred_cli_env: [quality: :test],
      dialyzer: [flags: ["-Wunmatched_returns", :error_handling, :underspecs]]
    ]
  end

  defp description do
    "Global, supervised singleton processes for Elixir"
  end

  defp package do
    %{
      files: ["lib", "mix.exs", "*.md", "LICENSE", "VERSION"],
      maintainers: ["Arjan Scherpenisse"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/arjan/singleton"}
    }
  end

  # Configuration for the OTP application
  def application do
    [extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      quality: [
        "format --check-formatted",
        "compile --force --all-warnings --warnings-as-errors",
        "test",
        "dialyzer"
      ]
    ]
  end
end
