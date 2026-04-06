defmodule AstrodynamicsTest do
  use ExUnit.Case
  doctest Astrodynamics

  test "propagate_rk4 circular orbit" do
    r = {7000.0, 0.0, 0.0}
    v = {0.0, :math.sqrt(398_600.4418 / 7000.0), 0.0}
    period = 2.0 * :math.pi() * :math.sqrt(:math.pow(7000.0, 3) / 398_600.4418)

    {:ok, {new_r, _new_v}} = Astrodynamics.propagate_rk4(r, v, period, ["twobody"])

    {x, y, z} = new_r
    assert abs(x - 7000.0) < 10.0
    assert abs(y) < 10.0
    assert abs(z) < 1.0e-12
  end

  test "propagate_dp54 circular orbit" do
    r = {7000.0, 0.0, 0.0}
    v = {0.0, :math.sqrt(398_600.4418 / 7000.0), 0.0}
    period = 2.0 * :math.pi() * :math.sqrt(:math.pow(7000.0, 3) / 398_600.4418)

    {:ok, {new_r, _new_v}} =
      Astrodynamics.propagate_dp54(r, v, period, ["twobody"], 1.0e-12, 1.0e-12)

    {x, y, z} = new_r
    # We expect much better precision with DP54
    assert abs(x - 7000.0) < 1.0e-7
    assert abs(y) < 1.0e-7
    assert abs(z) < 1.0e-12
  end

  test "propagate_dp54 J2 secular drift oracle" do
    r_mag = 7000.0
    inc_deg = 98.0
    inc_rad = inc_deg * :math.pi() / 180.0
    mu = 398_600.4418
    re = 6378.137
    j2 = 1.08262668e-3

    v_mag = :math.sqrt(mu / r_mag)
    r = {r_mag, 0.0, 0.0}
    v = {0.0, v_mag * :math.cos(inc_rad), v_mag * :math.sin(inc_rad)}

    # Propagate for one day
    t_end = 86400.0

    {:ok, {final_r, final_v}} =
      Astrodynamics.propagate_dp54(r, v, t_end, ["twobody", "j2"], 1.0e-12, 1.0e-12)

    # Analytical J2 RAAN drift
    n = :math.sqrt(mu / :math.pow(r_mag, 3))
    raan_drift_rate = -1.5 * j2 * :math.pow(re / r_mag, 2) * n * :math.cos(inc_rad)
    expected_raan_drift = raan_drift_rate * t_end

    # Calculate actual RAAN drift
    {rx, ry, rz} = final_r
    {vx, vy, vz} = final_v

    # h = r x v
    hx = ry * vz - rz * vy
    hy = rz * vx - rx * vz
    _hz = rx * vy - ry * vx

    # n = K x h = {-hy, hx, 0}
    nx = -hy
    ny = hx

    actual_raan = :math.atan2(ny, nx)

    # Initial RAAN calculation
    h0x = 0.0 * (v_mag * :math.sin(inc_rad)) - 0.0 * (v_mag * :math.cos(inc_rad))
    h0y = 0.0 * 0.0 - r_mag * (v_mag * :math.sin(inc_rad))
    _h0z = r_mag * (v_mag * :math.cos(inc_rad)) - 0.0 * 0.0

    n0x = -h0y
    n0y = h0x
    initial_raan = :math.atan2(n0y, n0x)

    actual_drift = actual_raan - initial_raan
    # Normalize to [-PI, PI]
    actual_drift = normalize_angle(actual_drift)

    assert_in_delta actual_drift, expected_raan_drift, abs(expected_raan_drift) * 0.01
  end

  defp normalize_angle(angle) do
    cond do
      angle > :math.pi() -> normalize_angle(angle - 2 * :math.pi())
      angle <= -:math.pi() -> normalize_angle(angle + 2 * :math.pi())
      true -> angle
    end
  end
end
