defmodule Binn.MixProject do
  use Mix.Project

  def project do
    [
      app: :binn,
      version: "0.1.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end
  
  defp package() do
    [maintainers: ["Thanos VAssilakis"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/thanos/binn"}]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.18", only: :dev, runtime: false},
     {:plug, "~> 1.0", optional: true},
     {:excoveralls, "~> 0.10", only: :test},
     {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
     {:alchemetrics, "~> 0.5.2", only: [:dev, :test], runtime: false},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
