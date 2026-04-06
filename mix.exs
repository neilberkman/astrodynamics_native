defmodule Astrodynamics.MixProject do
  use Mix.Project

  @version "0.5.0"
  @source_url "https://github.com/neilberkman/astrodynamics_native"

  def project do
    [
      app: :astrodynamics,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      source_url: @source_url
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
      {:rustler, "~> 0.37.3", optional: true},
      {:rustler_precompiled, "~> 0.9.0"}
    ]
  end

  defp description do
    "Elixir bindings for the astrodynamics Rust crate with precompiled NIF support."
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      },
      files: [
        "lib",
        "native/astrodynamics_native/src",
        "native/astrodynamics_native/Cargo*",
        "checksum-*.exs",
        "mix.exs",
        "README.md",
        "LICENSE"
      ]
    ]
  end

  defp docs do
    [
      main: "Astrodynamics",
      source_url: @source_url,
      source_ref: "v#{@version}"
    ]
  end
end
