# MarketBliss <-> TheEights bridge

This directory is the **v1 stub** for MarketBliss's integration with
[TheEights](../../../TheEights/ARCHITECTURE.md) — the persistent memory,
governance, and self-evolution substrate shared across the AiAppDeployments
stack.

## What this is in v1

A skeleton. No runtime code. MarketBliss agents talk to TheEights **directly
through the `mcp__eights__*` MCP tools** exposed by the running daemon. The
TypeScript file in `src/index.ts` documents the v2 shape and exports a couple
of constants (project id, actor slugs) so other MarketBliss code can import
canonical values today.

## Register MarketBliss with TheEights (today)

From any Claude Code session in this repo, call the MCP tools in this order:

```text
# 1) Register the project
mcp__eights__eights_identity_register_project
  name="marketbliss"
  domain="marketing"
  scopes_default=["public","team:marketing","sensitive:no"]

# 2) Register each of the 12 actors (loop)
mcp__eights__eights_identity_register_actor
  name="<slug>" kind="agent" parent="marketbliss"
```

The 12 actor slugs are listed below and exported as `ACTOR_SLUGS` from
`src/index.ts`.

## What this becomes in v2

A real adapter that mirrors the existing TheEights bridges under
`C:\AiAppDeployments\TheEights\daemon\src\adapters\`:

- `pp-bridge.ts` (pair-programmer)
- `execsuite-bridge.ts` (ExecutiveSuite)
- `rlm-bridge.ts` (RLM-Creative siblings)

When v2 lands, this stub is moved/copied into
`C:\AiAppDeployments\TheEights\daemon\src\adapters\marketbliss-bridge.ts` and
this directory becomes a thin client wrapper.

## The 12 actor slugs and their domains

| Slug | Squad (domain) |
|---|---|
| `marketing-supervisor`        | (all) orchestrator |
| `market-intelligence`         | marketing-research |
| `audience-persona`            | marketing-research |
| `seo-analyst`                 | marketing-research |
| `campaign-strategist`         | marketing-strategy |
| `analytics-experimentation`   | marketing-strategy |
| `contextual-copywriter`       | marketing-creative |
| `brand-narrative`             | marketing-creative |
| `media-buyer-bidder`          | marketing-ops      |
| `lifecycle-crm`               | marketing-ops      |
| `brand-safety-compliance`     | (all — governance gate) |
| `memory-steward`              | (all — Eights bridge)  |

## Episodic-memory write patterns

When v2 wiring exists, the bridge writes an episodic memory whenever:

1. A `CreativeBrief`, `MarketBrief`, or `DecisionRecord` is sealed in
   `output/campaigns/<id>/`.
2. A run's KPI snapshot is finalized.
3. Any governance gate emits a verdict (`pass`, `fail`, `hitl-escalated`).

Default scope set is `["public","team:marketing","sensitive:no"]`. Runs that
load the `regulated-health-finance` profile upgrade to `sensitive:yes` and
add a `regulated:<industry-tag>` scope.

## Evolution-proposal patterns

| Resource kind | risk_class | evolution_policy |
|---|---|---|
| Docs prompts, example libraries          | low      | auto-commit  |
| Agent persona tweaks, channel-mix priors | medium   | hitl-only    |
| Judge rubrics, taxonomy mappings         | high     | hitl-only    |
| Brand-voice rules, regulated-claims rules, gate definitions | critical | hitl-only (never auto) |

The first three are mechanical; the **critical** tier maps to TheEights'
hard invariant on safety filters and policy resources (ARCHITECTURE.md §12).
