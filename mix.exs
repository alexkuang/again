defmodule Again.MixProject do
  use Mix.Project

  def project do
    [
      app: :again,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer_settings()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:mox, "~> 1.1", only: :test}
    ]
  end

  defp dialyzer_settings do
    [
      plt_file: {:no_warn, "priv/plts/again.plt"},
      plt_add_apps: [:mix]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
