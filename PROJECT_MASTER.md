# MarketBliss — Project Master Plan

> Section-9 master plan template instantiated from `taxonomy_blueprint.md`. This document is the authoritative cross-functional plan; it is patched after every finalized run by `master-plan-patcher`.

---

## 0. Quick-reference

- **Project ID**: `marketbliss`
- **Domain**: `marketing`
- **Current phase**: Phase 0 — Foundation (scaffolding)
- **Build week (start)**: 2026-05-19
- **Build week (target v1.0)**: 2026-07-14 (8-week roadmap; see §11)
- **Stakeholders**: rob.hasselbach@gmail.com (operator / approver); ExecutiveSuite CMO (upstream); Hydra orchestrator (peer)
- **Master plan version**: 0.1.0 (scaffold)

---

## 1. Strategy, business context, and investment logic

**Outcome the platform exists to change**: convert ExecutiveSuite's strategic marketing directives into executed campaigns across six industries, without a human marketing org. Reduce campaign-brief-to-launch cycle time by ≥ 70% vs. manual baselines; preserve audit / governance posture equivalent to a regulated agency.

**Commercial logic**: enablement + leverage. Each MarketBliss-served campaign frees ExecutiveSuite + the human operator from repetitive operational marketing work. Direct cost: model spend per campaign. Indirect benefit: faster experimentation, broader industry coverage.

**Success metrics**:
- 5 Hydra squads discoverable and routable within 1 week of router-patch application.
- 1 end-to-end campaign brief (CSuiteDecisionPacket → DecisionRecord) round-trips cleanly through MarketBliss within 2 weeks.
- Brand-safety gate catches ≥ 95% of regulated-claim violations on synthetic test set within 4 weeks.

**Kill criteria**: if after 8 weeks the brand-safety gate's false-negative rate on regulated content > 10%, freeze the regulated profile until rebuilt.

---

## 2. User, market, workflow, and domain understanding

**Primary users**:
- The operator (single human) issuing campaign directives from Claude Code, Hydra CLI, or ExecutiveSuite.
- The strategic CMO agent in ExecutiveSuite issuing `CSuiteDecisionPacket` envelopes downstream.

**Domain**: enterprise marketing operations spanning B2B SaaS, DTC e-commerce, professional services, regulated (health/finance), creative-production (photo/video/film), and advertising/commercial. Workflow shape is consistent: research → strategy → creative → ops → measurement, with industry-specific gates and KPI targets.

---

## 3. Product scope, requirements, and prioritization

**In scope (v1, post Phase-J correction)**:
- 15 specialist agents (12 originals + 3 Phase J production-squad additions).
- 15 reusable skills (13 originals + 2 Phase J: production-planning, talent-ip-clearance).
- 9 slash-command entry points (8 originals + 1 Phase J: /production-brief).
- 5 pair-programmer team YAMLs (4 originals + 1 Phase J: production-team.yaml).
- 5 Hydra squad packs (4 originals + 1 Phase J: marketing-production).
- 6 industry profile YAMLs (all patched to add `default_squads` field).
- TheEights project registration + adapter stub.
- Hydra router-patch documentation (applied manually by operator).
- AGENTS.md + CLAUDE.md + this file + hooks.json + README.md.

**Out of scope (v1)** — explicitly deferred:
- External ad-platform integrations (Google Ads, Meta, GA4, HubSpot, Segment CDP).
- Live MCP daemon for MarketBliss (`mcp_servers/marketing/`) — claude-skill entrypoint covers v1.
- Eights-bridge daemon hookup (stub only).
- Full rubric library (gate IDs declared, rubric bodies in v2).
- UI / web console for campaign artifacts.

---

## 4. Experience design, content, and accessibility

Not user-facing (no end-user UI) in v1. Internal artifact shapes follow:
- `creative-brief-protocol` skill defines the canonical CreativeBrief markdown structure.
- Output markdown adheres to RFC 2119 normative language for `must` / `should` / `may` claims (inherited from pair-programmer convention).
- Asset accessibility (alt text, captions, contrast) is enforced downstream in Hydra's `creative` squad.

---

## 5. Domain model, data, analytics, and information lifecycle

**Core entities**:
- `Campaign` — `campaign_id`, `industry_profile`, `objective`, `budget`, `kpis`, `status`, `created_at`.
- `CreativeBrief` — see `creative-brief-protocol` skill schema.
- `MarketBrief` (MarketBliss extension) — research squad output: TAM/SAM/SOM, competitor map, persona summary, SEO landscape.
- `DecisionRecord` — immutable consensus artifact, signed by gatekeeper agent.
- `ExperimentDesign` — hypothesis, MDE, power, primary/guardrail metrics, attribution method.

**Lineage**: every artifact written to `output/` carries a header pointing to its parent `workflow_id` and `parent_id`, mirrored into TheEights episodic memory.

**Retention**: episodic memory unbounded by default; campaigns flagged `sensitive:yes` (regulated industries) follow the operator's data-retention rules in `progress/config.json`.

---

## 6. Architecture and technical strategy

- **Compute boundary**: MarketBliss agents run in-process inside Claude Code or any Hydra-spawned subprocess. No long-lived MarketBliss daemon in v1.
- **Cross-squad transport**: Hydra typed envelopes (`hydra_core/schemas.py`).
- **Persistence**: filesystem under `output/` + `progress/` (local); episodic / semantic memory in TheEights (sqlite + sqlite-vec + Kuzu graph at `~/.eights/`).
- **Orchestration**: Hydra supervisor graph routes `marketing-*` squads via deterministic-keyword pass; falls back to LLM classification.
- **Governance**: SSGM-style policy evaluation via `mcp__eights__eights_governance_policy_evaluate` on every evolution proposal.

---

## 7. Interfaces, contracts, and integration wiring

Inbound (squads accept):
- `Handoff`, `HITLRequest`, `CSuiteDecisionPacket`, `CreativeBrief`, `MarketBrief`.

Outbound (squads emit):
- `DecisionRecord`, `CreativeBrief` (refined), `ShotList`, `AssetJob`, `HITLRequest`.

Hydra MCP tools used: `mcp__hydra__*` for envelope dispatch.
TheEights MCP tools used: `mcp__eights__eights_memory_*`, `mcp__eights__eights_evolution_*`, `mcp__eights__eights_governance_*`, `mcp__eights__eights_audit_*`, `mcp__eights__eights_identity_*`.

---

## 8. Engineering implementation system and code quality

- All authored files are markdown / YAML / JSON / TypeScript stubs. No production code in v1.
- Frontmatter validation: AGENTS.md fields enforced via `mcp__pp_harness__agents_md_status`.
- Master-plan synchronization via `mcp__pp_harness__master_plan_status`.
- Style: no emojis in committed files unless the file explicitly says so (see `aesthetic-archetypes` skill).

---

## 9. Security, privacy, compliance, and trust

- **Regulated content gate**: HITL-required for all external publishes in `regulated-health-finance` profile.
- **PII**: persona embeddings store no raw PII — only behavioral and demographic abstractions.
- **Scopes**: TheEights envelopes carry explicit `scope` arrays; regulated campaigns escalate to `sensitive:yes`.
- **Supply-chain**: MarketBliss authors no executables; the eights-bridge stub TypeScript carries no runtime dependencies in v1.

---

## 10. Quality engineering and verification

Verification matrix (run before declaring v1 complete):

| # | Check | How |
|---|---|---|
| 1 | All 36+ files exist | `Glob` against the build manifest in `AGENTS.md` |
| 2 | Frontmatter parses | `mcp__pp_harness__agents_md_status` |
| 3 | Master plan present | `mcp__pp_harness__master_plan_status` |
| 4 | Squad discovery | `hydra:hydra-squads` lists the 5 `marketing-*` squads (incl. `marketing-production`) |
| 5 | Project registered with Eights | `mcp__eights__eights_evolution_list_resources` shows `marketbliss.*` |
| 6 | Round-trip CreativeBrief | `/campaign-brief` dry-run produces a valid envelope under `output/campaigns/<id>/brief.md` |
| 7 | CMO handoff | A test `CSuiteDecisionPacket` from ExecutiveSuite CMO results in a `DecisionRecord` written here |
| 8 | Production-brief round-trip | `/production-brief <campaign-id>` against an approved CreativeBrief produces `output/campaigns/<id>/production/{shot-list,schedule,budget,clearance}.md` and logs outbound `ShotList` + `AssetJob` envelopes to `progress/events.jsonl` |
| 9 | IP clearance gate | Synthetic brief referencing unlicensed music — `talent-ip-coordinator` must emit `HITLRequest` (subtype `ip_release_review`) and the team gate must verdict `hitl-required` |

---

## 11. Delivery, environments, release, and change management

8-week roadmap (mirrors the blueprint's Phase 0–4):

| Week(s) | Phase | Deliverables |
|---|---|---|
| 1 | Phase 0 — Foundation | This scaffold (contracts, agents, skills, commands, teams, squads, profiles, integrations). |
| 2 | Phase 1 — Read-only copilot | First end-to-end `MarketBrief` produced by research squad; no external writes. |
| 3–4 | Phase 2 — HITL-gated creative | Creative squad produces gated CreativeBriefs; brand-safety gate operational. |
| 5–6 | Phase 3 — Semi-autonomous ops | Ops squad produces budget + bid plans; no external API writes. |
| 7–8 | Phase 4 — External integrations (selected) | Wire 1–2 external connectors (e.g., GA4 read-only) behind HITL approvals. |

---

## 12. Observability, reliability, operations, and support

- **Audit stream**: `progress/events.jsonl` (append-only, RLM-pattern).
- **Run state**: `progress/pipeline-state.json` + `checkpoint.json` (compaction-safe generation counter).
- **Hooks**: `hooks.json` declares SessionStart / Pre-+PostToolUse / PreCompact / Stop. Each hook is a thin shell command that logs to `events.jsonl` and / or calls Eights MCP tools.
- **Failure mode**: any agent failure surfaces a `HITLRequest`. There is no auto-retry in v1.

---

## 13. Documentation, enablement, and knowledge management

- `README.md` — operator quickstart.
- `AGENTS.md` — cross-tool contract.
- `CLAUDE.md` — Claude shim.
- `PROJECT_MASTER.md` — this file.
- `taxonomy_blueprint.md` — adopted verbatim from pair-programmer; maps every section above to a 4.x taxonomy ID.
- `Enterprise Multi-Agent Marketing AI Platform Architecture ... .md` — original blueprint (kept for historical reference).

---

## 14. Team operating model, decision governance, and execution cadence

**Decision authority**:
- `marketing-supervisor` — orchestration, cross-squad arbitration.
- `campaign-strategist` + `brand-safety-compliance` — gatekeepers per their declared gates.
- ExecutiveSuite CMO — final escalation for strategy disputes.
- Human operator — final escalation for HITL gate refusals.

**Cadence**:
- Per-campaign: ad-hoc, triggered by `CSuiteDecisionPacket` or operator slash-command.
- Weekly: `/marketing-retro` summarizes the week's runs + outcomes.
- Quarterly: `/marketing-retro` extended scope for portfolio-level review.

---

## 15. AI and agentic system controls

- **Risk classification**: per EU AI Act Article 9, MarketBliss is **limited-risk** in B2B SaaS / DTC / ProServ / Creative-Production / Advertising profiles; **high-risk-adjacent** in Regulated profile (financial / medical claims).
- **Model cards**: each of the 15 agents declares its `model` + `maxTurns` + `skills` in frontmatter — that's the v1 model-card stand-in. Full model cards in v2.
- **HITL policy**: see `AGENTS.md` §7. Regulated profile always HITL on external publish.
- **Evaluation harness**: synthetic regulated-content test set is a v2 deliverable.

---

## 16. Deprecation, retirement, and lifecycle exit

- Any agent / skill / squad superseded by a new version is moved under `_archive/<date>/` with a tombstone record in `output/executive/board/sunset-<slug>-YYYY-MM-DD.md`.
- TheEights memory is **not** deleted on deprecation — retention follows the operator's retention policy.
- A full retirement (e.g., switching MarketBliss off entirely) would trigger `retirement-planner` per the pair-programmer taxonomy.

---

## Appendix A — File manifest

See `AGENTS.md` §3 for the canonical directory layout. The build manifest is the file list under `.claude/agents/`, `.claude/skills/`, `.claude/commands/`, `.claude/teams/`, `squads/`, `profiles/`, `integrations/`.

---

_Last patched: 2026-05-19 (scaffold). Next patch trigger: first finalized `/pp:run` against this project, or first material change to any section above._
