#import "../../src/lib.typ": article
#import "physics.typ" as P
#import "plot.typ": plot

#let dd = math.upright("d")
// A temperature, kept unbreakable: "65 °C" must not split across a line.
#let degC = box[°C]
#let T(x) = box[#x#h(0.17em)°C]

// Reference vessels used throughout.
#let MUG = P.mug()
#let MUG-LID = P.mug(lid-U: 6.0)
#let MUG-COSY = P.mug(lid-U: 6.0, extra-R: 0.25)
#let MUG-COLD = P.mug(c-vessel: 240.0)
#let FLASK = P.mug(volume: 500e-6, r: 0.035, c-vessel: 350.0, U-override: 0.8, lid-U: 0.8)
#let Ta = 20.0
#let RH = 0.5

#let T0 = 85.0
#let tau0 = P.tau(P.mug(), T0, 20.0, 0.5)

// A dash of milk: 30 ml, taken as m^3 like every other volume here.
#let MILK-VOL = 30e-6
#let MILK-T = 5.0
#let C-milk = MILK-VOL * 1030.0 * 3900.0

/// How far the real curve has pulled above the fitted exponential, in kelvin.
#let exp-gap(t) = {
  let model = P.cool(MUG, T0: T0, Ta: Ta, rh: RH, minutes: t, every: 1).last().at(1)
  model - (Ta + (T0 - Ta) * calc.exp(-t * 60 / tau0))
}

#let r2(x) = calc.round(x, digits: 2)
#let r1(x) = calc.round(x, digits: 1)
#let r0(x) = calc.round(x)
/// A value and its unit, kept on one line.
#let qty(v, u) = box[#v#h(0.17em)#u]

#show: article.with(
  title: [How to Keep a Cup of Tea Warm],
  authors: ([A Guide to the Physics of a Cooling Beverage],),
  date: [September 5, 2026],
  paper: "a4",
  size: "10",
  abstract: [
    A cup of tea left on a desk loses heat by four distinct mechanisms, and they
    are not of comparable size. This guide develops the thermal physics needed
    to say which one dominates, when, and by how much: heat capacity and the
    lumped-capacitance approximation, Fourier conduction, natural convection and
    its Nusselt correlations, Stefan--Boltzmann radiation, and evaporation
    through the Clausius--Clapeyron relation and the Chilton--Colburn analogy.
    A quantitative model of a #box[300#h(0.17em)ml] ceramic mug is assembled from
    these parts and calibrated against measured cooling rates. It shows that
    evaporation alone carries about half the heat away from a freshly poured
    mug and remains the largest single channel right through the drinking
    range; only the two wall losses taken together overtake it, at about #T(70).
    That is why a lid is worth more than any amount of insulation applied to
    the sides. The model is then used to rank every intervention available to a
    tea drinker, to settle the question of when to add the milk, and to explain
    why a vacuum flask beats a mug by a factor of about thirty in overall heat
    transfer coefficient. Every figure is computed from the model given in the appendix.
  ],
)

#set math.equation(numbering: "(1)")

= Why tea goes cold

A freshly poured mug of tea is a small, hot, wet object in a large, cool, dry
room, and the second law of thermodynamics has an opinion about that
arrangement. The tea will reach room temperature. Nothing in this guide will
prevent it. What the physics does offer is control over the _rate_, and the
rate is remarkably sensitive to a handful of choices that cost nothing.

The practical question is not "how do I stop the tea cooling" but "how do I
keep it inside a drinkable window for longer". That window has both an upper
and a lower bound. Above roughly #T(65) tea scalds; the most-quoted
epidemiological work on the subject associates habitual drinking above about
#T(65) with oesophageal injury. Below about #T(50) black tea is widely
described as flat, because several of the volatile aromatics that carry its
smell are no longer being driven off fast enough to reach the nose. So the
target is a band roughly #box[15#h(0.17em)K] wide, and the engineering problem is to
spend as much time in it as possible.

That framing matters, because it changes what "good" means. A vacuum flask does
not merely slow the cooling; it holds the tea *above* the drinking window for
hours, which is useful for transport and useless for the next twenty minutes at
a desk. The interesting interventions are the ones that stretch the time spent
between #T(65) and #T(50).

== The four channels

Heat leaves the tea by exactly four routes, and it is worth naming them
immediately because most folk wisdom about tea addresses the wrong one:

/ Conduction: heat flows through the mug wall and into whatever the mug is
  standing on.
/ Convection: air in contact with the hot surfaces warms, becomes buoyant,
  rises, and is replaced by cool air.
/ Radiation: every surface above absolute zero emits electromagnetic radiation;
  a hot mug emits more than the room returns.
/ Evaporation: water molecules leave the free surface, taking their latent heat
  of vaporisation with them.

The last of these is the one people forget, and for an open mug it is the
largest while the tea is hot. Section 4.5 shows that it accounts for about
half the total at #T(80) and stays ahead of every other individual channel
almost all the way to room temperature; it is only when the two wall losses are
added together that they overtake it, at about #T(70). This single
fact organises everything that follows: the highest-value intervention is a lid,
and it is not close.

== What we are allowed to change

Written as a rate equation, the cooling of the tea depends on
$
  C dd(T) / dd(t) = -Q(T, T_a, "geometry", "surfaces", "air")
$ <eq-master>
where $C$ is the thermal capacity of everything that is hot, $T$ the tea
temperature, $T_a$ the ambient temperature, and $Q$ the total heat flow out.
Every intervention in this guide is an attempt to do one of exactly three
things: increase $C$, decrease $Q$, or start with a larger $T$. The rest of the
document is about which levers actually move $Q$ and by how much.

= Heat, temperature, and the energy budget

== Heat capacity

Temperature and heat are not the same quantity, and the distinction does real
work here. Temperature is an intensive property, the thing a thermometer reads.
Heat is energy in transit. The constant of proportionality between them is the
_specific heat capacity_ $c$, defined so that raising a mass $m$ by $Delta T$
requires
$
  Q = m c Delta T.
$ <eq-heatcap>

Water's specific heat capacity, $c approx 4180$#h(0.3em)$"J kg"^(-1) "K"^(-1)$,
is enormous --- higher than almost any other common liquid, about ten times that
of copper by mass. This is why tea stays hot at all. A #box[300#h(0.17em)ml] mug
holds
$
  C_"water" = m c = 0.30 dot 4180 approx #r0(300e-6 * P.rho-water * P.c-water)
  #h(0.3em) "J K"^(-1),
$
so removing one kelvin from it takes about #box[1.25#h(0.17em)kJ]. Counting the
mug as well (below), cooling the whole system the #box[25#h(0.17em)K] from #T(85)
to #T(60) releases
#qty(r1(P.heat-capacity(MUG) * 25 / 1000), [kJ]), and the model does it in
#qty(r1(P.time-to(MUG, T0: 85.0, Tend: 60.0, Ta: Ta, rh: RH)), [minutes]) ---
an average of
#qty(r0(P.heat-capacity(MUG) * 25 / (P.time-to(MUG, T0: 85.0, Tend: 60.0, Ta: Ta, rh: RH) * 60)), [W]),
about what a small incandescent night-light draws.

The mug is part of the thermal system too. A typical stoneware mug weighs about
#box[300#h(0.17em)g] and ceramic has $c approx 800$#h(0.3em)$"J kg"^(-1) "K"^(-1)$,
giving $C_"mug" approx 240$#h(0.3em)$"J K"^(-1)$. Once the mug has come to
temperature it is carrying about 16% of the total stored heat, and it must be
counted:
$
  C_"tot" = m_"water" c_"water" + m_"vessel" c_"vessel"
  approx #r0(P.heat-capacity(MUG)) #h(0.3em) "J K"^(-1).
$ <eq-ctot>
Section 6.2 shows that whether that 240#h(0.3em)$"J K"^(-1)$ is charged to the
tea at the moment of pouring, or paid for in advance, is worth about
#box[12#h(0.17em)K].

== The governing equation

Conservation of energy applied to the tea gives @eq-master. Written per unit
time, the stored energy falls at exactly the rate heat crosses the boundary:
$
  C_"tot" dd(T) / dd(t) = -Q_"cond" - Q_"conv" - Q_"rad" - Q_"evap".
$ <eq-budget>
Everything difficult is hidden in the four terms on the right, each of which
depends on $T$ differently: conduction and convection roughly linearly in
$T - T_a$, radiation as $T^4 - T_a^4$, and evaporation exponentially in $T$. It
is the mismatch between those dependences that makes the cooling curve of real
tea a more interesting shape than the textbook exponential.

== Thermal resistance

It is often convenient to write a heat flow as a temperature difference divided
by a resistance, in exact analogy with Ohm's law:
$
  Q = (T - T_a) / R_"th", quad [R_"th"] = "K W"^(-1).
$ <eq-resistance>
Resistances in series add; resistances in parallel add as reciprocals. This is
the single most useful bookkeeping device in the subject, because it makes the
_bottleneck_ visible. When we come to ask why the material of a mug barely
matters (Section 6.5), the answer will be that the ceramic contributes a
resistance of about $0.003$#h(0.3em)$"m"^2"K W"^(-1)$ in series with an outside
air film of about $0.07$#h(0.3em)$"m"^2"K W"^(-1)$: improving the small
resistance by any factor whatsoever changes almost nothing.

For a surface it is conventional to work per unit area, using a _heat transfer
coefficient_ $h$ with units $"W m"^(-2)"K"^(-1)$, related to the area-specific
resistance by $h = 1 slash R''_"th"$. The overall coefficient for a composite
wall is then
$
  1 / U = 1 / h_"in" + sum_i t_i / k_i + 1 / h_"out",
$ <eq-composite>
with $t_i$ and $k_i$ the thickness and conductivity of each layer.

= Is the tea all one temperature?

@eq-budget quietly assumes the tea has _a_ temperature --- that we may speak of
$T$ rather than $T(bold(r), t)$. This is the *lumped-capacitance*
approximation, and it deserves a check, because it is the assumption that makes
the whole problem tractable.

The usual criterion is the *Biot number*, the ratio of internal to external
thermal resistance:
$
  "Bi" = (h L_c) / k,
$ <eq-biot>
where $L_c$ is a characteristic internal length and $k$ the conductivity of the
_contents_. The standard rule of thumb is that the lumped model is good when
$"Bi" < 0.1$. For our mug, taking the model's own overall coefficient of
#qty(r0(P.total-loss(MUG, 80.0, Ta, RH) / (P.area-surface(MUG) + P.area-wall(MUG)) / 60), [$"W m"^(-2)"K"^(-1)$]),
$L_c approx 0.03$#h(0.17em)m and the conductivity of still water
$k approx 0.6$#h(0.3em)$"W m"^(-1)"K"^(-1)$, we get $"Bi" approx 1.3$ --- an
order of magnitude too large. On the face of it the approximation should fail
badly.

It does not, and the reason is instructive. Still water is a poor conductor, but
the tea is not still. Cooling happens at the _top_ and at the _sides_, so the
water at the top becomes denser than the water beneath it, which is
gravitationally unstable, while the cooled skin on the side walls simply sinks
as a boundary layer. Either way the result is vigorous natural convection in the
cup: a visible overturning circulation that homogenises the bulk far faster than
conduction could. The effective internal conductivity is not $k$ but something
one or two orders of magnitude larger, and the effective Biot number falls
comfortably below the threshold.

Three practical consequences follow. First, the lumped model is justified, and
we may use it for the rest of the guide. Second, *stirring does not cool tea by
mixing it*, because it is already mixed; what stirring does is disturb the
surface, and Section 6.8 argues that this costs a little through the
evaporative channel. Third, the thin surface layer is the exception --- a cup
left absolutely undisturbed does develop a slightly cooler skin a fraction of a
millimetre thick, and it is that skin, not the bulk, that a lid protects.

= The four channels

This section builds each of the four terms in @eq-budget from first principles,
then evaluates them for a reference mug. The reference vessel is a
#box[300#h(0.17em)ml] straight-sided stoneware mug of inner radius #box[40#h(0.17em)mm] and
wall thickness #box[5#h(0.17em)mm], standing in a still room at #T(20) and 50%
relative humidity. Its liquid depth is then
#box[#r0(P.liquid-depth(MUG) * 1000)#h(0.17em)mm], its free surface area
$A_s = #r1(P.area-surface(MUG) * 1e4)$#h(0.3em)$"cm"^2$, and its wetted wall
area $A_w = #r0(P.area-wall(MUG) * 1e4)$#h(0.3em)$"cm"^2$. Note already that
the wall area is more than three times the surface area --- a fact that will
matter once the lid is on.

== Conduction

Conduction is the diffusion of thermal energy through matter without bulk
motion. It obeys *Fourier's law*, which states that the heat flux density is
proportional to the negative temperature gradient:
$
  bold(q) = -k nabla T,
$ <eq-fourier>
with $k$ the thermal conductivity in $"W m"^(-1)"K"^(-1)$. For the
one-dimensional case of a flat slab of thickness $t$ held between two
temperatures, this integrates to the familiar
$
  Q = (k A) / t (T_1 - T_2) = (T_1 - T_2) / R_"th", quad R_"th" = t / (k A).
$ <eq-slab>

Two conduction paths matter for a mug. The first is radially outwards through
the ceramic. Stoneware has $k approx 1.5$#h(0.3em)$"W m"^(-1)"K"^(-1)$, so a
#box[5#h(0.17em)mm] wall has an area-specific resistance of only
$
  R''_"wall" = t / k = 0.005 / 1.5 approx 0.0033 #h(0.3em) "m"^2"K W"^(-1).
$
This is a very small resistance. We will see in Section 6.5 that the air film
on the outside contributes roughly twenty times more. *The mug wall is not the
bottleneck*, which is why the choice of ceramic, glass, or thin steel makes far
less difference to cooling than intuition suggests --- and why a double wall
with a gap, which attacks the outside film rather than the solid, works so much
better than a thicker wall of the same material.

The second path is downwards into the table. Its magnitude depends entirely on
what the table is made of and whether a mat intervenes; a wooden surface or a
cork mat is a good enough insulator that this term is small, while a stone
worktop is a genuine heat sink. Because the contact area is small compared with
the walls, and because it depends so much on the surface, the model in this
guide omits it altogether rather than pretending to a number. The practical rule
stands: *do not stand a mug on stone or metal*.

== Convection

Convection is conduction into a fluid that then carries the energy away
bodily. The transport is described by *Newton's law of cooling*, which is not
really a law so much as the definition of the heat transfer coefficient $h$:
$
  Q_"conv" = h A (T_s - T_a),
$ <eq-newton>
where $T_s$ is the surface temperature. All the physics has been swept into
$h$, which depends on the geometry, the fluid, the orientation, and the
temperature difference itself.

For a mug on a desk, the relevant regime is *natural* (or free) convection: no
fan, no draught, motion driven only by the buoyancy of air that the mug has
warmed. The governing dimensionless group is the *Rayleigh number*, the ratio
of buoyant driving to viscous and diffusive damping:
$
  "Ra"_L = (g beta (T_s - T_a) L^3) / (nu alpha),
$ <eq-rayleigh>
with $g$ gravity, $beta approx 1 slash T$ the thermal expansion coefficient of
air, $nu$ the kinematic viscosity, $alpha$ the thermal diffusivity, and $L$ a
characteristic length. The heat transfer follows through the *Nusselt number*
$"Nu" = h L slash k_"air"$, the ratio of actual heat transfer to what pure
conduction across the same gap would give. For the two geometries we need, the
standard laminar correlations are
$
  "Nu" &= 0.54 "Ra"_L^(1 slash 4) quad ("hot plate facing up"), \
  "Nu" &= 0.59 "Ra"_L^(1 slash 4) quad ("vertical wall").
$ <eq-nusselt>

Both correlations are certified for $10^4 <= "Ra"_L <= 10^7$, which the mug
satisfies while it is hot; below about #T(38) the free surface falls under
$10^4$ and the coefficient there should be read as an extrapolation.

Evaluating @eq-rayleigh for the free surface of the mug at #T(80) --- using
$L = r slash 2 = 20$#h(0.17em)mm for a disc, since the characteristic length of
a horizontal plate is its area divided by its perimeter --- gives
$"Ra" approx 3 times 10^4$, comfortably laminar, and hence
$h approx #r1(P.h-plate(80, Ta, MUG.r))$#h(0.3em)$"W m"^(-2)"K"^(-1)$. The
vertical wall, with $L$ equal to the liquid depth, comes out similar.

Two features of @eq-nusselt are worth extracting. First, $h prop L^(-1 slash 4)$:
*small objects have higher heat transfer coefficients than large ones*, one of
several reasons a small cup is at a disadvantage. Second,
$h prop (Delta T)^(1 slash 4)$, so the convective term is not quite linear in
the temperature difference but goes as $(Delta T)^(5 slash 4)$ --- hot tea
loses heat slightly faster than a naive linear model predicts.

== Radiation

Every object emits electromagnetic radiation by virtue of its temperature. For
a grey surface of emissivity $epsilon$ exchanging with surroundings that
completely enclose it at $T_a$, the *Stefan--Boltzmann law* gives the net
exchange as
$
  Q_"rad" = epsilon sigma A (T^4 - T_a^4),
$ <eq-stefan>
with $sigma = 5.670 times 10^(-8)$#h(0.3em)$"W m"^(-2)"K"^(-4)$ and
temperatures *in kelvin*. The fourth-power dependence is on absolute
temperature, which is why the effect is much less dramatic than it first sounds:
going from #T(20) to #T(80) is a factor of 4 in Celsius but only 1.20 in kelvin,
and $1.20^4 approx 2.1$.

Emissivity is where the surprise lies. Water has $epsilon approx 0.95$ in the
thermal infrared, and glazed ceramic about 0.90. Both are close to perfect
black bodies at these wavelengths, *regardless of colour in the visible*. A
white mug and a black mug radiate essentially identically; the visible-light
intuition is simply the wrong band. The only surfaces with genuinely low
infrared emissivity are bare polished metals --- $epsilon approx 0.05$ for clean
aluminium --- which is exactly why the inside of a vacuum flask is silvered
(Section 6.6) and why a bright metal teapot really does radiate less than a
ceramic one.

For assembling a resistance network it is convenient to linearise @eq-stefan.
Factoring the difference of fourth powers and evaluating at the mean
temperature $T_m = (T + T_a) slash 2$ gives an equivalent coefficient
$
  h_r = 4 epsilon sigma T_m^3,
$ <eq-hrad>
accurate to a few percent over our range. For the free surface at #T(80) this
is $h_r approx #r1(P.h-rad(80, Ta, 0.95))$#h(0.3em)$"W m"^(-2)"K"^(-1)$ ---
of the same order as the convective coefficients of the previous section,
though somewhat smaller than the #qty(r1(P.h-plate(80.0, Ta, MUG.r)), [$"W m"^(-2)"K"^(-1)$])
computed there for an exposed free surface. *Radiation and convection are of
the same order for a mug*, and any treatment that ignores one of them is wrong
by a factor of two.

== Evaporation

The fourth channel is the one that dominates, and it is the only one that
transports mass as well as energy. Molecules escape the free surface; each takes
with it the *latent heat of vaporisation* $h_"fg"$, about
$2.31 times 10^6$#h(0.3em)$"J kg"^(-1)$ at #T(80). That is an extraordinary
quantity: evaporating a single gram of water removes as much energy as cooling
the entire #box[300#h(0.17em)ml] mug by nearly two kelvin.

The rate is set by how fast vapour can diffuse away from the surface, which is
driven by the difference between the vapour density at the surface --- saturated
at the tea's temperature --- and that in the room:
$
  dot(m) = h_m A_s (rho_(v,s)(T) - phi rho_(v,s)(T_a)), quad
  Q_"evap" = dot(m) h_"fg"(T),
$ <eq-evap>
where $phi$ is the relative humidity and $h_m$ a mass transfer coefficient in
$"m s"^(-1)$.

Two ingredients are needed. The first is the saturation vapour pressure, which
follows from the *Clausius--Clapeyron relation*
$
  dd(p_"sat") / dd(T) = (h_"fg" p_"sat") / (R_v T^2),
$ <eq-clausius>
whose approximate integral is exponential in $-1 slash T$. In practice one uses
an empirical fit; the Magnus form
$
  p_"sat"(T) = 610.94 exp( (17.625 T) / (T + 243.04) ) #h(0.3em) "Pa",
  quad T "in" upright("°C")
$ <eq-magnus>
is accurate to better than 0.4% up to about #T(60), drifting to roughly 1.3%
at #T(80) and 2.6% at the boiling point; it biases the evaporative term about a
percent high at drinking temperature. The saturated vapour density then follows
from the ideal gas law, $rho_(v,s) = p_"sat" M_w slash (R T)$.

@fig-psat shows why this term dominates. Saturation vapour pressure rises
_exponentially_ --- a doubling per #box[10#h(0.17em)K] near room temperature,
easing to about #r2(P.p-sat(90) / P.p-sat(80))#sym.times per
#box[10#h(0.17em)K] at drinking temperature --- from
#box[#r1(P.p-sat(20)/1000)#h(0.17em)kPa] at #T(20) to
#box[#r1(P.p-sat(60)/1000)#h(0.17em)kPa] at #T(60) and
#box[#r1(P.p-sat(85)/1000)#h(0.17em)kPa] at #T(85) --- a factor of
#r0(P.p-sat(85)/P.p-sat(20)) over the range. No other channel has anything like
this leverage. Conduction and convection scale as $Delta T$; radiation as
$T^4$, which over this range is a factor of about two; evaporation as
$e^(-h_"fg" slash R_v T)$, the factor of
#r0(P.p-sat(85) / P.p-sat(20)) just quoted.

#figure(
  plot(
    width: 280pt, height: 150pt,
    xlim: (0, 100), ylim: (0, 105),
    xticks: (0, 20, 40, 60, 80, 100),
    yticks: (0, 20, 40, 60, 80, 100),
    xlabel: [tea temperature (°C)],
    ylabel: [saturation vapour pressure (kPa)],
    series: (
      (data: range(0, 101, step: 2).map(t => (t, P.p-sat(t) / 1000)),),
    ),
    legend: none,
  ),
  caption: [
    Saturation vapour pressure of water, from the Magnus fit of @eq-magnus. The
    rise is exponential --- roughly a doubling per #box[10#h(0.17em)K] --- from
    #box[#r1(P.p-sat(20)/1000)#h(0.17em)kPa] at #T(20) through
    #box[#r1(P.p-sat(60)/1000)#h(0.17em)kPa] at #T(60) to
    #box[#r1(P.p-sat(85)/1000)#h(0.17em)kPa] at #T(85). This is the reason evaporation
    dominates the heat budget of an open mug at drinking temperature, and why it
    all but vanishes once the tea approaches room temperature.
  ],
) <fig-psat>

The second ingredient is $h_m$. Rather than solve a separate diffusion problem,
we use the *Chilton--Colburn analogy*, which relates mass transfer to heat
transfer for the same geometry and flow:
$
  h_m = h_c / (rho_"air" c_(p,"air") "Le"^(2 slash 3)),
$ <eq-chilton>
where $"Le" = alpha slash D approx 0.87$ is the Lewis number for water vapour in
air. The analogy holds because both processes are the same boundary-layer
transport problem with a different diffusivity. With
$h_c approx 5.5$#h(0.3em)$"W m"^(-2)"K"^(-1)$ this gives
$h_m approx 5 times 10^(-3)$#h(0.3em)$"m s"^(-1)$, and @eq-evap then yields
about #box[#r1(P.channels(MUG, 80, Ta, RH).evaporation)#h(0.17em)W] at #T(80).

Three consequences follow immediately, and they are the most practically useful
statements in this guide. *Evaporation is the largest single loss from an open
mug*, and it is largest exactly where it matters --- near boiling, where the
cooling is fastest and most of the heat is shed. *It is the only channel a lid can eliminate outright*, since a covered
headspace saturates within seconds and the driving difference collapses to
zero. And *it is strongly dependent on humidity and air movement*: the same mug
in a steamy kitchen loses noticeably less than in dry winter air, and a draught
that replaces the humid boundary layer raises $h_m$ in the same proportion as
$h_c$. This last
point is why blowing on tea works so well --- it is not mainly the extra
convection but the removal of the saturated layer sitting on the surface.

== The budget for a real mug

Assembling the four channels for the reference mug at #T(80) in a #T(20) room at
50% relative humidity gives @tbl-budget. The wall figures use the series
resistance of @eq-composite: inner film, ceramic, and outer film together put
the outside of the mug at #qty(r1(P.wall-temp(MUG, 80, Ta)), degC), which is why
a full mug is uncomfortable to hold.

#let ch80 = P.channels(MUG, 80.0, Ta, RH)
#let tot80 = P.total-loss(MUG, 80.0, Ta, RH)
#let row(name, key) = (
  name,
  qty(r1(ch80.at(key)), [W]),
  [#r0(100 * ch80.at(key) / tot80)%],
)

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, right, right),
    stroke: none,
    table.hline(stroke: 0.4pt),
    table.header([*channel*], [*heat flow*], [*share*]),
    table.hline(stroke: 0.4pt),
    ..row([evaporation from the free surface], "evaporation"),
    ..row([convection from the outer wall], "wall convection"),
    ..row([radiation from the outer wall], "wall radiation"),
    ..row([radiation from the free surface], "surface radiation"),
    ..row([convection from the free surface], "surface convection"),
    table.hline(stroke: 0.4pt),
    [*total*], [*#qty(r1(tot80), [W])*], [*100%*],
    table.hline(stroke: 0.4pt),
  ),
  caption: [
    Heat budget of the reference 300#h(0.17em)ml ceramic mug at #T(80) in a
    #T(20) room at 50% relative humidity. Evaporation alone carries about half
    the load; the two wall channels together carry most of the rest. The free
    surface is under a third the area of the wetted wall, yet it is responsible
    for #r0(100 * (ch80.evaporation + ch80.at("surface radiation") + ch80.at("surface convection")) / tot80)% of the loss.
  ],
  kind: table,
) <tbl-budget>

The total, #qty(r1(tot80), [W]), corresponds to an initial cooling rate of
$
  (dd(T)) / (dd(t)) = -Q / C_"tot"
  = -#r1(tot80) / #r0(P.heat-capacity(MUG))
  approx -#r2(tot80 / P.heat-capacity(MUG) * 60) #h(0.3em) "K min"^(-1),
$
which is the right order for a real mug: a freshly poured tea at #T(90) reaches
#T(75) in about ten minutes and #T(65) in about twenty.

@fig-channels shows how the budget shifts as the tea cools. The evaporative
curve falls away far more steeply than the others, following the exponential of
@eq-magnus, and by #T(40) it has almost vanished. The two wall channels, being
nearly linear in $T - T_a$, decline gently and overtake evaporation at about
#T(70) --- inside the drinking window --- after which they dominate.
This crossover has a practical corollary: *a lid is worth most in the first ten
minutes and progressively less thereafter*, whereas insulation on the sides
matters increasingly as the tea cools.

#figure(
  plot(
    width: 280pt, height: 165pt,
    xlim: (25, 95), ylim: (0, 55),
    xticks: (30, 40, 50, 60, 70, 80, 90),
    yticks: (0, 10, 20, 30, 40, 50),
    xlabel: [tea temperature (°C)],
    ylabel: [heat flow (W)],
    series: (
      (data: range(25, 96).map(t => (t, P.total-loss(MUG, t * 1.0, Ta, RH))),
       label: [total]),
      (data: range(25, 96).map(t => (t, P.channels(MUG, t * 1.0, Ta, RH).evaporation)),
       label: [evaporation]),
      (data: range(25, 96).map(t => {
         let c = P.channels(MUG, t * 1.0, Ta, RH)
         (t, c.at("wall convection") + c.at("wall radiation"))
       }),
       label: [wall, convection #sym.plus radiation]),
      (data: range(25, 96).map(t => {
         let c = P.channels(MUG, t * 1.0, Ta, RH)
         (t, c.at("surface radiation") + c.at("surface convection"))
       }),
       label: [free surface, non-evaporative]),
    ),
    legend: "nw",
  ),
  caption: [
    The heat budget of the open reference mug as a function of tea temperature,
    with the two wall channels and the two non-evaporative surface channels
    grouped; @tbl-budget gives the full five-way split. Evaporation is the
    largest term while the tea is hot and collapses fastest as it
    cools, because it inherits the exponential temperature dependence of the
    saturation vapour pressure. The wall terms are close to linear in
    $T - T_a$ and overtake evaporation below about #T(70) --- inside the
    drinking window, which is why insulation matters more as the tea ages and a
    lid matters more when it is fresh.
  ],
) <fig-channels>

= Solving the cooling equation

== Newton's law and the exponential

If every loss channel were linear in the temperature difference --- if we could
write $Q = U A (T - T_a)$ with $U A$ constant --- then @eq-budget would become
$
  C_"tot" dd(T) / dd(t) = -U A (T - T_a),
$ <eq-linear>
a first-order linear ordinary differential equation. Substituting
$theta = T - T_a$ turns it into $dot(theta) = -theta slash tau$, whose solution
is the celebrated exponential decay
$
  T(t) = T_a + (T_0 - T_a) e^(-t slash tau), quad
  tau = C_"tot" / (U A).
$ <eq-exponential>

The *time constant* $tau$ is the single most useful number in the subject. It
is the time to close $1 - e^(-1) approx 63%$ of the gap to room temperature, and
it depends on exactly the two things we can manipulate: the numerator, the
thermal capacity of everything hot, and the denominator, the conductance of the
envelope. Every intervention in Section 6 is an attempt to raise $tau$.

For our mug, using the secant conductance at #T(80),
$
  tau = (C_"tot" (T - T_a)) / Q = #r0(P.heat-capacity(MUG)) times #r0(80 - Ta)
  slash #r1(tot80) approx #r0(P.tau(MUG, 80.0, Ta, RH) / 60) #h(0.3em) "minutes".
$
A useful sanity check: after one time constant the model's tea has fallen from
#T(85) to #T(r1(P.cool(MUG, T0: 85.0, Ta: Ta, rh: RH, minutes: 41, every: 1).last().at(1))),
which is at the very bottom of drinkable. (The fitted exponential of
@eq-exponential would put it near #T(44); Section 5.2 explains the difference.)
The whole #T(65)--#T(50) window is spent inside the first
#r1((P.time-to(MUG, T0: 85.0, Tend: 50.0, Ta: Ta, rh: RH) - P.time-to(MUG, T0: 85.0, Tend: 65.0, Ta: Ta, rh: RH)) * 60 / P.tau(MUG, 85.0, Ta, RH))
time constants, so proportional changes in $tau$ translate directly into
drinking time.

== Why real tea does not cool exponentially

@eq-exponential is only an approximation, because $U A$ is not constant. Three
separate nonlinearities push in the same direction:

+ Radiation goes as $T^4 - T_a^4$, not $T - T_a$. Linearising gives
  $h_r prop T_m^3$, so the radiative conductance is larger when the tea is hot.
+ Natural convection has $h prop (Delta T)^(1 slash 4)$ from @eq-nusselt, so the
  convective term goes as $(Delta T)^(5 slash 4)$.
+ Evaporation is exponential in $T$ through @eq-magnus, which is far stronger
  than either of the above.

All three make the effective conductance *rise* with temperature. Equivalently,
the effective time constant *lengthens* as the tea cools: for our mug it is
#qty(r0(P.tau(MUG, 85.0, Ta, RH) / 60), [min]) at #T(85) but
#qty(r0(P.tau(MUG, 55.0, Ta, RH) / 60), [min]) at #T(55). There is no single
$tau$, and @eq-exponential is a fiction --- a useful one, but a fiction.

@fig-cooling shows what that costs. The dashed line is the exponential of
@eq-exponential using the time constant evaluated at the *initial* condition,
that is with the conductance the tea has when it is at its hottest. By
construction the two curves are tangent at $t = 0$; thereafter the real tea
cools progressively more slowly than the exponential predicts, because its
conductance is falling all the while, and the real curve pulls away upwards.
The gap reaches #qty(r1(exp-gap(30)), [K]) by half an hour and
#qty(r1(exp-gap(60)), [K]) by an hour. Fitting the exponential to the late behaviour
instead would reverse the error, badly under-predicting the first ten minutes.
Neither fit is right, because the curve is not an exponential.

The practical reading is encouraging rather than discouraging. Because the loss
is superlinear, *anything that keeps the tea slightly cooler early on saves a
disproportionate amount of heat later*. This is the mechanism behind the milk
result of Section 7, and it is why pouring water off the boil rather than at a
rolling boil costs less final temperature than one might fear.

#figure(
  plot(
    width: 280pt, height: 165pt,
    xlim: (0, 60), ylim: (35, 90),
    xticks: (0, 10, 20, 30, 40, 50, 60),
    yticks: (40, 50, 60, 70, 80, 90),
    xlabel: [time (minutes)],
    ylabel: [tea temperature (°C)],
    series: (
      (data: P.cool(MUG, T0: T0, Ta: Ta, rh: RH, minutes: 60),
       label: [full model, all four channels]),
      (data: range(0, 61).map(t => (t, Ta + (T0 - Ta) * calc.exp(-t * 60 / tau0))),
       label: [pure exponential, @eq-exponential]),
      (data: ((0, 65), (60, 65)),
       label: [drinking window], stroke: luma(50%), thickness: 0.5pt, dash: "dotted"),
      (data: ((0, 50), (60, 50)), stroke: luma(50%), thickness: 0.5pt, dash: "dotted"),
    ),
    legend: "ne",
  ),
  caption: [
    Cooling of the open reference mug from #T(85). The solid curve integrates
    @eq-budget with all four channels; the dashed curve is the pure exponential
    of @eq-exponential using the time constant evaluated at the initial
    condition ($tau = #r0(tau0 / 60)$#h(0.17em)min), so the two are tangent at
    the origin. Because radiation, convection and especially evaporation all
    weaken as the tea cools, its conductance falls, and the real curve pulls
    away above the exponential --- by #qty(r1(exp-gap(30)), [K]) at half an
    hour. The
    dotted lines mark the #T(65)--#T(50)
    drinking window, which this mug occupies for roughly
    #r0(P.time-to(MUG, T0: T0, Tend: 50.0, Ta: Ta, rh: RH) - P.time-to(MUG, T0: T0, Tend: 65.0, Ta: Ta, rh: RH))#h(0.17em)minutes.
  ],
) <fig-cooling>

= What actually works

We now have a calibrated model and can rank interventions rather than argue
about them. Throughout this section the baseline is the open reference mug
cooling from #T(85) in a #T(20) room, which spends
#r0(P.time-to(MUG, T0: 85.0, Tend: 50.0, Ta: Ta, rh: RH) - P.time-to(MUG, T0: 85.0, Tend: 65.0, Ta: Ta, rh: RH))#h(0.17em)minutes
in the drinking window and takes
#r0(P.time-to(MUG, T0: 85.0, Tend: 60.0, Ta: Ta, rh: RH))#h(0.17em)minutes to
fall from #T(85) to #T(60).

== Put something on top

This is the highest-value intervention available, and it is free. A lid does
three things at once. It stops the *export* of vapour: the headspace saturates
within seconds and the driving term $rho_(v,s)(T) - phi rho_(v,s)(T_a)$ in
@eq-evap collapses to zero. Latent transport does not stop entirely --- the
underside of the lid is cooler than the tea, so evaporation and condensation
shuttle heat onto it, which is part of why $U_"lid"$ is as large as it is ---
but that shuttle delivers heat to the lid rather than to the room. It replaces the free surface's convection and
radiation with conduction through a solid and a second, much weaker exchange
from the lid's outer face. And it suppresses the plume of warm humid air that
would otherwise rise from the surface and drive the whole circulation.

Modelling a lid as a barrier of overall coefficient
$U_"lid" approx 6$#h(0.3em)$"W m"^(-2)"K"^(-1)$ --- appropriate for a saucer or
a plastic travel-mug top --- cuts the total loss at #T(80) from
#qty(r1(tot80), [W]) to
#qty(r1(P.total-loss(MUG-LID, 80.0, Ta, RH)), [W]), a reduction of
#r0(100 * (1 - P.total-loss(MUG-LID, 80.0, Ta, RH) / tot80))%. The time to fall
from #T(85) to #T(60) rises from
#r0(P.time-to(MUG, T0: 85.0, Tend: 60.0, Ta: Ta, rh: RH)) to
#r0(P.time-to(MUG-LID, T0: 85.0, Tend: 60.0, Ta: Ta, rh: RH))#h(0.17em)minutes.

Note that a saucer laid on top of a mug is nearly as good as an engineered lid.
The gain comes overwhelmingly from stopping evaporation, not from the lid's
insulating value, so a thin ceramic plate captures most of the benefit. It does
not need to seal; it needs only to stop bulk exchange of the humid layer with
the room.

== Preheat the vessel

The mug is cold when the tea arrives, and it must be warmed at the tea's
expense. This is not a rate effect but an instantaneous one, and it is
surprisingly large. Treating the pour as an adiabatic mixing problem,
$
  T_"final" = (C_"water" T_"pour" + C_"mug" T_"mug") / (C_"water" + C_"mug"),
$ <eq-preheat>
which for water poured at #T(95) into a #T(20) mug of
$C_"mug" = 240$#h(0.3em)$"J K"^(-1)$ gives
$
  T_"final" = (#r0(300e-6 * P.rho-water * P.c-water) times 95 + 240 times 20)
  / (#r0(300e-6 * P.rho-water * P.c-water) + 240)
  approx #r1(P.mix(95.0, 300e-6 * P.rho-water * P.c-water, 20.0, 240.0)) #h(0.17em) upright("°C").
$
The tea has lost
#qty(r1(95 - P.mix(95.0, 300e-6 * P.rho-water * P.c-water, 20.0, 240.0)), [K])
before you have touched it --- more than any other single effect in this guide,
and it happens in the first thirty seconds. Rinsing the mug with boiling water
first, then discarding it, recovers essentially all of it.

The effect scales with the ratio $C_"mug" slash C_"water"$, so it is worst for
exactly the vessels people prize: heavy stoneware, thick-walled travel mugs, and
cast-iron teapots. Cast iron has $c approx 460$#h(0.3em)$"J kg"^(-1)"K"^(-1)$,
so a 500#h(0.17em)g pot carries $C approx 230$#h(0.3em)$"J K"^(-1)$ and takes
about
#qty(r1(95 - P.mix(95.0, 500e-6 * P.rho-water * P.c-water, 20.0, 230.0)), [K])
off half a litre of freshly boiled water; a 2#h(0.17em)kg pot takes
#qty(r1(95 - P.mix(95.0, 500e-6 * P.rho-water * P.c-water, 20.0, 920.0)), [K]).

== Thermal mass, once you are warm

The same thermal mass that costs so much at pouring is an asset afterwards.
Once the vessel is at temperature it is part of the reservoir: $C_"tot"$ in
@eq-exponential includes it, and $tau$ is proportional to $C_"tot"$. Our mug's
240#h(0.3em)$"J K"^(-1)$ is #r0(100 * 240 / P.heat-capacity(MUG))% of the total
stored heat, which is a
#r0(100 * 240 / (300e-6 * P.rho-water * P.c-water))% *increase* in $tau$ over an
imaginary mass-less vessel of the same shape --- the share and the increase are
not the same number.

This resolves the apparent paradox of the heavy mug. *A heavy vessel is a
liability if you pour into it cold and an asset if you preheat it.* The
crossover is immediate: preheating converts a #qty(r1(95 - P.mix(95.0, 300e-6 * P.rho-water * P.c-water, 20.0, 240.0)), [K])
penalty into a #r0(100 * 240 / (300e-6 * P.rho-water * P.c-water))% bonus on
$tau$.

== Geometry: tall and narrow, and full

The time constant is $tau = C slash (U A)$, and for a fixed shape $C$ scales
with volume while $A$ scales with area. Hence
$
  tau prop V / A prop L,
$ <eq-scaling>
the characteristic linear dimension. This is conservative: @eq-nusselt also
gives $h prop L^(-1 slash 4)$, so for the convective part $tau prop L^(5 slash 4)$,
and only the radiative part is scale-free. *Bigger vessels cool more slowly*,
which is why a teapot outlasts a cup and why the last third of a mug goes cold
fastest.

Shape matters as much as size. For a cylinder of radius $r$ filled to depth $d$,
the free surface is $pi r^2$ and the wetted wall $2 pi r d$, so
$
  tau prop (pi r^2 d) / (h_s pi r^2 + h_w 2 pi r d)
  = (r d) / (h_s r + 2 h_w d).
$ <eq-cylinder>
Increasing $d$ at fixed $r$ --- filling the mug fuller --- increases $tau$
towards an asymptote; increasing $r$ at fixed volume makes things worse, because
the free surface grows as $r^2$ while the volume is fixed. A wide shallow bowl
is the worst possible tea vessel, and a tall narrow one the best. This is not a
small effect: @fig-geometry shows the time to fall from #T(85) to #T(60) as a
function of fill volume for two mug radii.

#let vols = range(60, 501, step: 20)
#figure(
  plot(
    width: 280pt, height: 160pt,
    xlim: (50, 500), ylim: (0, 55),
    xticks: (100, 200, 300, 400, 500),
    yticks: (0, 10, 20, 30, 40, 50),
    xlabel: [volume of tea (ml)],
    ylabel: [minutes from 85#box[°C] to 60#box[°C]],
    series: (
      (data: vols.map(v => (v, P.time-to(P.mug(volume: v * 1e-6, r: 0.030), T0: 85.0, Tend: 60.0, Ta: Ta, rh: RH))),
       label: [narrow mug, $r = 30$#h(0.17em)mm]),
      (data: vols.map(v => (v, P.time-to(P.mug(volume: v * 1e-6, r: 0.045), T0: 85.0, Tend: 60.0, Ta: Ta, rh: RH))),
       label: [wide mug, $r = 45$#h(0.17em)mm]),
    ),
    legend: "nw",
  ),
  caption: [
    Time for an open mug to fall from #T(85) to #T(60), against the volume of
    tea in it, for two mug radii and a fixed vessel heat capacity of
    240#h(0.3em)$"J K"^(-1)$. Both curves rise steeply at first and then
    flatten, as @eq-cylinder predicts once the wall term begins to dominate the
    free-surface term; neither is linear in volume. The narrow mug wins at every
    volume because its
    free surface --- the seat of the evaporative loss --- is smaller for the
    same amount of tea. A half-filled mug cools dramatically faster than a full
    one.
  ],
) <fig-geometry>

The operational advice is blunt: *fill the mug*, and prefer a narrow one. A
300#h(0.17em)ml mug filled to 150#h(0.17em)ml loses the drinking window in
roughly #r0(P.time-to(P.mug(volume: 150e-6), T0: 85.0, Tend: 60.0, Ta: Ta, rh: RH))
minutes instead of #r0(P.time-to(MUG, T0: 85.0, Tend: 60.0, Ta: Ta, rh: RH)).
If you want a second cup later, the physics says keep it in the pot, not in a
half-empty mug.

== Insulate the walls

The wall channels together account for
#r0(100 * (ch80.at("wall convection") + ch80.at("wall radiation")) / tot80)% of
the loss from an open mug, and essentially all of it once a lid is on. Attacking
them means adding resistance in series with the outside air film. From
@eq-composite, the existing area-specific resistance is dominated by that film:
$
  R''_"out" = 1 / (h_"conv" + h_r) approx 1 / (#r1(P.h-wall-free(75.0, Ta, P.liquid-depth(MUG))) + #r1(P.h-rad(75.0, Ta, 0.9)))
  approx #r2(1 / (P.h-wall-free(75.0, Ta, P.liquid-depth(MUG)) + P.h-rad(75.0, Ta, 0.9))) #h(0.3em) "m"^2"K W"^(-1),
$
against which the ceramic's #qty(r0(1000 * 0.005 / 1.5 * 1000) / 1000, [$"m"^2"K W"^(-1)$])
is negligible. A 10#h(0.17em)mm knitted wool cosy, with
$k approx 0.04$#h(0.3em)$"W m"^(-1)"K"^(-1)$, adds
$R'' = 0.010 slash 0.04 = 0.25$#h(0.3em)$"m"^2"K W"^(-1)$ --- roughly *four
times* the existing resistance, in series. That is the whole case for the tea
cosy, and it is a good one.

Combining a lid with a cosy takes the reference mug from
#r0(P.time-to(MUG, T0: 85.0, Tend: 60.0, Ta: Ta, rh: RH)) minutes to
#r0(P.time-to(MUG-COSY, T0: 85.0, Tend: 60.0, Ta: Ta, rh: RH)) minutes for the
same #T(85)--#T(60) fall, a factor of
#r1(P.time-to(MUG-COSY, T0: 85.0, Tend: 60.0, Ta: Ta, rh: RH) / P.time-to(MUG, T0: 85.0, Tend: 60.0, Ta: Ta, rh: RH)).
@fig-interventions collects the effect of each intervention on the cooling
curve.

#figure(
  plot(
    width: 280pt, height: 175pt,
    xlim: (0, 90), ylim: (35, 96),
    xticks: (0, 15, 30, 45, 60, 75, 90),
    yticks: (40, 50, 60, 70, 80, 90),
    xlabel: [time (minutes)],
    ylabel: [tea temperature (°C)],
    series: (
      (data: P.cool(MUG-COSY, T0: 95.0, Ta: Ta, rh: RH, minutes: 90),
       label: [preheated, lid and cosy]),
      (data: P.cool(MUG-LID, T0: 95.0, Ta: Ta, rh: RH, minutes: 90),
       label: [preheated, lid]),
      (data: P.cool(MUG, T0: 95.0, Ta: Ta, rh: RH, minutes: 90),
       label: [preheated, open]),
      (data: P.cool(MUG, T0: P.mix(95.0, 300e-6 * P.rho-water * P.c-water, 20.0, 240.0), Ta: Ta, rh: RH, minutes: 90),
       label: [cold mug, open]),
      (data: ((0, 65), (90, 65)), stroke: luma(50%), thickness: 0.5pt, dash: "dotted"),
      (data: ((0, 50), (90, 50)), stroke: luma(50%), thickness: 0.5pt, dash: "dotted"),
    ),
    legend: "sw",
  ),
  caption: [
    The interventions compared, all from water at #T(95) in a #T(20) room. The
    lowest curve shows the cost of pouring into a cold mug: it starts
    #qty(r1(95 - P.mix(95.0, 300e-6 * P.rho-water * P.c-water, 20.0, 240.0)), [K])
    below the preheated case and never recovers. The dotted lines mark the
    #T(65)--#T(50) drinking window. A lid alone roughly doubles the time spent
    in it; a lid plus a cosy multiplies it several-fold.
  ],
) <fig-interventions>

== The vacuum flask

A vacuum flask attacks all four channels simultaneously, and understanding how
is the best possible summary of this guide. The flask is a double-walled vessel
with the space between the walls evacuated to perhaps
$10^(-2)$#h(0.17em)Pa. That single measure removes conduction and convection
through the gap: with a mean free path far larger than the gap width there is no
continuum fluid left to transport heat, and the residual gas conduction is
proportional to pressure.

That leaves radiation, which does not care about vacuum. From @eq-stefan the
exchange between two closely spaced grey surfaces at $T_1$ and $T_2$ is
$
  Q = (sigma A (T_1^4 - T_2^4)) / (1 slash epsilon_1 + 1 slash epsilon_2 - 1),
$ <eq-twosurface>
so the flask's designers silver both facing surfaces. With
$epsilon_1 = epsilon_2 = 0.05$ the denominator is
$1 slash 0.05 + 1 slash 0.05 - 1 = 39$, cutting the radiative exchange by a
factor of nearly forty relative to two black surfaces. What remains leaks mainly
through the neck and the stopper, which is why flask design is largely a
question of making the neck long, narrow, and thin-walled.

The result is an overall coefficient of order
$U approx 0.8$#h(0.3em)$"W m"^(-2)"K"^(-1)$, against roughly
#r0(tot80 / (P.area-surface(MUG) + P.area-wall(MUG)) / 60)#h(0.3em)$"W m"^(-2)"K"^(-1)$
for our open mug --- a factor of about
#r0(tot80 / (P.area-surface(MUG) + P.area-wall(MUG)) / 60 / 0.8). The time
constant for a 500#h(0.17em)ml flask becomes
#qty(r0(P.tau(FLASK, 90.0, Ta, RH) / 3600), [hours]) rather than
#qty(r0(P.tau(MUG, 80.0, Ta, RH) / 60), [minutes]), and the flask holds
#T(r1(P.cool(FLASK, T0: 95.0, Ta: Ta, rh: RH, minutes: 720, dt: 60.0, every: 720).last().at(1)))
twelve hours after filling. @fig-flask shows the comparison on a scale where the
mug's entire history is a vertical line at the origin.

#figure(
  plot(
    width: 280pt, height: 155pt,
    xlim: (0, 12), ylim: (20, 114),
    xticks: (0, 2, 4, 6, 8, 10, 12),
    yticks: (20, 40, 60, 80, 100),
    xlabel: [time (hours)],
    ylabel: [temperature (°C)],
    series: (
      (data: P.cool(FLASK, T0: 95.0, Ta: Ta, rh: RH, minutes: 720, dt: 60.0, every: 6).map(p => (p.at(0) / 60, p.at(1))),
       label: [vacuum flask, 500#h(0.17em)ml]),
      (data: P.cool(MUG-COSY, T0: 95.0, Ta: Ta, rh: RH, minutes: 720, dt: 20.0, every: 9).map(p => (p.at(0) / 60, p.at(1))),
       label: [mug with lid and cosy]),
      (data: P.cool(MUG, T0: 95.0, Ta: Ta, rh: RH, minutes: 720, dt: 20.0, every: 9).map(p => (p.at(0) / 60, p.at(1))),
       label: [open mug]),
      (data: ((0, 65), (12, 65)), stroke: luma(50%), thickness: 0.5pt, dash: "dotted"),
      (data: ((0, 50), (12, 50)), stroke: luma(50%), thickness: 0.5pt, dash: "dotted"),
    ),
    legend: "ne",
  ),
  caption: [
    Twelve hours of cooling, on which the open mug's entire useful life is a
    near-vertical drop. The flask's advantage is not a better version of the
    mug's insulation but a different mechanism: with the gas removed, only
    radiation is left, and low-emissivity coatings suppress that by a further
    factor of forty.
  ],
) <fig-flask>

== Ambient conditions and draughts

Everything so far has assumed a still #T(20) room at 50% relative humidity.
Three ambient variables matter, in decreasing order.

*Air movement* is the largest. Natural convection gives coefficients of order
#qty(r1(P.h-plate(80.0, Ta, MUG.r)), [$"W m"^(-2)"K"^(-1)$]); forced convection
at even 1#h(0.3em)$"m s"^(-1)$ --- a gentle draught, an open window, a fan, a
passing colleague --- lifts it to perhaps
#qty(r0(13), [$"W m"^(-2)"K"^(-1)$]) by the flat-plate forced-convection
correlation, and raises the mass transfer coefficient of @eq-chilton in exactly
the same proportion. That is not a dramatic multiplier on its own, but it acts
on the largest term in the budget, so a draught still costs far more than the
equivalent drop in room temperature. *Move the mug away from the draught before you turn
up the heating.*

*Humidity* acts only on the evaporative term, through the $phi rho_(v,s)(T_a)$
subtraction in @eq-evap. At #T(20) that term is small compared with
$rho_(v,s)(#r0(80))$, so going from 30% to 70% relative humidity changes the
evaporative loss by only a few percent. Humidity matters much more for tea near
room temperature, and hardly at all for tea worth drinking.

*Room temperature* enters every channel through $T - T_a$, so it is the most
democratic variable, but the leverage is modest: the difference between a #T(18)
and a #T(23) room changes the initial driving difference by about 8%.

== Things that do not work

Several widely repeated pieces of advice are either negligible or backwards.

/ Stirring: Section 3 showed the tea is already well mixed by internal natural
  convection. Stirring adds no mixing benefit, and it disturbs the surface,
  briefly increasing the evaporative loss. Stirring cools tea, slightly. This is
  why blowing and stirring both work when you _want_ it cooler.
/ Mug colour: emissivity in the thermal infrared is near 0.9 for essentially all
  glazes and paints regardless of visible colour, so a black mug and a white mug
  radiate the same. Only bare polished metal is different.
/ Thicker ceramic: the wall resistance is a twentieth of the outside air film.
  Doubling the wall thickness changes the total by about two percent. What a
  thick mug does buy is thermal mass --- but only if you preheat it.
/ Wrapping the base: heat leaves through the sides and the top, in proportion to
  wetted area. A coaster is worth having on a stone worktop and worth little on
  wood.
/ Adding sugar or salt: two teaspoons of sugar in a #box[300#h(0.17em)ml] mug
  lower the specific heat capacity by about two percent, which lengthens the
  drinking window by well under a minute. Sweetening tea to keep it warm does
  not work.

= When to add the milk

This is the classic problem, and it has a genuinely non-obvious answer: *if you
are going to add cold milk, add it immediately*. Three separate effects all
point the same way.

Write $f = C_m slash (C_t + C_m)$ for the fraction of the final heat capacity
contributed by the milk, and let the milk be at $T_m$. Mixing gives
$T_"mix" = (1 - f) T_t + f T_m$.

*The linear argument.* Suppose for a moment that Newton's law held exactly with
the same time constant in both cases. Adding milk first and then cooling for
time $t$ gives
$
  T_A (t) = T_a + [(1 - f) T_0 + f T_m - T_a] e^(-t slash tau),
$
while cooling first and adding milk at the end gives
$
  T_B (t) = (1 - f) [T_a + (T_0 - T_a) e^(-t slash tau)] + f T_m.
$
Subtracting, almost everything cancels and we are left with
$
  T_A (t) - T_B (t) = f (T_m - T_a) (e^(-t slash tau) - 1).
$ <eq-milk>
Both factors on the right are negative for refrigerated milk, so the product is
positive: *milk-first is warmer*. Note what @eq-milk says. The advantage is
proportional to how far the milk is *below room temperature*, not below the tea.
Milk already at room temperature makes the two strategies identical in this
approximation --- the entire linear effect comes from the fact that cold milk,
added early, spends the intervening minutes being warmed by the room rather than
by your tea.

*The capacity argument.* Adding the milk early raises $C_"tot"$ for the whole
of the intervening period, and $tau prop C_"tot"$ from @eq-exponential. For
30#h(0.17em)ml of milk in 300#h(0.17em)ml of tea this is a
#r1(100 * C-milk / P.heat-capacity(MUG))% increase in the
time constant, applied exactly when it is most valuable.

*The nonlinear argument.* This is the strongest of the three. Section 5.2
established that the loss is superlinear in temperature --- dominated by an
evaporative term exponential in $T$. Adding milk first keeps the tea several
kelvin cooler throughout, and it is precisely in that range that the
exponential is steepest. The tea that was never as hot never paid the
evaporative premium.

@fig-milk shows all three effects together, computed from the full model.

#let MUG-MILK = P.mug(volume: 300e-6 + MILK-VOL)
#let TmilkA = P.mix(T0, P.heat-capacity(MUG), MILK-T, C-milk)
#figure(
  plot(
    width: 280pt, height: 160pt,
    xlim: (0, 30), ylim: (50, 82),
    xticks: (0, 5, 10, 15, 20, 25, 30),
    yticks: (50, 55, 60, 65, 70, 75, 80),
    xlabel: [minutes between pouring and drinking],
    ylabel: [temperature when drunk (°C)],
    series: (
      (data: P.cool(MUG-MILK, T0: TmilkA, Ta: Ta, rh: RH, minutes: 30, every: 3),
       label: [milk added immediately]),
      (data: P.cool(MUG, T0: T0, Ta: Ta, rh: RH, minutes: 30, every: 3)
        .map(p => (p.at(0), P.mix(p.at(1), P.heat-capacity(MUG), MILK-T, C-milk))),
       label: [milk added just before drinking]),
    ),
    legend: "ne",
  ),
  caption: [
    The milk question, for #qty(r0(MILK-VOL * 1e6), [ml]) of milk at
    #T(r0(MILK-T)) added to 300#h(0.17em)ml of tea at #T(r0(T0)). Adding the milk immediately wins at every
    delay, and the margin grows with the wait: about
    #qty(r1(P.cool(MUG-MILK, T0: TmilkA, Ta: Ta, rh: RH, minutes: 10, every: 60).last().at(1) - P.mix(P.cool(MUG, T0: T0, Ta: Ta, rh: RH, minutes: 10, every: 60).last().at(1), P.heat-capacity(MUG), MILK-T, C-milk)), [K])
    after ten minutes and
    #qty(r1(P.cool(MUG-MILK, T0: TmilkA, Ta: Ta, rh: RH, minutes: 30, every: 180).last().at(1) - P.mix(P.cool(MUG, T0: T0, Ta: Ta, rh: RH, minutes: 30, every: 180).last().at(1), P.heat-capacity(MUG), MILK-T, C-milk)), [K])
    after thirty. The margin is small in absolute terms; the point is that the
    sign is unambiguous and the intuition that "adding cold milk later keeps it
    hotter" is simply wrong.
  ],
) <fig-milk>

Two caveats keep this honest. First, the effect is a matter of one or two
kelvin, not ten --- it is real but it is not the dominant term, and anyone
choosing between milk-first and a lid should choose the lid. Second, the
argument assumes you know when you will drink. If the milk is there to make the
tea drinkable *now*, adding it last is the whole point, since it removes several
kelvin instantly.

= Pots, cosies, and serving strategy

A teapot is a better thermal object than a mug for the reason given by
@eq-scaling: at four times the volume it has only about 2.5 times the surface
area, so its time constant is roughly 1.6 times longer. It also usually has a
lid, which as Section 6.1 established is worth more than everything else
combined.

This suggests a serving strategy that follows directly from the physics. *Keep
the reserve in the pot, under a cosy, and pour small measures into a preheated
cup.* The pot's favourable volume-to-area ratio and its lid protect the bulk;
the cup is refreshed often enough that it never has time to go cold. The
opposite strategy --- pouring the whole pot into a large mug at the start --- is
the worst case: maximum surface area exposed for the longest time.

The one place a cosy disappoints is a pot that is mostly empty. @eq-cylinder
applies to pots as much as cups: a quarter-full teapot has nearly the full
wetted wall area at the bottom but a much reduced volume, and the cosy cannot
help with the free surface under the lid. A small pot fully used beats a large
pot quarter-used.

= Recommendations, in order of value

The model lets us rank interventions rather than argue about them. Two figures
of merit are reported in @tbl-ranking, because they answer different questions:
how long the tea stays warm enough to drink at all (the time to fall below
#T(50)), and how long it spends inside the #T(65)--#T(50) window.

#let t50(v, T0) = P.time-to(v, T0: T0, Tend: 50.0, Ta: Ta, rh: RH, max-min: 2000)
#let t65(v, T0) = P.time-to(v, T0: T0, Tend: 65.0, Ta: Ta, rh: RH, max-min: 2000)
#let Tcold = P.mix(95.0, 300e-6 * P.rho-water * P.c-water, 20.0, 240.0)
#let base = t50(MUG, Tcold)

#let rank(name, v, T0, note) = (
  name,
  qty(r0(t65(v, T0)), [min]),
  qty(r0(t50(v, T0)), [min]),
  [#r1(t50(v, T0) / base)#sym.times],
  qty(r0(t50(v, T0) - t65(v, T0)), [min]),
  note,
)

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, 1fr),
    align: (left, right, right, right, right, left),
    stroke: none,
    inset: (x: 3.5pt, y: 2.6pt),
    table.hline(stroke: 0.4pt),
    table.header(
      [*what you do*], [*drops\ below 65*], [*below\ 50*], [*gain*],
      [*window*], [*why*],
    ),
    table.hline(stroke: 0.4pt),
    ..rank([nothing (cold mug, no lid)], MUG, Tcold, [baseline]),
    ..rank([preheat the mug], MUG, 95.0, [starts #qty(r0(95 - Tcold), [K]) higher]),
    ..rank([lid, cold mug], MUG-LID, Tcold, [removes the evaporative channel]),
    ..rank([lid + preheat], MUG-LID, 95.0, [the two act independently]),
    ..rank([lid + preheat + cosy], MUG-COSY, 95.0, [adds 4#sym.times the wall resistance]),
    table.hline(stroke: 0.4pt),
  ),
  caption: [
    Interventions ranked for a 300#h(0.17em)ml mug filled from water at #T(95)
    in a still #T(20) room. Times are measured from the pour. A vacuum flask is
    omitted because it does not belong on this scale: it holds the tea *above*
    the window for many hours, which is a different objective.
  ],
  kind: table,
) <tbl-ranking>

The table contains one result worth pausing on. *Preheating does not lengthen
the drinking window at all* --- it is
#qty(r0(t50(MUG, Tcold) - t65(MUG, Tcold)), [min]) with a cold mug and
#qty(r0(t50(MUG, 95.0) - t65(MUG, 95.0)), [min]) with a preheated one. The
reason is exact within the model: once the tea has fallen to #T(65) it
has no memory of where it started, so the trajectory from #T(65) down to #T(50)
is identical in both cases. What preheating buys is
#qty(r0(t50(MUG, 95.0) - t50(MUG, Tcold)), [min]) of extra time *before* the
window, and a hotter cup throughout.

That is worth having for three reasons --- you may prefer tea above #T(65); you
may be about to add cold milk, which drops you into the window instantly; and
you may not intend to drink for ten minutes --- but it is a different benefit
from the one a lid provides. *A lid stretches the window; preheating shifts it.*
Only the lid and the cosy make the tea stay drinkable for longer.

Condensed to a rule that fits on a postcard:

+ *Put something on top of it.* A saucer will do. This is worth more than
  everything else put together, because it removes the single largest channel
  rather than merely impeding the others.
+ *Warm the vessel before you pour.* Thirty seconds of boiling water, discarded,
  buys #qty(r0(95 - Tcold), [K]) that no amount of insulation can recover later.
+ *Fill it, and prefer a tall narrow vessel.* Time constant scales with volume
  over area.
+ *Keep it out of draughts.* Air movement multiplies the dominant evaporative
  term directly.
+ *If you take cold milk, add it at the start.* Worth a kelvin or two, and free.
+ *Do not bother* changing the colour of the mug, thickening its walls, or
  stirring it.

#counter(heading).update(0)
#set heading(numbering: "A.1")

= Symbols

#figure(
  table(
    columns: (auto, 1fr, auto),
    align: (center, left, left),
    stroke: none,
    inset: (x: 4pt, y: 2.4pt),
    table.hline(stroke: 0.4pt),
    table.header([*symbol*], [*quantity*], [*unit*]),
    table.hline(stroke: 0.4pt),
    $A$, [area], [$"m"^2$],
    $c$, [specific heat capacity], [$"J kg"^(-1)"K"^(-1)$],
    $C$, [heat capacity of a body], [$"J K"^(-1)$],
    $g$, [gravitational acceleration], [$"m s"^(-2)$],
    $h$, [convective heat transfer coefficient], [$"W m"^(-2)"K"^(-1)$],
    $h_m$, [mass transfer coefficient], [$"m s"^(-1)$],
    $h_r$, [linearised radiative coefficient], [$"W m"^(-2)"K"^(-1)$],
    $h_"fg"$, [latent heat of vaporisation], [$"J kg"^(-1)$],
    $k$, [thermal conductivity], [$"W m"^(-1)"K"^(-1)$],
    $dot(m)$, [mass flow rate], [$"kg s"^(-1)$],
    $p_"sat"$, [saturation vapour pressure], [Pa],
    $Q$, [heat flow], [W],
    $R_"th"$, [thermal resistance], [$"K W"^(-1)$],
    $T$, [temperature of the tea], [$upright("°C")$ or K],
    $T_a$, [ambient temperature], [$upright("°C")$ or K],
    $U$, [overall heat transfer coefficient], [$"W m"^(-2)"K"^(-1)$],
    $alpha$, [thermal diffusivity], [$"m"^2"s"^(-1)$],
    $beta$, [coefficient of thermal expansion], [$"K"^(-1)$],
    $epsilon$, [emissivity], [--],
    $nu$, [kinematic viscosity], [$"m"^2"s"^(-1)$],
    $rho$, [density], [$"kg m"^(-3)$],
    $sigma$, [Stefan--Boltzmann constant], [$"W m"^(-2)"K"^(-4)$],
    $tau$, [time constant], [s],
    $phi$, [relative humidity], [--],
    [Bi], [Biot number], [--],
    [Le], [Lewis number], [--],
    [Nu], [Nusselt number], [--],
    [Ra], [Rayleigh number], [--],
    table.hline(stroke: 0.4pt),
  ),
  caption: [Symbols used in this guide.],
  kind: table,
) <tbl-symbols>

= Parameter values

The reference mug and the material properties used throughout are collected in
@tbl-params. Air properties are evaluated at a film temperature of about #T(40).

#figure(
  table(
    columns: (1fr, auto, auto),
    align: (left, right, left),
    stroke: none,
    inset: (x: 4pt, y: 2.4pt),
    table.hline(stroke: 0.4pt),
    table.header([*quantity*], [*value*], [*note*]),
    table.hline(stroke: 0.4pt),
    [tea volume], [300 ml], [reference mug],
    [inner radius $r$], [40 mm], [],
    [liquid depth], [#r0(P.liquid-depth(MUG) * 1000) mm], [derived],
    [free surface $A_s$], [#r1(P.area-surface(MUG) * 1e4) cm#super[2]], [derived],
    [wetted wall $A_w$], [#r0(P.area-wall(MUG) * 1e4) cm#super[2]], [derived],
    [wall thickness], [5 mm], [],
    [$c$ of water], [4180 J kg#super[--1] K#super[--1]], [],
    [$C$ of the mug body], [240 J K#super[--1]], [300 g stoneware],
    [$C$ total], [#r0(P.heat-capacity(MUG)) J K#super[--1]], [derived],
    [$k$ of stoneware], [1.5 W m#super[--1] K#super[--1]], [],
    [$epsilon$ of water], [0.95], [thermal infrared],
    [$epsilon$ of glaze], [0.90], [],
    [$sigma$], [5.670#sym.times#h(0.1em)10#super[--8] W m#super[--2] K#super[--4]], [],
    [$k$ of air], [0.028 W m#super[--1] K#super[--1]], [at #T(40)],
    [$nu$ of air], [1.82#sym.times#h(0.1em)10#super[--5] m#super[2] s#super[--1]], [at #T(40)],
    [$alpha$ of air], [2.60#sym.times#h(0.1em)10#super[--5] m#super[2] s#super[--1]], [at #T(40)],
    [Le#super[2/3]], [0.91], [water vapour in air],
    [ambient $T_a$], [#T(20)], [],
    [relative humidity $phi$], [50%], [],
    [$U$ of a lid], [6 W m#super[--2] K#super[--1]], [saucer or travel lid],
    [$R''$ of a cosy], [0.25 m#super[2] K W#super[--1]], [10 mm wool],
    [$U$ of a flask], [0.8 W m#super[--2] K#super[--1]], [500 ml, silvered],
    table.hline(stroke: 0.4pt),
  ),
  caption: [Parameters of the reference system.],
  kind: table,
) <tbl-params>

= The model, and what it gets wrong

Every number in this guide comes from integrating @eq-budget with the four
channels of Section 4, using RK4 at a ten-second step. The model is deliberately
simple, and it is worth being explicit about where it is approximate.

*One calibration constant.* The flat-plate correlation of @eq-nusselt describes
an exposed horizontal surface. The surface of a mug is recessed several
centimetres below the rim, which suppresses both the convective plume and the
escape of vapour. Rather than model the cavity, a single shielding factor of
0.55 multiplies the free-surface coefficient, chosen so that the predicted
initial cooling rate of #qty(r2(tot80 / P.heat-capacity(MUG) * 60), [$"K min"^(-1)$])
at #T(80) matches published measurements of ceramic mugs. This is the only
fitted parameter in the model, and it affects the absolute rate rather than the
relative ranking of interventions.

*The lumped approximation.* Section 3 argued that internal natural convection
homogenises the bulk. It does not homogenise the surface skin, which is
genuinely cooler than the bulk by a fraction of a kelvin, nor the vessel wall,
whose outer face lags the tea. The wall is handled with a steady-state series
resistance, which slightly overestimates the wall loss during the first minute
after pouring while the ceramic is still warming.

*Constant properties.* The specific heat of water, the emissivities, and the air
properties are held constant over the whole range. The first two vary by well
under a percent. The air properties are all taken at a film temperature of
#T(40), which is right in the middle of the range but wrong at both ends by a
few percent; because they enter the Nusselt correlation as
$k slash (nu alpha)^(1 slash 4)$, a nearly invariant group, the effect on $h$ is
under a percent, but the density enters the mass transfer coefficient directly,
so the evaporative term carries the same few percent.

*The saturation fit drifts at the top of the range.* @eq-magnus is within 0.4%
below #T(60) but about 1.3% high at #T(80) and 2.6% high at #T(100), so the
evaporative term is overstated by around a percent at pouring temperature.

*The recess factor is applied to radiation as well.* The 0.55 that suppresses
convection and vapour escape from the sunken free surface is also applied to its
radiation, on the grounds that a surface which cannot see the room cannot
radiate to it either --- what it sees instead is wall at nearly its own
temperature. A proper treatment would compute the view factor from the recess
depth, which changes as the mug empties.

*Mass loss is ignored in the capacity.* Evaporation removes about
#qty(r1(1000 * P.channels(MUG, 80.0, Ta, RH).evaporation / P.h-fg(80.0) * 600), [g])
in the first ten minutes, roughly #r1(100 * P.channels(MUG, 80.0, Ta, RH).evaporation / P.h-fg(80.0) * 600 / 0.3)% of
the mass. $C_"tot"$ is held fixed, which slightly underestimates the later
cooling rate.

*Radiative enclosure.* @eq-stefan assumes the mug is surrounded by a large
enclosure at $T_a$. A mug beside a cold window or a warm radiator exchanges with
those preferentially, and view factors would be needed to do it properly.

None of these changes the conclusions. The ordering in @tbl-ranking is
determined by which channel each intervention removes, and the evaporative
channel is large enough over the range where the tea sheds most of its heat
--- half the budget at #T(80) --- that no plausible refinement of these
approximations dethrones the lid.
