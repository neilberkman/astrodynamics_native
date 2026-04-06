# Astrodynamics

Elixir bindings for the `astrodynamics` Rust library, distributed as a Rustler
NIF with precompiled binaries for common BEAM targets.

## Installation

The package can be installed by adding `astrodynamics` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:astrodynamics, "~> 0.5.0"}
  ]
end
```

By default, the package downloads a matching precompiled NIF from GitHub
Releases. To force a local build from source instead, set:

```bash
ASTRODYNAMICS_BUILD=1
```

The current wrapper exposes:

- `propagate_rk4/4`
- `propagate_dp54/6`

Documentation can be found at <https://hexdocs.pm/astrodynamics>.
