---
name: marketing-governance
description: "HITL gate catalog, audit-log shape, DecisionRecord schema, three-lines-of-defense mapping, v1 gate IDs (brand-consistency, regulated-claims-review, budget-cap, attribution-soundness, ip-clearance)."
user-invocable: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
---

# Marketing Governance Skill

Owned by `brand-safety-compliance` (1st line operator) and consumed by every agent that emits an artifact or makes a decision. Codifies the gate catalog, the immutable audit log, the `DecisionRecord` schema, and three-lines-of-defense responsibilities.

Every gate verdict writes to `progress/events.jsonl` (append-only). Every material decision writes a `DecisionRecord` to `output/campaigns/<id>/decisions/` (immutable consensus).

## 1. HITL Gate Catalog (v1)

| gate_id | Description | Trigger condition | Required approver role | Override authority |
|---|---|---|---|---|
| brand-consistency | Visual + voice + voice + voice fidelity to brand book | Every outbound asset | brand-safety-compliance + brand-narrative (lead) | CMO |
| regulated-claims-review | FDA/FTC/FCA/FINRA/GDPR rule check | Every external publish in regulated profiles | compliance-officer + legal counsel | Legal + CMO joint |
| budget-cap | Media spend cap enforcement | Proposed spend >= 1.05x approved cap | CMO + CFO | CFO |
| attribution-soundness | Pre-registration + method appropriateness | Every measurement claim in `DecisionRecord` | analytics-experimentation lead | CMO |
| ip-clearance | Talent / music / stock / location releases | Every asset handoff to Hydra creative | producer + legal | Legal |

### Gate Lifecycle
1. Gate request emitted by agent
2. Gate evaluator runs (automated checks + rubric)
3. Verdict produced: `pass` / `fail` / `hitl`
4. If `hitl`: `HITLRequest` envelope to required approver
5. Approver decision recorded
6. Verdict + decision appended to `progress/events.jsonl`
7. If `pass`: artifact is unblocked; sealed if applicable

### Override Rules
- Override of any gate requires named approver per "Override authority" column
- Override is logged as a `DecisionRecord` with rationale (free-text required)
- Override never silently passes — always `verdict: hitl, decision: override_pass, approver: <name>`

## 2. Audit-Log Shape (`progress/events.jsonl`)

Append-only JSONL. Every line is one event.

```json
{
  "ts": "2026-05-19T14:22:11Z",
  "workflow_id": "wf_abc123",
  "campaign_id": "c-2026Q3",
  "actor": "brand-safety-compliance",
  "event_type": "gate.verdict",
  "gate_id": "brand-consistency",
  "target_ref": "memref://output/campaigns/c-2026Q3/assets/hero-v3.png",
  "verdict": "pass",
  "severity": null,
  "evidence_refs": [
    "memref://progress/checks/brand-consistency-hero-v3.json"
  ],
  "approver": null,
  "decision_record_ref": null,
  "schema_version": "1.0"
}
```

### Event Types
- `gate.request` — agent requests gate evaluation
- `gate.verdict` — evaluator returns verdict
- `gate.override` — approver overrides verdict
- `hitl.requested` — escalation emitted
- `hitl.resolved` — approver responded
- `decision.recorded` — `DecisionRecord` written
- `artifact.sealed` — brief or asset sealed (no further edits)
- `evolution.proposed` — TheEights proposal opened

### Append-Only Invariant
- NEVER edit or delete an existing line
- Schema changes require migration script + new `schema_version`
- Operators verify integrity via hash chain over file (planned v2)

## 3. DecisionRecord Schema

Aligned with Hydra's `hydra_core/schemas.py` DecisionRecord.

```python
from datetime import datetime
from typing import Literal, Optional
from pydantic import BaseModel, Field

class DecisionRecord(BaseModel):
    """Immutable record of a consensus decision in MarketBliss."""

    record_id: str                                    # ULID
    workflow_id: str
    campaign_id: Optional[str]
    decision_type: Literal[
        "campaign_brief_approval",
        "media_plan_approval",
        "creative_signoff",
        "budget_reallocation",
        "gate_override",
        "experiment_decision",
        "lifecycle_program_change",
        "brand_evolution",
        "regulated_claim_approval",
        "ip_clearance_decision",
    ]
    summary: str                                      # one-sentence
    rationale: str                                    # 2-5 sentences
    decision: Literal["approve", "reject", "conditional", "defer"]
    conditions: Optional[list[str]]                   # if conditional
    inputs_refs: list[str]                            # MemoryRefs to inputs
    evidence_refs: list[str]                          # MemoryRefs to evidence
    participants: list[Participant]                   # agents + humans involved
    primary_owner: str                                # role / slug
    approvers: list[Approver]                         # who signed off
    dissents: list[Dissent]                           # recorded disagreements
    risk_class: Literal["low", "moderate", "high", "critical"]
    profile: str                                      # active industry profile
    related_gates: list[str]                          # gate_ids touched
    created_at: datetime
    schema_version: str = "1.0"

class Participant(BaseModel):
    role: str
    name_or_slug: str
    contribution: str

class Approver(BaseModel):
    role: str
    name: str
    decided_at: datetime
    decision: Literal["approve", "reject"]
    note: Optional[str]

class Dissent(BaseModel):
    role: str
    name: str
    position: str
    recorded_at: datetime
```

DecisionRecords are **immutable**. Updates require a new record that references the prior (`related_records: list[str]` in v2).

## 4. Three Lines of Defense (Marketing Adaptation)

| Line | Responsibility | MarketBliss roles |
|---|---|---|
| 1st (operational) | Make the decisions, run the campaigns, own the outcomes | campaign-strategist, media-buyer-bidder, lifecycle-crm, contextual-copywriter, brand-narrative, analytics-experimentation |
| 2nd (oversight + controls) | Define rules, monitor adherence, advise 1st line | brand-safety-compliance, memory-steward |
| 3rd (independent assurance) | Independent review, audit, board reporting | ExecutiveSuite CMO + human operator (Robert) + (in regulated profiles) external compliance |

### Boundary Rules
- 1st line cannot self-approve gates of its own work
- 2nd line cannot make 1st-line operational decisions (advisory + gating only)
- 3rd line reviews aggregated patterns, not individual artifacts
- Any 2nd-line escalation is mirrored to 3rd line within 24h

## 5. Gate-ID Reference (v1)

### `brand-consistency`
- **Owner**: brand-safety-compliance
- **Inputs**: artifact ref + brand book + active aesthetic archetype
- **Checks**: see `brand-safety` skill checklist (logo / color / typo / voice / imagery)
- **Failure modes**: archetype drift, voice off-tone, prohibited content present
- **HITL trigger**: severity >= medium; ALWAYS HITL in regulated profile

### `regulated-claims-review`
- **Owner**: brand-safety-compliance + external compliance counsel
- **Inputs**: artifact ref + jurisdiction + regulatory regime
- **Checks**: FDA/FTC/FCA/FINRA/GDPR rules per `brand-safety` skill
- **Failure modes**: drug claim drift, fair-balance missing, endorsement disclosure missing, consent flag missing
- **HITL trigger**: ALWAYS — no auto-pass for external publishes in regulated profiles

### `budget-cap`
- **Owner**: media-buyer-bidder + brand-safety-compliance
- **Inputs**: proposed spend + approved cap + pacing trajectory
- **Checks**: per `media-mix-modeling` budget-cap gate criteria
- **Failure modes**: cap exceeded, projected breach, reallocation > 25% mid-flight
- **HITL trigger**: >=5% breach, mid-flight reallocations >25%

### `attribution-soundness`
- **Owner**: analytics-experimentation + brand-safety-compliance
- **Inputs**: measurement claim + pre-registration + method declaration
- **Checks**: see `experimentation-design` pre-registration validator + `marketing-attribution` method-selection matrix
- **Failure modes**: missing MDE/power, post-hoc method change, attribution method mismatch with channel mix
- **HITL trigger**: any post-hoc analysis change, any cross-method aggregation

### `ip-clearance`
- **Owner**: producer (Hydra creative squad) + legal + brand-safety-compliance
- **Inputs**: asset + talent releases + music license + stock receipts + location releases
- **Checks**: every named or recognizable element traced to clearance evidence
- **Failure modes**: unreleased talent, unlicensed music, stock asset out of usage scope, location not cleared
- **HITL trigger**: ALWAYS for unreleased talent or unlicensed music; AUTO-PASS only with full evidence

## 6. Evolution & Drift Detection

Prompt / persona / rubric changes go through TheEights evolution flow (see AGENTS.md sec 8):

1. `eights.evolution.propose` — change captured with rationale
2. `eights.evolution.evaluate` — automated and/or HITL evaluation
3. `eights.evolution.commit` (auto for `low` risk) OR HITL queue
4. `eights.evolution.rollback` available within retention window

Marketing-relevant `critical` risk classes (always HITL):
- Brand voice rules (any change to tone, banned phrases, archetype)
- Regulated-claims rules (any change to FDA/FTC/FCA/FINRA logic)
- Gate definitions (this skill's gate catalog)
- HITL gate trigger thresholds

## 7. Operator Quickstart

```bash
# Tail the audit log
Get-Content progress\events.jsonl -Wait -Tail 20

# Review open HITL requests
hydra hitl list --workflow <wf_id>

# Approve a HITL request
hydra hitl approve <hitl_id> --note "<rationale>"

# View decisions for a campaign
ls output/campaigns/<id>/decisions/
```

## 8. Anti-patterns

- Verdicts without evidence_refs (un-auditable)
- Editing existing events.jsonl entries (breaks append-only)
- DecisionRecord without rationale (governance theater)
- Auto-pass on regulated profiles (compliance violation)
- Override without named approver (accountability gap)
- Gate evaluation by the same agent that produced the artifact (self-approval)

## References

- AGENTS.md sec 7 (gate definitions)
- AGENTS.md sec 8 (evolution flow)
- `brand-safety` (verdict schema, regulated rules)
- `experimentation-design` (attribution-soundness criteria)
- `media-mix-modeling` (budget-cap criteria)
- Hydra schemas: `C:\AiAppDeployments\Hydra\hydra_core\schemas.py`
