defmodule RogerUi.Mixfile do
  use Mix.Project

  def project do
    [
      app: :roger_ui,
      version: "0.1.6",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      description: """
      Dashboard and monitoring tools for Roger job processing system
      """,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      deps: deps(),
      aliases: aliases()
    ]
  end

  def package do
    [
      files: ~w(lib test priv/static) ++ ~w(LICENSE mix.exs README.md),
      maintainers: ["Antonio Abella", "Paul Engel"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/Spadavecchia/roger_ui"}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {RogerUi.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:roger, "~> 1.3.0"},
      {:plug, "~> 1.4"},
      {:cowboy, "~> 1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:credo, ">= 0.0.0", only: :dev},
      {:excoveralls, "~> 0.8", only: :test},
      {:mox, "~> 0.3", only: :test}
    ]
  end
end
