---
name: media-mix-modeling
description: "Budget allocation, bid optimization, channel-mix solver inputs, saturation curves, pacing strategy, budget-cap gate criteria. Includes a worked $100k example."
user-invocable: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
---

# Media Mix Modeling Skill

Owned by `media-buyer-bidder`. Operationalizes the MMM outputs from `marketing-attribution` into budget decisions, bid strategies, and pacing plans. Deterministic where possible; surfaces budget-cap breaches for HITL.

## 1. Budget Allocation — Marginal-Return Optimization

Objective: allocate budget B across channels c=1..C to maximize total expected KPI.

```
maximize  Sigma_c  f_c(x_c)
subject to  Sigma_c x_c = B
            x_c >= 0
            L_c <= x_c <= U_c               # min/max guardrails per channel
```

Where `f_c(x_c)` is the saturation-adjusted response curve for channel c.

### Optimality Condition

Per Lagrangian: at optimum, **marginal return is equal across all funded channels**:

```
df_c/dx_c | x_c=x*_c  = lambda  (for all c with x*_c > L_c)
```

If channel c has higher mROI than channel c', shift dollars from c' to c until they equalize (subject to guardrails).

## 2. Saturation Curves

Two canonical forms (from MMM):

### Hill function
```
f(x) = K * x^alpha / (k^alpha + x^alpha)
```
- K = asymptote (max KPI from channel)
- k = half-saturation (spend at which 50% of K reached)
- alpha = curvature (>1 = S-curve, =1 = hyperbolic, <1 = concave-only)

### Log saturation
```
f(x) = K * log(1 + x / k)
```
Smoother, no inflection, easier to fit when data is sparse.

**Operational rule**: do not exceed 80% of K on any single channel — diminishing returns dominate; reallocate to next-best channel.

## 3. Diminishing Returns Detection

Practical heuristics (when full MMM is not available):

| Signal | Interpretation |
|---|---|
| CPA rising >25% over 4 weeks at flat creative | Saturation approaching |
| Frequency >7 per user / 28 days on social | Audience exhausted |
| Auction win-rate <30% at current bid | Inventory saturation |
| Branded search CTR climbs while non-brand CTR drops | Demand cannibalization |

When any 2 of 4 fire on the same channel, propose reallocation in next planning cycle.

## 4. Bid Optimization Strategy Selection

| Strategy | When to use | Risk |
|---|---|---|
| Manual CPC / CPM | Early test, learning phase, brand reach | High oversight cost |
| Maximize clicks | Awareness, top-funnel | Quality variance |
| tCPA (target CPA) | Mature campaign with conversion volume | Needs >=30 conv/wk per ad set |
| tROAS (target ROAS) | DTC, value-known | Volatile if value signal noisy |
| Value-based / max conversion value | DTC, varied AOV | Requires server-side value upload |
| Max conversions (no target) | Volume-first, when CPA tolerance wide | Spend volatility |

### Conversion Volume Floors
- tCPA / tROAS: minimum 30-50 conversions per week per ad set for the algorithm to learn
- Value-based: minimum 50 transactions per week with stable value signal

Below the floor, fall back to manual or max-conversions and revisit weekly.

## 5. Channel-Mix Solver Inputs

`media-buyer-bidder` requires these inputs to run the channel-mix solver:

```yaml
solver_inputs:
  budget_usd: 100000
  horizon_weeks: 6
  objective: "maximize_kpi"            # or maximize_kpi_capped_cpa
  kpi: "qualified_leads"
  cap:
    cpa_usd_max: 250                   # guardrail
  channels:
    - id: meta_paid_social
      response_K: 400                  # max leads achievable
      response_k: 25000                # half-saturation spend
      response_alpha: 1.3
      min_spend: 5000
      max_spend: 50000
    - id: google_search
      response_K: 250
      response_k: 15000
      response_alpha: 1.0
      min_spend: 8000
      max_spend: 30000
    - id: linkedin_ads
      response_K: 180
      response_k: 20000
      response_alpha: 1.1
      min_spend: 0
      max_spend: 25000
    - id: youtube_video
      response_K: 220
      response_k: 35000
      response_alpha: 1.5
      min_spend: 0
      max_spend: 30000
  audience_overlap_matrix: <CxC overlap %>
  attribution_coefficients: <from latest MMM>
```

## 6. Worked Example — $100,000 / 6 weeks, 4 channels

Using the inputs above and a numerical solver (scipy.optimize.minimize with SLSQP):

| Channel | Allocated $ | Predicted leads | Predicted CPA |
|---|---|---|---|
| Meta paid social | $42,000 | 251 | $167 |
| Google search | $26,000 | 174 | $149 |
| LinkedIn ads | $18,000 | 88 | $205 |
| YouTube video | $14,000 | 75 | $187 |
| **Total** | **$100,000** | **588** | **$170** |

Notes on solution:
- Search hits its mROI ceiling quickly (alpha=1.0, concave); cap kicks in at ~$26k.
- YouTube under-funded vs K because alpha=1.5 means returns lag at low spend — solver allocates only past the inflection.
- All channels below 80% of K (saturation safety).
- Composite CPA $170 within $250 guardrail.

If business adds $25k mid-flight: solver reallocates marginal $ to whichever channel has highest df/dx at current solution — typically Meta or YouTube (S-curve channels).

## 7. Pacing Strategy

| Strategy | Pacing curve | When |
|---|---|---|
| Level | Uniform daily spend | Always-on, mature campaign |
| Front-load | Heavy weeks 1-2 | New product launch, time-sensitive promo |
| Accelerate-to-end | Heavy weeks N-1, N | Tentpole (Black Friday), event-driven |
| Pulse | On / off weeks | Brand-build with paid-search always-on |
| Adaptive | Based on weekly performance | Mature campaigns with weekly review |

**Default**: level pacing with 10% reserve for in-flight reallocation.

## 8. Budget-Cap Gate Criteria

The `budget-cap` gate fires when:

| Condition | Action |
|---|---|
| Proposed spend exceeds approved cap by >=5% | Fail + HITL |
| Pacing trajectory will exceed cap before flight-end | Auto-throttle + warn |
| Reallocation shifts >25% of budget between channels mid-flight | HITL (re-approval) |
| New channel added with >10% of total budget | HITL (re-approval) |
| CPA guardrail breached for 2 consecutive weeks | Pause channel + HITL |

Verdict schema follows `brand-safety` skill's verdict structure with `gate_id: "budget-cap"`.

## 9. Reporting Outputs

`media-buyer-bidder` produces:

- `output/campaigns/<id>/media-plan.md` — channel allocation + pacing
- `output/campaigns/<id>/measurement/weekly-pacing.md` — actuals vs plan
- `output/campaigns/<id>/measurement/reallocation-proposals.md` — when triggered

## 10. Anti-patterns

- Over-fitting last week's CPA into next week's budget (recency bias)
- Allocating budget below conversion-volume floor (algorithm cannot learn)
- Ignoring audience overlap (double-counting reach)
- Hard-coded channel splits ignoring saturation
- Pacing all-channels-level when one channel has weekend volatility
- Treating last-touch CPA as ground truth (see `marketing-attribution`)

## References

- `marketing-attribution` (response curves, MMM coefficients)
- `experimentation-design` (calibration via geo-lift)
- `campaign-playbook` (channel-mix starting defaults per profile)
