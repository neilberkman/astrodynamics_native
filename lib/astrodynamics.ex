defmodule Astrodynamics do
  @moduledoc """
  Astrodynamics provides Elixir bindings for the `astrodynamics` Rust library.
  """

  def propagate_rk4(r, v, dt, forces \\ ["twobody"]) do
    Astrodynamics.Native.propagate_rk4(r, v, dt, forces)
  end

  def propagate_dp54(r, v, dt, forces \\ ["twobody"], abs_tol \\ 1.0e-12, rel_tol \\ 1.0e-12) do
    Astrodynamics.Native.propagate_dp54(r, v, dt, forces, abs_tol, rel_tol)
  end
end
