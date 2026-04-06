# AstrodynamicsNative

## To load the NIF:

```elixir
defmodule Astrodynamics.Native do
  use Rustler, otp_app: :astrodynamics, crate: "astrodynamics_native"

  # When your NIF is loaded, it will override this function.
  def propagate_rk4(_r, _v, _dt, _forces), do: :erlang.nif_error(:nif_not_loaded)
  def propagate_dp54(_r, _v, _dt, _forces, _abs_tol, _rel_tol), do: :erlang.nif_error(:nif_not_loaded)
end
```
