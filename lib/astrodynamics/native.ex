defmodule Astrodynamics.Native do
  @moduledoc false

  version = Mix.Project.config()[:version]
  checksum_file = Path.expand("../../checksum-Elixir.Astrodynamics.Native.exs", __DIR__)
  source_checkout? = File.exists?(Path.expand("../../.git", __DIR__))

  checksum_current? =
    File.exists?(checksum_file) and
      checksum_file |> File.read!() |> String.contains?("-v#{version}-")

  force_build =
    System.get_env("ASTRODYNAMICS_BUILD") in ["1", "true"] or source_checkout? or
      not checksum_current?

  use RustlerPrecompiled,
    otp_app: :astrodynamics,
    crate: "astrodynamics_native",
    base_url: "https://github.com/neilberkman/astrodynamics_native/releases/download/v#{version}",
    force_build: force_build,
    version: version,
    nif_versions: ["2.17", "2.16", "2.15"],
    targets: [
      "aarch64-apple-darwin",
      "aarch64-unknown-linux-gnu",
      "aarch64-unknown-linux-musl",
      "x86_64-apple-darwin",
      "x86_64-unknown-linux-gnu",
      "x86_64-unknown-linux-musl"
    ]

  # When your NIF is loaded, it will override this function.
  def propagate_rk4(_r, _v, _dt, _forces), do: :erlang.nif_error(:nif_not_loaded)

  def propagate_dp54(_r, _v, _dt, _forces, _abs_tol, _rel_tol),
    do: :erlang.nif_error(:nif_not_loaded)
end
