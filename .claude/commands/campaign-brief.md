---
description: "Produce a CreativeBrief envelope via marketing-supervisor + campaign-strategist"
argument-hint: "<project description> [--industry <profile>] [--type acquisition|retention|brand|launch]"
model: opus
skills:
  - creative-brief-protocol
  - marketing-expertise
  - marketing-business-context
  - campaign-playbook
---

# Campaign Brief — MarketBliss

Generate a canonical `CreativeBrief` envelope (per `creative-brief-protocol`) for a marketing campaign. The brief is the contract that downstream creative, ops, and lifecycle squads execute against.

**Project**: $ARGUMENTS

## Brief Generation Process

### 1. Parse Arguments
- Extract the project / campaign description (free text).
- `--industry <profile>` — one of `b2b-saas`, `dtc-ecommerce`, `professional-services`, `regulated-health-finance`, `creative-production`, `advertising-commercial`. If omitted, the `marketing-supervisor` infers from context.
- `--type` — campaign category, one of:
  - `acquisition` — net-new customer acquisition / demand-gen.
  - `retention` — lifecycle, winback, loyalty.
  - `brand` — awareness, narrative, positioning.
  - `launch` — product / feature / market launch.

### 2. Load Industry Profile
Marketing-supervisor reads `profiles/<industry>.yaml` to pull KPI targets, gate thresholds, HITL requirements, and channel constraints. All downstream agents inherit these.

### 3. Marketing-Supervisor Orchestration
Adopt the `marketing-supervisor` persona to:
- Mint a `workflow_id` (format: `mb-brief-<YYYYMMDD>-<slug>`).
- Decide which research signals are required (TAM, persona, SERP) and request them from `market-intelligence`, `audience-persona`, `seo-analyst` via `MARKET_BRIEF` envelopes.
- Hand the assembled `MarketBrief` to `campaign-strategist` for synthesis.

### 4. Campaign-Strategist Synthesis
Adopt the `campaign-strategist` persona to assemble the `CreativeBrief` envelope. Fields (per `creative-brief-protocol/SKILL.md`):

- `business_objective` — one sentence tied to a CMO-level OKR.
- `target_audience` — persona slug + JTBD + intent stage.
- `core_message` — single-sentence value prop.
- `proof_points` — 3-5 evidence items (data, customer quotes, third-party validation).
- `tone_and_voice` — brand voice descriptor + aesthetic-archetype suggestion.
- `channels` — primary + secondary, ranked.
- `kpis` — leading + lagging, with target ranges from profile.
- `constraints` — `budget_usd`, `risk_tolerance`, `priority`, `timeline_weeks`, regulated-claim flags.
- `governance_flags` — list of gates that MUST fire (`brand-consistency` always; `regulated-claims-review` in regulated profiles).
- `context_refs` — `MemoryRef` handles to any source research artifacts.

### 5. Brand-Safety Pre-Check
Run `brand-safety-compliance` against the draft brief. If `industry == regulated-health-finance`, raise an `HITLRequest` (subtype: `regulated_claim_review`) and do NOT seal the brief until human approval. Otherwise, attach the verdict to the brief.

### 6. Output
Write the brief to:

```
output/campaigns/<campaign-id>/brief.md
```

The file body is a fenced YAML block (the `CreativeBrief` envelope, machine-readable) followed by a human-readable narrative section per the `creative-brief-protocol` template.

Also write a `DecisionRecord` to `output/campaigns/<campaign-id>/decisions/brief-sealed.md` once the brief is approved. Per AGENTS.md §10 — never edit `brief.md` after it has been sealed.

## Output Schema (truncated)

```yaml
envelope: CreativeBrief
workflow_id: mb-brief-20260519-acme-q3
origin_squad: marketing-strategy
target_squad: marketing-creative
campaign_id: acme-q3-demand-gen
business_objective: "Drive 200 qualified demos for the observability product in Q3."
target_audience:
  persona: platform-engineer-mid-market
  jtbd: "Reduce MTTR for cloud-native services without ripping out current toolchain."
core_message: "Observability that ships in an afternoon, not a quarter."
constraints:
  budget_usd: 250000
  risk_tolerance: medium
  priority: P1
  timeline_weeks: 12
governance_flags: [brand-consistency, attribution-soundness]
context_refs:
  - kind: MarketBrief
    handle: mem://marketbliss/market-brief/acme-q3-001
```

## Example Invocations

```
/campaign-brief Q3 demand-gen for cloud observability SaaS --industry b2b-saas --type acquisition
/campaign-brief Holiday winback for skincare DTC, 60-day window --industry dtc-ecommerce --type retention
/campaign-brief Brand repositioning for boutique wealth-management firm --industry regulated-health-finance --type brand
/campaign-brief Launch of GA release for AI compliance copilot --industry b2b-saas --type launch
```
