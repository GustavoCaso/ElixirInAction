defmodule Todo.Mixfile do
  use Mix.Project

  def project do
    [ app: :todo,
      version: "0.0.1",
      elixir: "~> 1.2",
      deps: deps
    ]
  end

  def application do
    [
      applications: [:logger, :gproc],
      mod: {Todo.Application, []},
      env: [
        port: 5454
      ]
    ]
  end

  defp deps do
    [
      {:gproc, "0.3.1"},
      {:cowboy, "1.0.0"},
      {:plug, "0.10.0"},
      {:meck, "0.8.2", only: :test},
      {:httpoison, "0.4.3", only: :test}
    ]
  end
end
