# CLAUDE.md — Claude Code shim for MarketBliss

This file is the Claude-Code-specific entry point. All shared behavioral contract lives in `AGENTS.md`. Do not duplicate content here — import it.

@AGENTS.md

---

## Claude-specific notes

- **Default model selection**: agents in `plugins/marketbliss/agents/*.md` carry their own `model:` frontmatter (opus for gatekeeper / orchestrator roles; sonnet for specialists; haiku for `memory-steward`). Honor it.
- **Skill invocation**: when a user types `/<skill-name>` (e.g. `/marketing-expertise`), invoke via the Skill tool. Don't guess skill names from training data — only invoke skills listed in `plugins/marketbliss/skills/` or surfaced in the system's available-skills reminder.
- **Sub-agent dispatch**: use the Agent tool with `subagent_type` matching the slug of one of the 15 MarketBliss agents (e.g. `subagent_type: campaign-strategist`). For multi-perspective synthesis, prefer the `marketing-supervisor` orchestrator over spawning parallel agents directly.
- **Hydra envelopes**: when sending a `CreativeBrief` / `ShotList` / `AssetJob` to Hydra's `creative` squad, use the Hydra MCP tools (`mcp__hydra__*`) — do not write the envelope directly into another project's directory.
- **Memory writes**: route all persistent memory through `mcp__eights__eights_memory_*` tools. Don't write campaign decisions to scratch files outside `output/`.
- **TodoWrite / TaskCreate**: prefer TaskCreate for multi-step work spanning ≥ 3 stages. Stage names should map to the 4 phases (research → strategy → creative → ops).

## When in doubt

Re-read `AGENTS.md` §10 ("What agents must NOT do") and `AGENTS.md` §7 ("Governance, HITL, and gates"). Those two sections define the hard constraints.
