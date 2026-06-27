> [!IMPORTANT]
> **This project has been superseded by [Sidereon](https://github.com/neilberkman/sidereon-ex).**
> The `astrodynamics` hex package is retired — install **[`sidereon`](https://hex.pm/packages/sidereon)** instead.
> This repository is archived and no longer maintained.

# Astrodynamics

Elixir bindings for the `astrodynamics` Rust library, distributed as a Rustler
NIF with precompiled binaries for common BEAM targets.

## Installation

The package can be installed by adding `astrodynamics` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:astrodynamics, "~> 0.6.1"}
  ]
end
```

By default, the package downloads a matching precompiled NIF from GitHub
Releases. To force a local build from source instead, set:

```bash
ASTRODYNAMICS_BUILD=1
```

Source builds are supported on GNU and musl Linux targets. The precompiled
release matrix includes Apple Silicon, Apple Intel, GNU Linux, and musl Linux
targets for the supported Rustler NIF versions.

The current wrapper exposes:

- `propagate_rk4/4`
- `propagate_dp54/6`

Documentation can be found at <https://hexdocs.pm/astrodynamics>.
