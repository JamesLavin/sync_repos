defmodule SyncRepos.MixProject do
  use Mix.Project

  def project do
    [
      app: :sync_repos,
      version: "0.1.0",
      elixir: "~> 1.9",
      escript: escript(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp escript do
    [main_module: SyncRepos.CLI]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false},
      {:yaml_elixir, "~> 2.4.0"}
    ]
  end
end
