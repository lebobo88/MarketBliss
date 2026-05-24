---
description: "Marketing retrospective — each agent contributes a section"
argument-hint: "[--period weekly|quarterly] [--campaign <id>]"
model: sonnet
skills:
  - marketing-expertise
  - marketing-attribution
  - marketing-governance
  - experimentation-design
---

# Marketing Retrospective — MarketBliss

Run a structured retrospective across all 15 specialist agents. Each agent contributes a section on what happened, what worked, what didn't, and what to evolve.

**Scope**: $ARGUMENTS

## Retro Process

### 1. Parse Arguments
- `--period weekly` — last 7 days of `progress/events.jsonl`.
- `--period quarterly` (default) — last 90 days.
- `--campaign <id>` — scope to a single campaign-id under `output/campaigns/`.

### 2. Marketing-Supervisor Orchestration
- Mint `workflow_id` (format: `mb-retro-<YYYYMMDD>-<scope>`).
- Read episodic memory and `progress/events.jsonl` for the scoped window.
- Dispatch a section-write to each of the 15 agents.

### 3. Per-Agent Section Template
Each agent contributes a section with this shape:

```markdown
## <agent-slug>
### What we did
- 3-5 bullets, factual, with `MemoryRef` handles.

### Wins
- Outcomes that beat KPI targets.

### Misses
- KPI gaps + root cause hypothesis.

### Evolution proposal
- 0-2 proposals for prompt / persona / rubric change.
  Each becomes an `eights.evolution.propose` call (risk class noted).
```

### 4. Cross-Cutting Synthesis (marketing-supervisor)
After collecting all 12 sections, marketing-supervisor writes a synthesis section:
- **Top 3 wins** across the squads.
- **Top 3 misses** with shared root causes.
- **Decision log** — open items, who owns, by when.
- **Evolution queue** — list of proposals filed; flag any `critical` risk (brand voice, regulated-claims) for HITL.

### 5. Output
Write to:

```
output/executive/marketing/retro-<period>-YYYY-MM-DD.md
```

Per AGENTS.md §8, every retro produces episodic memory writes AND surfaces evolution proposals into TheEights queue.

## Example Invocations

```
/marketing-retro --period weekly
/marketing-retro --period quarterly
/marketing-retro --campaign acme-q3-demand-gen
```
