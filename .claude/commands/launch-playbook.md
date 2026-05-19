---
description: "Full launch lifecycle — research → strategy → creative → ops via Hydra"
argument-hint: "<launch description> [--industry <profile>] [--budget <usd>] [--timeline weeks]"
model: opus
skills:
  - campaign-playbook
  - creative-brief-protocol
  - marketing-expertise
  - marketing-business-context
  - media-mix-modeling
  - experimentation-design
---

# Launch Playbook — MarketBliss

Run the full MarketBliss lifecycle for a product / feature / market launch: research → strategy → creative → ops. Dispatched as a Hydra campaign across all 4 squads in sequence with explicit handoffs.

**Launch**: $ARGUMENTS

## Lifecycle Process

### 1. Parse Arguments
- Extract the launch description (free text).
- `--industry <profile>` — one of the 6 industry profiles.
- `--budget <usd>` — total launch budget. Passed downstream to `media-plan`.
- `--timeline weeks` — total weeks from kickoff to launch day. Drives pacing.

### 2. Marketing-Supervisor Orchestration
- Mint a campaign-id (`mb-launch-<YYYYMMDD>-<slug>`).
- Load `profiles/<industry>.yaml` once and cascade.
- Open `progress/pipeline-state.json` and create a 4-stage state machine: `research → strategy → creative → ops`.

### 3. Stage 1 — Research (marketing-research squad)
Sub-command: `/market-research <topic> --industry <profile> --depth standard`.
Outputs: `MarketBrief` envelope at `output/campaigns/<id>/research/market-brief.md`.
Gate: `attribution-soundness` (informational at this stage; sets baselines).

### 4. Stage 2 — Strategy (marketing-strategy squad)
Sub-command: `/campaign-brief <description> --industry <profile> --type launch`.
Inputs: `MarketBrief` from Stage 1.
Outputs: sealed `CreativeBrief` at `output/campaigns/<id>/brief.md`.
Gates: `brand-consistency`; `regulated-claims-review` (HITL if regulated profile).

### 5. Stage 3 — Creative (marketing-creative squad → hands off to Hydra `creative` squad)
- `contextual-copywriter` drafts launch copy variants (long-form announcement, short-form ads, landing-page sections, lifecycle email sequence).
- `brand-narrative` selects an aesthetic archetype and emits a `ShotList` envelope for any image / video assets, addressed to Hydra `creative` squad (NEVER generate binaries in MarketBliss — per AGENTS.md §10).
- `brand-safety-compliance` gates every outbound asset.
Outputs: `output/campaigns/<id>/assets/` with copy markdown + `ShotList` / `AssetJob` envelopes.
Gates: `brand-consistency`, `ip-clearance` (HITL when risk_tolerance == low).

### 6. Stage 4 — Ops (marketing-ops squad)
Sub-command: `/media-plan <campaign description> --budget <usd> --industry <profile>`.
- `media-buyer-bidder` produces channel mix + pacing keyed to the timeline.
- `lifecycle-crm` builds the post-launch nurture / onboarding cadence.
- `analytics-experimentation` registers the measurement plan and pre-registers hypotheses.
Outputs: `output/campaigns/<id>/measurement/media-plan.md` + `output/campaigns/<id>/lifecycle/post-launch-cadence.md`.
Gates: `budget-cap`, `attribution-soundness`.

### 7. Cross-Stage Synthesis
Marketing-supervisor writes a launch playbook summary at:

```
output/campaigns/<campaign-id>/launch-playbook.md
```

The summary indexes every artifact, lists open HITL escalations, and surfaces the full gate-verdict trail.

### 8. Episodic Memory + Evolution
Per AGENTS.md §8:
- Every stage transition writes an episodic-memory entry.
- The campaign KPI baselines are stored for later retro comparison.
- Any prompt / persona drift surfaced during stages becomes an `eights.evolution.propose` call.

### 9. HITL Gates
Surface HITL prompts inline at:
- End of Stage 2 if regulated-claims review pending.
- End of Stage 3 if any asset triggers IP-clearance escalation.
- End of Stage 4 if `proposed_spend > budget * 1.05`.

## Example Invocations

```
/launch-playbook Public GA of cloud observability product --industry b2b-saas --budget 750000 --timeline 12
/launch-playbook New skincare line for sensitive skin --industry dtc-ecommerce --budget 200000 --timeline 8
/launch-playbook Boutique wealth-management practice opening in Austin --industry regulated-health-finance --budget 400000 --timeline 16
```
