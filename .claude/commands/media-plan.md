---
description: "Generate a media plan with budget allocation, bid strategy, and channel mix"
argument-hint: "<campaign description> --budget <usd> [--industry <profile>] [--channels paid_social,paid_search,display,...]"
model: sonnet
skills:
  - media-mix-modeling
  - marketing-attribution
  - experimentation-design
  - campaign-playbook
---

# Media Plan — MarketBliss

Run the `marketing-ops` squad to produce a `DecisionRecord` containing budget allocation, bid strategy, channel mix, and pacing for a campaign.

**Campaign**: $ARGUMENTS

## Plan Generation Process

### 1. Parse Arguments
- Extract the campaign description (free text).
- `--budget <usd>` — REQUIRED total media spend cap. Fails the `budget-cap` gate if downstream allocations exceed `budget × 1.05`.
- `--industry <profile>` — one of the 6 industry profiles.
- `--channels` — comma-separated allow-list. If omitted, all channels are eligible per profile. Valid values: `paid_social`, `paid_search`, `display`, `ctv`, `audio`, `affiliate`, `influencer`, `direct_mail`, `ooh`, `email`, `sms`, `push`.

### 2. Marketing-Supervisor Routing
- Mint `workflow_id` (format: `mb-mediaplan-<YYYYMMDD>-<slug>`).
- Dispatch parallel sub-jobs:
  - `media-buyer-bidder` → channel mix, budget split, bid strategy, pacing schedule.
  - `analytics-experimentation` → measurement plan, attribution method, holdout / lift-test design, MDE + power calc.

### 3. Media-Buyer-Bidder Output
- Channel allocation table: channel → % budget → $ → expected CPM / CPC / CPA.
- Bid strategy per channel (target CPA, max CPC, tROAS, etc.).
- Pacing schedule (week-by-week curve, front-load / even / back-load justification).
- Frequency caps.

### 4. Analytics-Experimentation Output
- Attribution method choice (MTA, MMM, geo-lift, conversion-lift) with justification.
- Holdout design (cell sizes, MDE, statistical power at α=0.05).
- KPI hierarchy: north-star → leading → lagging.
- Pre-registered hypotheses.

### 5. Gate: budget-cap
- If `sum(channel_allocations) > budget * 1.05` → FAIL the gate, surface the overage, and require either a budget increase or a rebalanced allocation.
- If `industry == regulated-health-finance` and channel mix includes `paid_search` or `paid_social` → require `brand-safety-compliance` HITL signoff on claim copy.

### 6. Output
Write to:

```
output/campaigns/<campaign-id>/measurement/media-plan-YYYY-MM-DD.md
```

Header is a `DecisionRecord` envelope; body is the human-readable plan with the two tables (allocation + measurement). Memory-steward writes the decision into episodic memory.

## Output Schema (truncated)

```yaml
envelope: DecisionRecord
workflow_id: mb-mediaplan-20260519-acme-q3
campaign_id: acme-q3-demand-gen
decision_kind: media_plan
budget_usd: 250000
allocations:
  - channel: paid_search
    pct: 35
    usd: 87500
    bid_strategy: target_cpa
    target_cpa_usd: 180
  - channel: paid_social
    pct: 25
    ...
measurement:
  primary_method: geo_lift
  mde_pct: 5
  power: 0.8
gates_passed: [budget-cap, attribution-soundness]
```

## Example Invocations

```
/media-plan Q3 demand-gen for cloud observability --budget 250000 --industry b2b-saas
/media-plan Holiday DTC push --budget 80000 --industry dtc-ecommerce --channels paid_social,paid_search,influencer
/media-plan Awareness flight for wealth management --budget 500000 --industry regulated-health-finance --channels display,ctv,audio
```
