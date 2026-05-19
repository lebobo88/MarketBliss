---
description: "Run brand-safety + brand-narrative audit over existing assets or a campaign"
argument-hint: "<asset path or campaign-id> [--industry <profile>]"
model: sonnet
skills:
  - brand-safety
  - marketing-governance
  - marketing-expertise
---

# Brand Audit — MarketBliss

Run the `brand-safety-compliance` (gatekeeper) and `brand-narrative` (advisory) agents over a single asset or an entire campaign to produce a pass / fail / HITL verdict.

**Subject**: $ARGUMENTS

## Audit Process

### 1. Parse Arguments
- The first positional argument is either:
  - A filesystem path (relative to `MarketBliss/` or absolute) — single-asset audit.
  - A `campaign-id` matching `output/campaigns/<campaign-id>/` — full-campaign audit (every asset under `assets/`).
- `--industry <profile>` — one of the 6 industry profiles. Determines which regulated-claims rule pack is applied.

### 2. Brand-Safety Pass
`brand-safety-compliance` runs each asset through the `brand-safety` rule pack:
- Toxicity / bias gate (per-asset score, threshold from profile).
- Regulated-claims gate (FDA / FTC / FCA / FINRA / GDPR rules — only when profile is `regulated-health-finance` or `professional-services`).
- Prohibited-content registry (brand-specific deny list).
- IP-clearance pre-check (talent releases, music licensing, stock-asset clearance).

### 3. Brand-Narrative Pass
`brand-narrative` advises on:
- Voice / tone consistency vs. brand voice samples in semantic memory.
- Aesthetic-archetype alignment (drift from the campaign's chosen archetype).
- Narrative coherence across the asset set.

### 4. Verdict Format

```yaml
envelope: DecisionRecord
workflow_id: mb-audit-20260519-<slug>
decision_kind: brand_audit
subject: <path or campaign-id>
verdict: pass | fail | hitl_required
per_asset:
  - asset: <path>
    brand_safety: { toxicity: 0.02, bias: 0.01, status: pass }
    regulated_claims: { violations: [], status: n/a | pass | fail }
    brand_narrative: { voice_match: 0.91, archetype_drift: low, status: pass }
    ip_clearance: { status: pass | hitl_required, notes: "..." }
findings:
  - severity: high | medium | low
    asset: <path>
    rule: <rule-id>
    summary: "..."
    remediation: "..."
hitl_subtype: regulated_claim_review | ip_release_review | high_risk_external_publish | null
```

### 5. HITL Escalation
Per AGENTS.md §7, raise an `HITLRequest` envelope if:
- Any regulated-claims violation in a regulated profile.
- Any IP-clearance status of `hitl_required`.
- Any toxicity / bias score above the profile's HITL threshold.

### 6. Output
Write to:

```
output/campaigns/<campaign-id>/decisions/brand-audit-YYYY-MM-DD.md
```
(or `output/governance/brand-audit-<asset-slug>-YYYY-MM-DD.md` for ad-hoc single-asset audits).

## Example Invocations

```
/brand-audit acme-q3-demand-gen --industry b2b-saas
/brand-audit output/campaigns/holiday-skincare-2026/assets/hero.md --industry dtc-ecommerce
/brand-audit wealth-mgmt-launch --industry regulated-health-finance
```
