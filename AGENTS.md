# MarketBliss — Cross-Tool Behavioral Contract

This file is the cross-tool behavioral contract for every AI agent (Claude Code, Codex, Gemini, Cursor, Copilot, Hydra squad runners, ExecutiveSuite orchestrators) that opens a session inside `C:\AiAppDeployments\MarketBliss\`. Read it before doing anything else.

> Sibling tool-specific shims (e.g. `CLAUDE.md`) import this file with `@AGENTS.md`. Change conventions here, not there.

---

## 1. What MarketBliss is

MarketBliss is the **operational marketing organization** for the AiAppDeployments stack. It is a multi-agent platform of 15 specialist agents organized into 5 Hydra squad packs (`marketing-research`, `marketing-strategy`, `marketing-creative`, `marketing-production`, `marketing-ops`) that turn strategic CMO directives into executed marketing work — research, strategy, briefs, copy, production planning, media plans, lifecycle programs, measurement, governance — across six industry profiles (B2B SaaS, DTC E-commerce, Professional Services, Regulated, Creative-Production, Advertising/Commercial).

MarketBliss is **not**:

- The strategic CMO. That role lives in `C:\AiAppDeployments\ExecutiveSuite\.claude\agents\cmo.md`. MarketBliss receives `CSuiteDecisionPacket` / `CreativeBrief` envelopes from that CMO and emits `DecisionRecord` envelopes back.
- The creative-production studio. Image / video / cinematography asset **generation** is delegated to Hydra's existing `creative` squad (`C:\AiAppDeployments\Hydra\squads\creative\`) which fronts RLM-CLI-Starter (ComfyUI, gemini-image, frontend-design). MarketBliss's own `marketing-production` squad owns the production *planning* layer (shot lists, talent / IP releases, locations, schedules, budgets, post-production briefs) and hands the resulting `ShotList` + `AssetJob` envelope pair downstream to that Hydra squad.
- A pipeline runner. Hydra is the orchestrator. Pair-programmer is the code-quality harness. TheEights is the memory + evolution substrate.

---

## 2. Integration map

| System | Path | MarketBliss role |
|---|---|---|
| Hydra (orchestrator) | `C:\AiAppDeployments\Hydra\` | Squad-pack consumer — 5 `marketing-*` squads register here. |
| ExecutiveSuite (C-suite) | `C:\AiAppDeployments\ExecutiveSuite\` | Strategic CMO upstream; MarketBliss is the operational layer beneath it. |
| TheEights (memory + evolution) | `C:\AiAppDeployments\TheEights\` | All campaign decisions, briefs, KPI outcomes flow into episodic memory. Prompt / persona / rubric drift uses Eights' propose → evaluate → commit → rollback flow. |
| Pair-programmer (engineering harness) | `C:\AiAppDeployments\pair-programmer\` | Source of agent / skill / team / hooks conventions. Borrowed verbatim. |
| RLM-CLI-Starter (creative production) | `C:\AiAppDeployments\RLM-CLI-Starter\` | Downstream asset-production delegate via Hydra `creative` squad. Source of `marketing-expertise`, `aesthetic-archetypes`, `creative-brief-protocol`. |

Cross-squad communication uses the typed envelopes defined in `C:\AiAppDeployments\Hydra\hydra_core\schemas.py`:

- **Accept** (inbound): `Handoff`, `HITLRequest`, `CSuiteDecisionPacket`, `CreativeBrief`, `MarketBrief` (MarketBliss extension).
- **Emit** (outbound): `DecisionRecord` (immutable consensus), `CreativeBrief` (refined), `ShotList` / `AssetJob` (asset handoff to `creative` squad), `HITLRequest` (escalation).

---

## 3. Directory layout

```
.claude/
  agents/      15 specialist persona markdown files
  skills/      15 reusable skill bundles (SKILL.md per dir)
  commands/    9 slash-command entry points
  teams/       5 pair-programmer-style team YAMLs (stage / gate / generator / judge)
squads/        5 Hydra squad packs (one squad.yaml per dir)
profiles/      6 industry profile YAMLs
integrations/
  eights-bridge/     adapter stub for TheEights project registration + episodic-memory writes
  hydra-router-patch.md   instructions for adding 5 new keyword fingerprints to Hydra router
output/        all generated artifacts land here (mirrors RLM convention)
  executive/marketing|creative|board/
  research/
  campaigns/<campaign-id>/{brief,strategy,assets,measurement}/
progress/      run-state files (pipeline-state.json, checkpoint.json, config.json, events.jsonl)
hooks.json     SessionStart / Pre + PostToolUse / PreCompact / Stop hooks
PROJECT_MASTER.md     Section-9 master plan, 16-section taxonomy coverage
taxonomy_blueprint.md   adopted verbatim from pair-programmer
AGENTS.md      this file
CLAUDE.md      @AGENTS.md import shim
README.md      operator quickstart
```

---

## 4. Agent roster

| Slug | Family | Authority | Model | Hydra squad | Purpose (one line) |
|---|---|---|---|---|---|
| `marketing-supervisor` | Orchestrator | gatekeeper | opus | (all) | Routes work across the 5 squads, synthesizes board-style multi-perspective recommendations. |
| `market-intelligence` | Research | advisory | sonnet | research | Competitive intel, TAM/SAM/SOM, market sizing, trend analysis. |
| `audience-persona` | Research | advisory | sonnet | research | Quantitative segmentation, JTBD, persona archetypes, intent mapping. |
| `seo-analyst` | Research | execute | sonnet | research | Pillar/cluster maps, SERP analysis, content-gap mapping, entity SEO. |
| `campaign-strategist` | Strategy | gatekeeper | opus | strategy | Integrated campaign briefs, hypotheses, KPIs, channel-mix decisions. |
| `analytics-experimentation` | Strategy | execute | sonnet | strategy | A/B/MAB design, MMM/MTA interpretation, causal inference, lift tests. |
| `contextual-copywriter` | Creative | execute | sonnet | creative | Long/short-form copy, multi-variant ads, narrative structures, DCO components. |
| `brand-narrative` | Creative | advisory | sonnet | creative | Brand voice, story arc, aesthetic-archetype selection, hands `ShotList` to Hydra `creative`. |
| `media-buyer-bidder` | Ops | execute | sonnet | ops | Budget allocation, bid optimization, channel mix, pacing across paid channels. |
| `lifecycle-crm` | Ops | execute | sonnet | ops | Onboarding / retention / winback / email-SMS-push cadence, segmentation activation. |
| `brand-safety-compliance` | Governance | gatekeeper | sonnet | (all — gate) | Brand-consistency + regulated-claims gate; HITL escalation. |
| `memory-steward` | Governance | advisory | haiku | (all — Eights bridge) | Episodic memory writes, evolution proposals, context packaging. |
| `executive-producer` | Production | execute | sonnet | production | Production planning, scheduling, budgeting, crew/vendor sourcing, on-set logistics, post oversight. |
| `shot-list-designer` | Production | execute | sonnet | production | Translates CreativeBrief + locked aesthetic into per-shot tech specs; emits `ShotList` envelope to Hydra `creative`. |
| `talent-ip-coordinator` | Production | gatekeeper | sonnet | production | Talent releases, music / stock licensing, location permits, chain-of-title; owns `ip-clearance` gate. |

Strict role boundaries: `gatekeeper` agents can block gates and require explicit approval to override; `advisory` agents never block; `execute` agents can call write-tier tools within their privilege scope.

---

## 5. Skill roster

Skills under `.claude/skills/<name>/SKILL.md`. User-invocable unless noted. Agents declare their skill set in frontmatter.

| Skill | Purpose |
|---|---|
| `marketing-expertise` | Brand Positioning Framework, E-E-A-T, 7Ps, funnel stages, pricing tiering, content taxonomy, luxury-brand principles. Cloned + reskinned from RLM-CLI-Starter. |
| `marketing-business-context` | Identity / services / segments / competitive positioning / strategic goals, parameterized by industry profile. Cloned from RLM `media-business`. |
| `aesthetic-archetypes` | 5 archetype bundles (Ethereal Glass / Editorial Luxury / Soft Structuralism / Minimalist Editorial / Industrial Brutalist) with surfaces / typography / motion / texture specs. |
| `marketing-attribution` | MMM, MTA, incrementality, lift tests, attribution-method selection. Deterministic formulas. |
| `audience-segmentation` | RFM, behavioral cohorts, JTBD framing, CDP/CRM integration patterns. |
| `semantic-seo` | Pillar / cluster maps, SERP analysis, entity SEO, content-gap mapping. |
| `brand-safety` | Toxicity / bias gates, regulated-claims rules (FDA / FTC / FCA), prohibited-content registry. |
| `campaign-playbook` | Funnel templates per industry profile (6 variants). |
| `creative-brief-protocol` | Canonical `CreativeBrief` schema. 1:1 alignment with Hydra `CreativeBrief` envelope. |
| `media-mix-modeling` | Budget allocation, bid optimization, channel-mix solver inputs. |
| `lifecycle-marketing` | Onboarding / retention / winback playbooks, cadence rules. |
| `experimentation-design` | A/B/MAB design, MDE / power, causal inference patterns. |
| `marketing-governance` | HITL gate definitions, audit-log shape, `DecisionRecord` schema. |
| `production-planning` | Shoot-day checklists, equipment manifests, timeline / budget templates, contingency planning, crew sourcing patterns, on-set heuristics. |
| `talent-ip-clearance` | Release templates, music / stock licensing tiers, FTC §255 + ASA + ASCI disclosure rules, GDPR / COPPA likeness, chain-of-title, per-geography permits. |

---

## 6. Engineering standards

- **Authoring**: all agent / skill / command files are markdown with YAML frontmatter. Frontmatter fields: `name`, `description`, `model`, `maxTurns` (agents only), `skills` (list), `allowed-tools` (skills only), `user-invocable` (skills only).
- **Naming**: kebab-case slugs everywhere. Agent slugs match filenames without `.md`. Squad slugs match directory names.
- **Outputs**: every artifact written to `output/<domain>/<topic>-YYYY-MM-DD.md`. Campaign artifacts to `output/campaigns/<campaign-id>/<kind>.md`.
- **State**: pipeline / checkpoint / config writes go to `progress/`. Append-only audit stream is `progress/events.jsonl`. Never overwrite events.jsonl.
- **Envelopes**: every cross-squad message carries `workflow_id`, `origin_squad`, `target_squad`, `constraints` (budget_usd, risk_tolerance, priority), `context_refs` (memory handles, never blobs).
- **Memory**: large artifacts live in `output/` and are referenced by `MemoryRef` handles. Do not paste full briefs / specs into envelopes.
- **Industry profile**: loaded once per run by `marketing-supervisor` from `profiles/<industry>.yaml`. All downstream agents read profile-derived KPI targets, gate thresholds, and HITL requirements from it.

---

## 7. Governance, HITL, and gates

Every squad declares `gates` in its `squad.yaml`. Gate rubrics live under future `rubrics/` directories (v2). v1 gate IDs:

- `brand-consistency` — applied by `brand-safety-compliance` on every outbound asset. HITL **required** when industry profile = regulated.
- `regulated-claims-review` — FDA / FTC / FCA / FINRA / GDPR rule check. HITL **required** for any external publish in regulated industries.
- `budget-cap` — fail if proposed media spend exceeds the campaign budget cap by ≥ 5%.
- `attribution-soundness` — fail if test design lacks declared MDE / power, or attribution method is unsuitable for the channel mix.
- `ip-clearance` — for asset handoff to Hydra `creative` squad: talent releases, music licensing, stock-asset clearance. HITL **required** for unreleased talent or unlicensed music.

HITL escalations use the standard `HITLRequest` envelope (subtype: `campaign_signoff`, `budget_approval`, `regulated_claim_review`, `ip_release_review`, `high_risk_external_publish`).

---

## 8. Memory & evolution (TheEights)

- **Project ID**: `marketbliss`. **Domain**: `marketing`. Default scopes: `["public", "team:marketing", "sensitive:no"]`. Regulated-industry runs upgrade to `sensitive:yes`.
- **Actors**: each of the 15 agent slugs registers as a distinct actor.
- **Episodic memory** writes:
  - Every CreativeBrief / MarketBrief / DecisionRecord written.
  - Every campaign KPI snapshot at run finalize.
  - Every governance-gate verdict (pass / fail / HITL-escalated).
- **Semantic memory** writes: persona embeddings, brand-voice samples, aesthetic-archetype assignments per campaign.
- **Evolution**: prompt / persona / rubric changes go through `eights.evolution.propose` → `evaluate` → `commit` (auto for low-risk) or HITL queue. Brand-voice and regulated-claims rules are `critical` risk class — always HITL.

The adapter under `integrations/eights-bridge/` is a stub in v1; daemon hookup is a v2 task. The MCP surface is already callable via `mcp__eights__*` tools.

---

## 9. Hydra wiring

Each of the 5 squad packs uses `entrypoint: claude-skill` and `source_pack: C:\AiAppDeployments\MarketBliss`, mirroring the existing `creative` squad pattern. Router keywords are documented in `integrations/hydra-router-patch.md` — the user applies the patch to `C:\AiAppDeployments\Hydra\hydra_core\router.py:_KEYWORDS`.

---

## 10. What agents must NOT do

- **Never** call external ad-platform APIs (Google Ads, Meta, GA4, HubSpot, Segment) — those tools are stubbed for v1. If you encounter a tool name you don't have, request escalation via `HITLRequest`.
- **Never** edit `output/campaigns/<id>/brief.md` after the brief gate has signed off. Approved briefs are sealed.
- **Never** post external comms in regulated profiles without `brand-safety-compliance` gate verdict = `pass` AND human approval.
- **Never** bypass the marketing-supervisor by calling other squads directly across the MarketBliss boundary — use Hydra envelopes.
- **Never** generate asset binaries in MarketBliss — emit a `ShotList` / `AssetJob` to Hydra `creative` squad instead.

---

## 11. Operator quickstart

```bash
# Discover squads after the Hydra router patch is applied
hydra squads | grep marketing-

# Run a campaign brief
hydra run "Q3 demand-gen plan for a B2B SaaS observability product" --squad marketing-strategy

# Direct command (Claude Code, in this project's cwd)
/campaign-brief Q3 demand-gen plan for a B2B SaaS observability product --industry b2b-saas

# Stress-test a regulated campaign
/brand-audit --industry regulated-health-finance --asset path/to/claim.md
```

Refer to `README.md` for the longer setup walkthrough.

---

## 12. Versioning

This contract is versioned in lockstep with `PROJECT_MASTER.md`. Material changes (new agent / squad / gate / envelope type / industry profile) require a `DecisionRecord` written to `output/executive/board/` and an evolution proposal via `eights.evolution.propose` against this file.
