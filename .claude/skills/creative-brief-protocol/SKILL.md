---
name: creative-brief-protocol
description: "Canonical CreativeBrief markdown + JSON schema, aligned 1:1 with Hydra CreativeBrief envelope. Sections cover vision, references, aesthetic, technical approach, key shots/messages, production, guardrails, approvals."
user-invocable: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
---

# Creative Brief Protocol Skill

Defines the canonical `CreativeBrief` markdown template used by `campaign-strategist`, `brand-narrative`, and `contextual-copywriter`. The markdown serializes into the typed `CreativeBrief` envelope defined in `<AIAPP_BASE>/Hydra/hydra_core/schemas.py` and is the artifact handed to Hydra's `creative` squad for asset production.

**Invariant**: every section below maps 1:1 to a field in the envelope. Adding sections requires an evolution proposal on the schema (`eights.evolution.propose`).

## 1. Canonical Markdown Template

```markdown
# CreativeBrief — <campaign_id>

## Overview
- **campaign_id**: <kebab-case unique id>
- **client**: <brand name>
- **brief_type**: production | media | hybrid
- **industry_profile**: b2b-saas | dtc-ecommerce | professional-services | regulated | creative-production | ad-commercial
- **date**: YYYY-MM-DD
- **location**: <city, country | virtual | n/a>
- **owner_agent**: campaign-strategist
- **upstream_envelope**: <handle to CSuiteDecisionPacket or MarketBrief>

## Creative Vision
- **Mood (3-5 adjectives)**: <e.g. refined, considered, present, quiet, intentional>
- **Concept (one sentence)**: <single-sentence creative concept>
- **Narrative (3-5 sentences)**:
  <free-text narrative that captures the story arc; must reference the target persona's JTBD and the brand archetype>

## Visual References
- **Reference 1**: <URL or memref to image>  — what we borrow: <what>
- **Reference 2**: <URL or memref to image>  — what we borrow: <what>
- **Reference 3-5**: ...

## Aesthetic Archetype
- **primary**: one of 5 (ethereal-glass | editorial-luxury | soft-structuralism | minimalist-editorial | industrial-brutalist)
- **accent** (optional): one of 5
- **surfaces**:
  - bg: "#RRGGBB"
  - fg: "#RRGGBB"
  - accent: "#RRGGBB"
- **typography**:
  - heading: "<font + weight>"
  - body: "<font + weight>"
  - mono: "<font + weight>"
- **motion**: { easing, duration_ms }
- **texture**: { type, opacity }
- **prompt_seed**: "<<=80 words, used by ComfyUI / gemini-image>"

## Technical Approach
For brief_type=production:
- **camera**: <body + recommended bodies>
- **lens**: <primary + alts>
- **lighting**: <natural / continuous / strobe; key+fill+rim>
- **color**: <LUT or grade direction; gamut>
- **post**: <retouch standard, grain, motion treatment>
- **deliverables_format**: <ratios, dpi, codecs>

For brief_type=media:
- **channels**: [channel + ad-unit pairs]
- **formats**: [aspect ratios, durations]
- **runtime_versions**: [count and purpose]
- **dynamic_creative**: <DCO yes/no + components>
- **tracking**: <UTM scheme, pixel/SDK requirements>

## Key Shots / Key Messages
For production briefs, numbered key shots (1-10 typical):
1. <shot description, role in narrative, must-have / nice-to-have>
2. ...

For media briefs, numbered key messages (3-7 typical):
1. <message, target persona, funnel stage>
2. ...

## Production Plan
- **timeline**: <pre-prod start -> shoot dates -> post -> delivery>
- **budget_usd**: <number, plus contingency %>
- **equipment**: <high-level list>
- **talent**: <number of subjects, roles, release status>
- **locations**: <named or scouted-by-date>
- **crew**: <roles + count>

## Must-Haves vs Nice-to-Haves
**Must-Haves**:
- <non-negotiable>
- <non-negotiable>

**Nice-to-Haves**:
- <stretch>
- <stretch>

## KPIs & Measurement Plan
- **primary KPI**: <metric + target>
- **secondary KPIs**: [<metric + target>, ...]
- **guardrail KPIs**: [<metric + threshold not to breach>]
- **measurement method**: <see marketing-attribution>
- **measurement window**: <start -> end>
- **review cadence**: <weekly / bi-weekly / monthly>

## Guardrails
- **brand-safety**: <see brand-safety skill; specific rules from prohibited-content registry>
- **ip-clearance**: <talent release status, music license, stock-asset license>
- **regulated-claims**: <MLR / legal review required? approver names?>
- **accessibility**: <WCAG AA targets, alt text, captioning>
- **prohibited content**: <profile-specific items>

## Approvals
| Role | Name | Status | Date |
|---|---|---|---|
| campaign-strategist | <name> | pending/approved | |
| brand-narrative | <name> | pending/approved | |
| brand-safety-compliance | <name> | pending/approved | |
| CMO (ExecutiveSuite) | <name> | pending/approved | |
| Client signoff | <name> | pending/approved | |
| MLR (regulated only) | <name> | pending/approved | |
```

## 2. JSON Envelope Shape

The markdown above serializes to a `CreativeBrief` envelope (Pydantic-style sketch):

```python
class CreativeBrief(BaseModel):
    workflow_id: str
    campaign_id: str
    client: str
    brief_type: Literal["production", "media", "hybrid"]
    industry_profile: IndustryProfile
    date: date
    location: Optional[str]
    owner_agent: str
    upstream_envelope_ref: Optional[MemoryRef]

    creative_vision: CreativeVision
    visual_references: list[VisualReference]
    aesthetic_archetype: AestheticArchetype           # see aesthetic-archetypes skill
    technical_approach: ProductionTech | MediaTech
    key_items: list[KeyShot] | list[KeyMessage]
    production_plan: ProductionPlan
    must_haves: list[str]
    nice_to_haves: list[str]
    kpis: KPISpec
    guardrails: Guardrails
    approvals: list[Approval]

    constraints: Constraints                         # budget_usd, risk_tolerance, priority
    context_refs: list[MemoryRef]                    # not blobs
```

The full Pydantic class lives in `<AIAPP_BASE>/Hydra/hydra_core/schemas.py`. Changes to either the markdown or the schema MUST update both in lockstep.

## 3. Brief-Type Decision Rule

| Situation | brief_type |
|---|---|
| MarketBliss asks Hydra `creative` for image/video assets | `production` |
| MarketBliss runs paid + lifecycle media against existing assets | `media` |
| Single campaign needs both (most common) | `hybrid` — produces two child envelopes |

## 4. Authoring Checklist

Before emitting a brief:

- [ ] Every section above is populated (no placeholder text)
- [ ] `aesthetic_archetype` selected per `aesthetic-archetypes` decision matrix
- [ ] At least 3 visual references for production briefs
- [ ] KPIs include primary + at least 1 guardrail
- [ ] Guardrails populated per active industry profile
- [ ] Approvals row exists for every required gatekeeper (per AGENTS.md sec 7)
- [ ] Constraints (budget_usd, risk_tolerance, priority) match upstream packet
- [ ] context_refs are MemoryRef handles, not embedded blobs

## 5. Asset Handoff to Hydra `creative`

When the brief is sealed and approved, MarketBliss derives child envelopes:

- **ShotList** (for production briefs): explicit shot-by-shot specification, one entry per `KeyShot`
- **AssetJob** (for media briefs): one job per ad unit / format / variant, with `dynamic_creative` component list

These envelopes carry the locked `aesthetic_archetype` and `guardrails` from the brief.

## 6. Sealed-Brief Rule

Per AGENTS.md sec 10: once `brand-safety-compliance` and CMO have approved a brief, the file in `output/campaigns/<id>/brief.md` is sealed. Subsequent changes require:

1. New `DecisionRecord` documenting the change rationale
2. Re-run of `brand-consistency` and `regulated-claims-review` gates
3. New brief version (`brief.v2.md`) — never overwrite v1

## 7. Anti-patterns

- Vague creative vision ("modern and bold") — must be specific enough that two creatives produce convergent work
- Missing aesthetic_archetype — downstream production becomes a guessing game
- KPIs without measurement method — attribution claims become un-falsifiable
- Guardrails copy-pasted between briefs without profile-specific tailoring
- Approvals table without dates / names — audit trail breaks

## References

- `aesthetic-archetypes` (aesthetic spec)
- `brand-safety` (Guardrails)
- `marketing-attribution` (KPI measurement method)
- `marketing-governance` (Approval gate definitions)
- Hydra envelope: `<AIAPP_BASE>/Hydra/hydra_core/schemas.py`
