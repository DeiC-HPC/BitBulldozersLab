# THIS IS AI GENERATED (mostly)
# I removed the 2nd derivative.
# -------------------------------------------------------------
# vanilla_mc_jax_greeks.py
# -------------------------------------------------------------
#   European call price + Greeks (Delta, Gamma, Vega, Rho)
# -------------------------------------------------------------
from time import time

import jax
import jax.numpy as jnp
from jax import random, jit, grad, jacfwd, jacrev
from functools import partial

# ------------------------------------------------------------------
# path generator
# ------------------------------------------------------------------

@partial(jax.jit, static_argnames=("n_steps", "n_paths"))
def gbm_paths(key,
              S0: float,
              r: float,
              sigma: float,
              T: float,
              n_steps: int,
              n_paths: int) -> jnp.ndarray:
    """Simulate `n_paths` geometric‑Brownian‑motion price paths."""
    dt = T / n_steps
    key, subkey = random.split(key)
    dw = random.normal(subkey, shape=(n_paths, n_steps)) * jnp.sqrt(dt)

    drift = (r - 0.5 * sigma ** 2) * dt
    logS = jnp.log(S0) + jnp.cumsum(drift + sigma * dw, axis=1)

    # prepend S0 so we have shape (n_paths, n_steps+1)
    logS = jnp.concatenate([jnp.full((n_paths, 1), jnp.log(S0)), logS], axis=1)
    return jnp.exp(logS)


# ------------------------------------------------------------------
# Monte‑Carlo price (JIT‑compiled)
# ------------------------------------------------------------------
@partial(jax.jit, static_argnames=("n_steps", "n_paths"))
def mc_price(key,
             S0: float,
             K: float,
             r: float,
             sigma: float,
             T: float,
             n_steps: int = 100,
             n_paths: int = 100_000) -> float:
    """
    Discounted MC price of a European call.
    All arguments are scalars (except the PRNG key) so JAX can
    differentiate w.r.t. them.
    """
    # Simulate whole matrix of spot paths
    prices = gbm_paths(key, S0, r, sigma, T, n_steps, n_paths)

    # Terminal values
    ST = prices[:, n_steps]

    # Payoff = max(ST - K, 0)
    payoff = jnp.maximum(ST - K, 0.0)

    # Discounted average
    price = jnp.exp(-r * T) * jnp.mean(payoff)
    return price


# ------------------------------------------------------------------
# Greeks via autodiff
# ------------------------------------------------------------------
#   The MC price depends on (S0, K, r, sigma, T).  We treat K as a
#   constant for the Greeks that are usually quoted (Δ, Γ, ν, ρ).
#   If you need sensitivity to K (i.e. “strike‑vega”) just add it
#   to the argument list.

@partial(jax.jit, static_argnames=("n_steps", "n_paths"))
def compute_greeks(key,
                   S0: float,
                   K: float,
                   r: float,
                   sigma: float,
                   T: float,
                   n_steps: int = 100,
                   n_paths: int = 100_000):
    """
    Returns a dictionary with price and the four classic Greeks:
        Δ  (delta)   = ∂Price/∂S0
        Γ  (gamma)   = ∂²Price/∂S0²
        ν  (vega)    = ∂Price/∂σ
        ρ  (rho)     = ∂Price/∂r
    All quantities are Monte‑Carlo estimates; increasing `n_paths`
    reduces the sampling noise.
    """
    # 1️⃣  Price (already JIT‑compiled)
    price = mc_price(key, S0, K, r, sigma, T,
                     n_steps=n_steps, n_paths=n_paths)

    # 2️⃣  First‑order grads (Δ, ν, ρ)
    #    grad returns a function that computes ∂price/∂arg_i
    d_price_d_S0_sigma_r   = grad(mc_price, argnums=[1, 3, 4])   # argnums are 0‑based (key=0)
    delta_rho_vega = d_price_d_S0_sigma_r(key, S0, K, r, sigma, T,
                        n_steps=n_steps, n_paths=n_paths)

    return {
        "price": price,
        "delta": delta_rho_vega[0],
        "vega" : delta_rho_vega[2],
        "rho"  : delta_rho_vega[1]
    }


# ------------------------------------------------------------------
# 4️⃣  Demo / entry point
# ------------------------------------------------------------------
if __name__ == "__main__":
    print(jax.devices())
    # Market data
    S0    = 100.0   # spot
    K     = 105.0   # strike (kept constant for Greeks)
    r     = 0.05    # risk‑free rate
    sigma = 0.20    # volatility
    T     = 1.0     # 1 year

    # MC settings
    n_steps = 500          # daily discretisation
    n_paths = 500_000      # half‑million paths → ~0.1 % MC error

    # Fixed PRNG key (deterministic run)
    rng_key = random.PRNGKey(42)

    results = compute_greeks(rng_key, S0, K, r, sigma, T,
                            n_steps=n_steps, n_paths=n_paths)
    print(results)
    start = time()
    for i in range(1,100):
        _ = compute_greeks(rng_key, S0, K, r, sigma, T,
                                n_steps=n_steps, n_paths=n_paths)
    print(time()-start)
