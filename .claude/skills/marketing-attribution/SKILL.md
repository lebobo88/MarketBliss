---
name: marketing-attribution
description: "Deterministic attribution toolkit — MMM, MTA, incrementality testing, method-selection matrix, formulas, decision tree, common pitfalls."
user-invocable: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
---

# Marketing Attribution Skill

Used by `analytics-experimentation` and `media-buyer-bidder` to quantify channel contribution to outcome. Three families: **MMM** (top-down, channel-level, long-horizon), **MTA** (bottom-up, touchpoint-level, short-horizon), **Incrementality** (causal, gold-standard, narrow).

Apply the Hardcoding Directive: every attribution claim in a `DecisionRecord` must cite method, time-window, data window, and confidence interval. No "the campaign drove $X" without method declared.

## 1. Marketing Mix Modeling (MMM)

### Purpose
Estimate channel-level contribution to a KPI (revenue, leads, brand search) over a multi-week / multi-quarter window. Robust to cookie deprecation, signal loss, walled-garden opacity.

### Model Structure

```
KPI_t = baseline_t
      + Sigma_c [ beta_c * Adstock(saturate(spend_c,t)) ]
      + Sigma_x [ gamma_x * control_x,t ]
      + epsilon_t
```

Components:

| Term | Meaning | Typical functional form |
|---|---|---|
| baseline_t | Trend + seasonality | Fourier seasonality + trend |
| Adstock(x) | Carryover / decay | Geometric: x_t + lambda * Adstock_{t-1}, lambda in [0,1] |
| saturate(x) | Diminishing returns | Hill: x^alpha / (k^alpha + x^alpha), or log(1+x) |
| beta_c | Channel coefficient | Estimated, must be >=0 (constrain) |
| control_x | Exogenous (price, promo, weather, holiday) | Linear |

### Estimation Choices

| Method | When |
|---|---|
| OLS with positivity constraints | Small data, fast prototyping |
| Ridge regression | Multicollinear channels (TV + OOH + YouTube) |
| Bayesian (PyMC-Marketing, Meridian, Robyn) | When priors are informative and uncertainty matters for budget decisions |

Bayesian is preferred for any budget decision >= $1M. Priors should come from prior MMM runs, meta-analysis, or experiment-calibrated benchmarks.

### Outputs MMM Must Produce

1. Channel decomposition: %-of-KPI from each channel + baseline
2. Saturation curves per channel (current spend vs saturation point)
3. mROI per channel at current spend (marginal $ in -> $ out)
4. Optimal reallocation given budget envelope
5. Confidence intervals (Bayesian credible intervals at 80% and 95%)

### MMM Pitfalls
- Insufficient variation in spend (channels at flat budgets are non-identifiable)
- Confounding by always-on baseline (must control for organic trend)
- Aggregation bias (national MMM blind to local mix)
- Stale priors (calibrate with recent geo-experiments)

## 2. Multi-Touch Attribution (MTA)

### Purpose
Allocate credit across digital touchpoints in a user's path-to-conversion. Operates on user-level event log.

### Rule-Based Models

| Model | Credit allocation | When sensible |
|---|---|---|
| First-touch | 100% to first touch | Brand discovery emphasis |
| Last-touch | 100% to last touch | Closing-channel emphasis (default in many ad platforms) |
| Linear | Equal split across N touches | Naive, but unbiased between channels |
| Time-decay | Weight = exp(-(T - t) / half_life) | Late-funnel-weighted |
| Position-based (U-shape) | 40% first + 40% last + 20% middle | Funnel-aware compromise |

### Data-Driven MTA

- **Shapley value**: cooperative game theory — credit_c = average marginal contribution of channel c across all subsets of channels. Theoretically correct, expensive (2^N coalitions; approximation via Monte Carlo sampling).
- **Markov chain**: model journeys as states; channel credit = removal effect (delta in conversion rate when channel is removed from graph).
- **Logistic / survival models**: estimate per-touch hazard rate.

### MTA Pitfalls
- Cookie / device fragmentation undercounts cross-device journeys
- Walled-garden self-reported conversions inflate own channel
- Selection bias: MTA only sees converters' paths
- Last non-direct override masks true direct-traffic value
- Cannot attribute offline / brand-driven lift (use MMM)

## 3. Incrementality Testing (Causal Gold Standard)

### Geo Holdouts (Geo-Lift)

- Randomize geographies (DMAs, ZIPs, postal codes) into test/control
- Run treatment in test markets; hold control dark
- Measure delta-KPI between matched test/control using synthetic-control or DiD
- Requires ~20-30 markets per arm for reasonable power
- Best for: TV, OOH, audio, broad social

### Ghost Ads / Public Service Ad (PSA) Holdouts

- Within paid social/programmatic, eligible users randomly assigned to control see PSA instead of ad
- Compare conversion rates between treatment and control
- Requires platform support (Meta Conversion Lift, Google Ads Conversion Lift, DV360)
- Best for: digital paid channels at scale

### Conversion Lift Tests
- Same as ghost ads but reported at the campaign level
- Power calculation: need MDE >= 5-10% typically; campaign duration 2-4 weeks minimum

### Incrementality Pitfalls
- Spillover (ads in test market reach control-market users)
- Novelty/Hawthorne effects in short tests
- Test-market selection bias (don't cherry-pick high-performing geos)
- Stopping rules: pre-register; never peek

## 4. Method-Selection Matrix

Rows: channel type. Columns: data-availability tier.

| Channel | Rich first-party data | Limited 1P, walled-garden | Offline / no tracking |
|---|---|---|---|
| Paid social | MTA + Ghost-Ad incrementality | Geo holdout | MMM only |
| Paid search | MTA (data-driven) + brand-search lift test | MTA rule-based | MMM |
| Display / programmatic | MTA + Ghost-Ad | Geo holdout | MMM |
| Email / SMS | MTA (direct attribution) | Hold-out cohorts | n/a |
| Influencer | UTM + promo-code + matched-market | Promo-code only | MMM |
| TV / OOH | Geo lift + MMM | Geo lift | MMM |
| Audio (podcast, radio) | Promo-code + geo lift | Promo-code | MMM |
| Organic / SEO | Last-non-direct MTA + brand search trend | MTA | n/a |
| PR / earned | MMM + brand search lift | MMM | MMM |

## 5. Decision Tree

```
Q1: Is the budget decision worth >= $250k or >= 5% of total media?
  YES -> Q2
  NO  -> Use platform-default MTA (last-touch / data-driven)
Q2: Is the channel digital with platform measurement?
  YES -> Q3
  NO  -> MMM (with geo-lift calibration if budget allows)
Q3: Can we run a holdout >= 2 weeks?
  YES -> Run incrementality test, calibrate MTA with result
  NO  -> Data-driven MTA + sensitivity check vs MMM
```

## 6. Reporting Standards

Every attribution claim in a MarketBliss artifact must include:

- Method tag: `mmm` | `mta_rule` | `mta_dd` | `incrementality_geo` | `incrementality_ghost`
- Window: e.g. "2025-W30 to 2025-W42"
- Confidence: e.g. "80% credible interval +/-12%"
- Calibration source: e.g. "calibrated by Q2 ghost-ad test (lift = 8.4%)"

## 7. Common Cross-Method Pitfalls

- **Attribution gaming**: changing attribution mid-campaign to favor a channel
- **Double-counting**: summing MTA channel credits + MMM channel contribution
- **Selection bias**: only modeling converters in MTA
- **Confounding**: not controlling for price, promo, weather, holiday in MMM
- **Stale models**: MMM trained on pre-iOS14 data applied to current paid social
- **Cherry-picking windows**: re-running analysis with different start dates

## References

- `audience-segmentation` (cohort definitions feed MTA)
- `media-mix-modeling` (downstream consumer of MMM output)
- `experimentation-design` (incrementality test design specifics)
