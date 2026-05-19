# MarketBliss

Enterprise multi-agent marketing platform. The **operational marketing organization** that sits beneath ExecutiveSuite's strategic CMO, orchestrated by Hydra, with persistent memory and evolution provided by TheEights, and downstream creative production delegated to RLM-CLI-Starter via Hydra's `creative` squad.

> Read `AGENTS.md` before doing anything else. `AGENTS.md` is the cross-tool behavioral contract.

---

## At a glance

- **15 specialist agents** organized into **5 Hydra squad packs** (`marketing-research`, `marketing-strategy`, `marketing-creative`, `marketing-production`, `marketing-ops`).
- **15 reusable skills** (brand positioning, attribution, segmentation, SEO, brand safety, lifecycle, experimentation, production planning, talent + IP clearance, etc.).
- **9 slash commands** (`/campaign-brief`, `/market-research`, `/media-plan`, `/brand-audit`, `/marketing-retro`, `/launch-playbook`, `/campaign-landing`, `/marketing-board`, `/production-brief`).
- **6 industry profiles** (B2B SaaS, DTC e-commerce, Professional Services, Regulated, Creative-Production, Advertising/Commercial).
- **TheEights integration** for episodic memory + persona / prompt / rubric evolution.
- **Hydra integration** as 5 sibling squad packs (router-patch doc included).
- **Asset generation delegated** to Hydra's existing `creative` squad (RLM-CLI-Starter) — MarketBliss owns production *planning* (shot lists, talent / IP, schedules, budgets) and hands off `ShotList` + `AssetJob` envelopes.

---

## Quickstart

### 1. Register MarketBliss with TheEights

```bash
# from a Claude Code session inside this directory
mcp__eights__eights_identity_register_project project_id=marketbliss domain=marketing scopes='["public","team:marketing","sensitive:no"]'
```

### 2. Apply the Hydra router patch

Open `integrations/hydra-router-patch.md` and follow the instructions to add the 4 new `marketing-*` keyword fingerprints to `C:\AiAppDeployments\Hydra\hydra_core\router.py:_KEYWORDS`.

Then verify discovery:

```bash
hydra squads | grep marketing-
```

You should see 4 lines (one per `marketing-*` squad).

### 3. Dry-run a campaign brief

```bash
# from anywhere with Hydra on the path
hydra run "Q3 demand-gen plan for a B2B SaaS observability product" --squad marketing-strategy

# or directly inside a Claude Code session in this project
/campaign-brief Q3 demand-gen plan for a B2B SaaS observability product --industry b2b-saas
```

Expect a `CreativeBrief` markdown to land under `output/campaigns/<id>/brief.md` and the corresponding `DecisionRecord` to be available via `mcp__eights__eights_audit_trace`.

### 4. ExecutiveSuite handoff

From an ExecutiveSuite session, ask the CMO to dispatch a `CSuiteDecisionPacket` to MarketBliss. MarketBliss accepts the envelope, runs through `marketing-supervisor`, and emits a `DecisionRecord` back to ExecutiveSuite via Hydra.

---

## Layout

See `AGENTS.md` §3 for the full directory map. Highlights:

```
.claude/
  agents/      # 12 specialist persona markdown files
  skills/      # 13 reusable skill bundles
  commands/    # 8 slash commands
  teams/       # 4 pair-programmer-style team YAMLs
squads/        # 4 Hydra squad packs
profiles/      # 6 industry profile YAMLs
integrations/  # eights-bridge stub + hydra-router-patch doc
output/        # all generated artifacts (mirrors RLM convention)
progress/      # run state, audit stream (RLM convention)
```

---

## Sibling systems

| Path | Role |
|---|---|
| `C:\AiAppDeployments\Hydra` | Orchestrator. Discovers MarketBliss squads. |
| `C:\AiAppDeployments\ExecutiveSuite` | Strategic CMO upstream. Issues `CSuiteDecisionPacket`. |
| `C:\AiAppDeployments\TheEights` | Memory + evolution substrate. |
| `C:\AiAppDeployments\pair-programmer` | Engineering harness. Source of agent / skill / team conventions. |
| `C:\AiAppDeployments\RLM-CLI-Starter` | Downstream creative-production delegate (via Hydra `creative` squad). |

---

## Roadmap

- **Week 1** — this scaffold (foundation).
- **Week 2** — first end-to-end `MarketBrief` from research squad.
- **Weeks 3–4** — HITL-gated creative squad operational.
- **Weeks 5–6** — semi-autonomous ops squad (budget + bid plans).
- **Weeks 7–8** — first 1–2 external integrations (read-only) behind HITL.

Full plan in `PROJECT_MASTER.md` §11.

---

## License & ownership

Internal AiAppDeployments project. Owner: rob.hasselbach@gmail.com.
