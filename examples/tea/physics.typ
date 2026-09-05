// The thermal model. Every number quoted in the text and every curve in the
// figures is computed here, so the prose and the graphs cannot drift apart.

// ---------------------------------------------------------------- constants
#let sigma = 5.670374419e-8   // Stefan-Boltzmann, W m^-2 K^-4
#let R-gas = 8.314462         // J mol^-1 K^-1
#let M-water = 0.0180153      // kg mol^-1
#let c-water = 4180.0         // J kg^-1 K^-1
#let rho-water = 997.0        // kg m^-3
// Air properties, all at a film temperature of 40 C (313 K). They have to come
// from one temperature: rho enters the mass transfer coefficient directly, so
// mixing a 30 C density with 50 C transport properties biases evaporation.
#let rho-air = 1.128          // kg m^-3
#let cp-air = 1006.0          // J kg^-1 K^-1
#let k-air = 0.0273           // W m^-1 K^-1
#let nu-air = 1.72e-5         // m^2 s^-1
#let alpha-air = 2.44e-5      // m^2 s^-1
// Le = alpha/D with D = 2.6e-5 m^2/s for water vapour in air at 40 C.
#let Le23 = 0.958             // Le^(2/3)
#let g = 9.81

#let K(T) = T + 273.15

/// Magnus form of the saturation vapour pressure, Pa, for T in degrees C.
#let p-sat(T) = 610.94 * calc.exp(17.625 * T / (T + 243.04))

/// Density of saturated water vapour, kg m^-3.
#let rho-sat(T) = p-sat(T) * M-water / (R-gas * K(T))

/// Latent heat of vaporisation, J kg^-1 (linear fit, good to 100 C).
#let h-fg(T) = 2.501e6 - 2370.0 * T

/// Linearised radiation coefficient about the mean of T and Ta.
#let h-rad(T, Ta, eps) = {
  let Tm = (K(T) + K(Ta)) / 2
  4 * eps * sigma * calc.pow(Tm, 3)
}

/// Natural-convection coefficient for a heated horizontal plate facing up.
/// Nu = 0.54 Ra^(1/4), with the characteristic length A/P = r/2.
#let h-plate(T, Ta, r) = {
  let L = r / 2
  let dT = calc.max(T - Ta, 0.1)
  let beta = 1 / ((K(T) + K(Ta)) / 2)
  let Ra = g * beta * dT * calc.pow(L, 3) / (nu-air * alpha-air)
  0.54 * calc.pow(Ra, 0.25) * k-air / L
}

/// Natural-convection coefficient for a vertical cylinder wall.
/// Nu = 0.59 Ra^(1/4), characteristic length = wall height.
#let h-wall-free(T, Ta, L) = {
  let dT = calc.max(T - Ta, 0.1)
  let beta = 1 / ((K(T) + K(Ta)) / 2)
  let Ra = g * beta * dT * calc.pow(L, 3) / (nu-air * alpha-air)
  0.59 * calc.pow(Ra, 0.25) * k-air / L
}

// ------------------------------------------------------------------ vessels
/// A vessel is described by its geometry and its surface properties.
#let mug(
  volume: 300e-6,        // m^3
  r: 0.040,              // inner radius, m
  wall-t: 0.005,         // wall thickness, m
  k-wall: 1.5,           // W m^-1 K^-1, ceramic
  c-vessel: 240.0,       // J K^-1, thermal capacity of the vessel body
  eps-water: 0.95,
  eps-wall: 0.90,
  h-in: 300.0,           // W m^-2 K^-1, inner-wall convection (vigorous)
  lid-U: none,           // W m^-2 K^-1; none = open cup
  shield: 0.55,          // multiplies the free-surface coefficient (see text)
  U-override: none,      // W m^-2 K^-1 overall, for vacuum flasks
  extra-R: 0.0,          // m^2 K W^-1, an added insulating layer (a cosy)
) = (
  volume: volume, r: r, wall-t: wall-t, k-wall: k-wall, c-vessel: c-vessel,
  eps-water: eps-water, eps-wall: eps-wall, h-in: h-in, lid-U: lid-U,
  shield: shield, U-override: U-override, extra-R: extra-R,
)

#let liquid-depth(v) = v.volume / (calc.pi * calc.pow(v.r, 2))
#let area-surface(v) = calc.pi * calc.pow(v.r, 2)
#let area-wall(v) = 2 * calc.pi * (v.r + v.wall-t) * liquid-depth(v)
#let heat-capacity(v) = v.volume * rho-water * c-water + v.c-vessel

/// Outer wall temperature, from the series resistance through the wall.
#let wall-temp(v, T, Ta) = {
  let R-in = 1 / v.h-in + v.wall-t / v.k-wall + v.extra-R
  let L = calc.max(liquid-depth(v), 0.01)
  // The outside film coefficient depends on the wall temperature we are
  // solving for (h goes as dT^(1/4)), so iterate. Starting from the tea
  // temperature this converges in two or three passes; four is ample. Skipping
  // it under-predicts the wall loss by ~22% for an insulated vessel.
  let Tw = T
  for _ in range(4) {
    let h-out = h-wall-free(Tw, Ta, L) + h-rad(Tw, Ta, v.eps-wall)
    Tw = (T / R-in + h-out * Ta) / (1 / R-in + h-out)
  }
  Tw
}

/// The individual loss channels, in watts.
#let channels(v, T, Ta, rh) = {
  let As = area-surface(v)
  let Aw = area-wall(v)
  let surf-conv = 0.0
  let surf-rad = 0.0
  let evap = 0.0
  let wall-conv = 0.0
  let wall-rad = 0.0

  if v.U-override != none {
    // A vacuum flask is described by one overall coefficient over the whole
    // wetted envelope; its internal breakdown is not resolved here.
    wall-conv = v.U-override * (Aw + As) * (T - Ta)
  } else {
    // --- free surface
    if v.lid-U == none {
      let hs = h-plate(T, Ta, v.r) * v.shield
      surf-conv = hs * As * (T - Ta)
      // The same recess reduces the surface's view factor to the room; what it
      // does not see, it exchanges with wall at nearly its own temperature.
      surf-rad = (v.shield * v.eps-water * sigma * As
        * (calc.pow(K(T), 4) - calc.pow(K(Ta), 4)))
      // Chilton-Colburn analogy between heat and mass transfer.
      let hm = hs / (rho-air * cp-air * Le23)
      let drho = calc.max(rho-sat(T) - rh * rho-sat(Ta), 0.0)
      evap = hm * As * drho * h-fg(T)
    } else {
      surf-conv = v.lid-U * As * (T - Ta)
    }
    // --- wall
    let Tw = wall-temp(v, T, Ta)
    let L = calc.max(liquid-depth(v), 0.01)
    wall-conv = h-wall-free(Tw, Ta, L) * Aw * (Tw - Ta)
    wall-rad = v.eps-wall * sigma * Aw * (calc.pow(K(Tw), 4) - calc.pow(K(Ta), 4))
  }

  (
    evaporation: evap,
    "surface radiation": surf-rad,
    "surface convection": surf-conv,
    "wall convection": wall-conv,
    "wall radiation": wall-rad,
  )
}

#let total-loss(v, T, Ta, rh) = {
  let c = channels(v, T, Ta, rh)
  (c.evaporation + c.at("surface radiation") + c.at("surface convection")
    + c.at("wall convection") + c.at("wall radiation"))
}

/// Instantaneous time constant, seconds: C divided by the secant conductance.
#let tau(v, T, Ta, rh) = {
  let q = total-loss(v, T, Ta, rh)
  if q <= 0 { return 0.0 }
  heat-capacity(v) * (T - Ta) / q
}

/// Integrate the cooling curve with RK4. Returns (minutes, temperature) pairs.
#let cool(v, T0: 85.0, Ta: 20.0, rh: 0.5, minutes: 60, dt: 10.0, every: 3) = {
  let C = heat-capacity(v)
  let f(T) = -total-loss(v, T, Ta, rh) / C
  let steps = int(calc.round(minutes * 60 / dt))
  let T = T0
  let out = ((0.0, T0),)
  for i in range(steps) {
    let k1 = f(T)
    let k2 = f(T + dt * k1 / 2)
    let k3 = f(T + dt * k2 / 2)
    let k4 = f(T + dt * k3)
    T = T + dt * (k1 + 2 * k2 + 2 * k3 + k4) / 6
    if calc.rem(i + 1, every) == 0 {
      out.push(((i + 1) * dt / 60, T))
    }
  }
  out
}

/// Temperature after mixing two liquids of capacity C1, C2.
#let mix(T1, C1, T2, C2) = (C1 * T1 + C2 * T2) / (C1 + C2)

/// Minutes taken to fall from T0 to Tend. Returns `none` if it never gets there.
#let time-to(v, T0: 85.0, Tend: 60.0, Ta: 20.0, rh: 0.5, dt: 5.0, max-min: 480) = {
  let C = heat-capacity(v)
  let f(T) = -total-loss(v, T, Ta, rh) / C
  let steps = int(calc.round(max-min * 60 / dt))
  let T = T0
  for i in range(steps) {
    let k1 = f(T)
    let k2 = f(T + dt * k1 / 2)
    let k3 = f(T + dt * k2 / 2)
    let k4 = f(T + dt * k3)
    let Tn = T + dt * (k1 + 2 * k2 + 2 * k3 + k4) / 6
    if Tn <= Tend {
      // linear interpolation within the step
      let frac = (T - Tend) / (T - Tn)
      return (i + frac) * dt / 60
    }
    T = Tn
  }
  none
}
