use rustler::{Encoder, Env, NifResult, Term};
use astrodynamics::state::CartesianState;
use astrodynamics::forces::{TwoBodyGravity, J2Gravity, CompositeForceModel};
use astrodynamics::integrators::{RK4, DP54, Integrator};
use astrodynamics::propagator::{OrbitalDynamics, PropagationContext, api::IntegratorOptions};
use nalgebra::Vector3;

#[rustler::nif]
fn propagate_rk4(
    env: Env,
    r_tuple: (f64, f64, f64),
    v_tuple: (f64, f64, f64),
    dt: f64,
    forces: Vec<String>,
) -> NifResult<Term> {
    propagate_with_integrator(env, r_tuple, v_tuple, dt, forces, &RK4, &IntegratorOptions::default())
}

#[rustler::nif]
fn propagate_dp54(
    env: Env,
    r_tuple: (f64, f64, f64),
    v_tuple: (f64, f64, f64),
    dt: f64,
    forces: Vec<String>,
    abs_tol: f64,
    rel_tol: f64,
) -> NifResult<Term> {
    let mut opts = IntegratorOptions::default();
    opts.abs_tol = abs_tol;
    opts.rel_tol = rel_tol;
    propagate_with_integrator(env, r_tuple, v_tuple, dt, forces, &DP54, &opts)
}

fn propagate_with_integrator<'a>(
    env: Env<'a>,
    r_tuple: (f64, f64, f64),
    v_tuple: (f64, f64, f64),
    dt: f64,
    forces: Vec<String>,
    integrator: &dyn Integrator,
    opts: &IntegratorOptions,
) -> NifResult<Term<'a>> {
    let initial_state = CartesianState {
        epoch_tdb_seconds: 0.0,
        position_km: Vector3::new(r_tuple.0, r_tuple.1, r_tuple.2),
        velocity_km_s: Vector3::new(v_tuple.0, v_tuple.1, v_tuple.2),
    };
    
    let mut composite_force = CompositeForceModel::new();
    for force_name in forces {
        match force_name.as_str() {
            "twobody" => composite_force.add(Box::new(TwoBodyGravity::default())),
            "j2" => composite_force.add(Box::new(J2Gravity::default())),
            _ => return Ok((rustler::types::atom::Atom::from_str(env, "error")?, format!("Unknown force: {}", force_name)).encode(env)),
        }
    }
    
    let dynamics = OrbitalDynamics { force_model: &composite_force };
    let ctx = PropagationContext::default();
    
    match integrator.propagate(initial_state, dt, &dynamics, &ctx, opts) {
        Ok(result) => {
            let ok = rustler::types::atom::Atom::from_str(env, "ok")?;
            let r = result.final_state.position_km;
            let v = result.final_state.velocity_km_s;
            Ok((ok, ((r.x, r.y, r.z), (v.x, v.y, v.z))).encode(env))
        },
        Err(e) => {
            let error = rustler::types::atom::Atom::from_str(env, "error")?;
            Ok((error, format!("{}", e)).encode(env))
        }
    }
}

rustler::init!("Elixir.Astrodynamics.Native");
