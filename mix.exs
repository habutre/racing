defmodule Racing.MixProject do
  use Mix.Project

  def project do
    [
      app: :racing,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:csv, "~> 2.3.1"},
      {:credo, "~> 1.1.2"}
    ]
  end
end