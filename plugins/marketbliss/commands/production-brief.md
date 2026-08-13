---
description: "Convert an approved CreativeBrief into a production-ready ShotList + Schedule + Clearance package, then hand off to Hydra creative squad via ShotList + AssetJob envelopes."
argument-hint: "<campaign-id or brief path> [--industry <profile>] [--budget <usd>] [--shoot-window YYYY-MM-DD/YYYY-MM-DD]"
model: sonnet
skills:
  - creative-brief-protocol
  - production-planning
  - talent-ip-clearance
  - aesthetic-archetypes
---

# Production Brief — MarketBliss

Convert an approved `CreativeBrief` (per `creative-brief-protocol`) into a production-ready package: ShotList, Schedule, Budget, and Clearance verdict. Hand off to the Hydra `creative` squad via typed cross-squad envelopes (`ShotList` and `AssetJob`). This command is the bridge from sealed creative to executable production.

**Input**: $ARGUMENTS

## Process

1. Parse arguments and load the sealed `CreativeBrief`.
2. Dispatch to `shot-list-designer` to design the shot list against the locked aesthetic archetype.
3. Dispatch to `executive-producer` to build the production schedule and budget.
4. Dispatch to `talent-ip-coordinator` to clear all talent, music, stock, locations, and trademarks.
5. Emit `ShotList` and per-asset `AssetJob` envelopes to the Hydra `creative` squad and log a `DecisionRecord`.

## Step 1: Parse Arguments

- Required: `<campaign-id>` (kebab-case) or absolute path to `brief.md`.
- Optional: `--industry <profile>` — one of `b2b-saas`, `dtc-ecommerce`, `professional-services`, `regulated-health-finance`, `creative-production`, `advertising-commercial`. If omitted, inherited from the brief.
- Optional: `--budget <usd>` — override or confirm the production budget envelope.
- Optional: `--shoot-window YYYY-MM-DD/YYYY-MM-DD` — earliest / latest acceptable shoot dates.

Load and validate the brief: confirm it is sealed (per AGENTS.md §10), confirm aesthetic archetype is locked, confirm `brand-safety-compliance` and CMO approvals are present.

## Step 2: Shot-List Design

Adopt the `shot-list-designer` persona. Apply the Shot Coverage Adequacy decision framework:

- Parse the CreativeBrief's narrative, mood, key shots, and guardrails.
- Lock aesthetic archetype and translate to a lighting recipe.
- Design hero (1) + supporting (3-7) + detail/atmosphere (2-5) shots.
- Spec per-shot camera body class, lens, aperture, shutter, ISO, lighting, composition, mood, talent, props.
- Fill the coverage matrix (wide / med / close / detail / cutaway per scene).
- Flag IP and talent risk inline (any logo, identifiable property, named track, minor on camera).

Write to: `output/campaigns/<campaign-id>/production/shot-list.md`

## Step 3: Production Plan

Adopt the `executive-producer` persona. Apply the Production Viability Assessment decision framework:

- Score the locked shot list against scope, budget, timeline, vision alignment, risk.
- If score < 80, negotiate scope or schedule with the upstream `campaign-strategist`.
- If score >= 80, build the schedule (Pre-prod / Shoot / Post / Delivery) and the budget (15-line table + 10-15% contingency).
- Source crew: DP, gaffer, sound op, stylist, makeup, hair, wardrobe, PAs, talent agent. Confirm day-rate and book-by lead time.
- Scout or confirm locations; identify permits and lead time.

Write to:

- `output/campaigns/<campaign-id>/production/schedule.md`
- `output/campaigns/<campaign-id>/production/budget.md`
- `output/campaigns/<campaign-id>/production/crew.md`

## Step 4: Talent + IP Clearance

Adopt the `talent-ip-coordinator` persona. Apply the IP Risk Score decision framework:

- Walk every shot in the shot list against the clearance checklist (talent / music / stock / location / trademark / privacy).
- Source and queue releases per `talent-ip-clearance` §1 catalog.
- Validate music and stock licenses against the campaign's intended distribution scope.
- Confirm permits for any street, public-realm, school, hospital, or drone shoot.
- Emit the Pass / Fail / HITL verdict per `talent-ip-clearance` §8.
- If `hitl-required` or `fail`, emit an `HITLRequest` envelope (subtype `ip_release_review`) and DO NOT proceed to Step 5.

Write to:

- `output/campaigns/<campaign-id>/production/clearance.md`
- `output/campaigns/<campaign-id>/production/releases/` (per-asset signed releases)

## Step 5: Hydra Handoff

Only when clearance verdict is `pass`:

- Emit a `ShotList` envelope (per `hydra:cross-squad-message`) with `target_squad: creative`, carrying the locked aesthetic archetype, guardrails, and per-shot specs from Step 2.
- Emit one `AssetJob` envelope per requested asset / format / aspect-ratio variant.
- Log a `DecisionRecord` to `output/campaigns/<campaign-id>/decisions/production-handoff.md` referencing the workflow_id and envelope handles.
- Append an event to `progress/events.jsonl` with `event_type: production_brief_emitted`, `campaign_id`, `clearance_verdict`, `shot_count`, `budget_usd`.

## Output Package

```
output/campaigns/<campaign-id>/
  brief.md                          # sealed upstream input
  production/
    shot-list.md                    # per-shot spec
    schedule.md                     # phases + dates + owners
    budget.md                       # 15-line table + contingency
    crew.md                         # booked roster
    clearance.md                    # IP verdict + ledger
    releases/                       # signed PDFs
    call-sheets/<date>.md           # per shoot day
    dailies/<date>.md               # on-set log
  decisions/
    production-handoff.md           # DecisionRecord
```

## Example Invocations

```
/production-brief acme-dtc-spring-product --industry dtc-ecommerce --budget 85000 --shoot-window 2026-06-01/2026-06-14
/production-brief b2b-customer-story-q3 --industry b2b-saas --budget 45000 --shoot-window 2026-07-15/2026-07-22
/production-brief broadcast-spot-launch --industry advertising-commercial --budget 650000 --shoot-window 2026-09-08/2026-09-12
```
