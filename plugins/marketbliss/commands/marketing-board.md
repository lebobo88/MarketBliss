---
description: "Convene a marketing board meeting — marketing-supervisor + CMO + specialists"
argument-hint: "<topic> [--attendees comma,separated,slugs] [--format quick|full|strategic]"
model: opus
skills:
  - marketing-expertise
  - marketing-business-context
  - executive-protocol
---

# Marketing Board — MarketBliss

Convene a virtual marketing board on a topic. Attendees: `marketing-supervisor` (chair) + ExecutiveSuite `cmo` (strategic anchor) + selected MarketBliss specialists. Auto-routes attendees by topic.

**Agenda**: $ARGUMENTS

## Meeting Protocol

### 1. Parse Arguments
- Extract agenda topic (free text, first positional arg).
- `--attendees` — comma-separated MarketBliss agent slugs. Valid: `marketing-supervisor`, `market-intelligence`, `audience-persona`, `seo-analyst`, `campaign-strategist`, `analytics-experimentation`, `contextual-copywriter`, `brand-narrative`, `media-buyer-bidder`, `lifecycle-crm`, `brand-safety-compliance`, `memory-steward`. Also `cmo` (resolves to `<AIAPP_BASE>/ExecutiveSuite/.claude/agents/cmo.md`).
- `--format`:
  - `quick` — 3-5 sentences per perspective, single recommendation.
  - `full` (default) — comprehensive analysis, decision log, action items.
  - `strategic` — long-form, 12-week horizon, includes scenario branches.

### 2. Auto-Route Attendees (when `--attendees` omitted)
`marketing-supervisor` infers the right roster from topic keywords:

| Topic keywords | Required attendees |
|---|---|
| `budget`, `media spend`, `pacing`, `ROAS`, `CPA` | media-buyer-bidder, analytics-experimentation, cmo |
| `brand`, `positioning`, `voice`, `archetype` | brand-narrative, brand-safety-compliance, cmo |
| `audience`, `persona`, `segment`, `JTBD` | audience-persona, lifecycle-crm, market-intelligence |
| `SEO`, `content`, `SERP`, `keyword` | seo-analyst, contextual-copywriter |
| `experiment`, `A/B`, `MMM`, `MTA`, `lift` | analytics-experimentation, media-buyer-bidder |
| `compliance`, `regulated`, `FDA`, `FTC`, `claim` | brand-safety-compliance, campaign-strategist, cmo |
| `lifecycle`, `email`, `winback`, `retention` | lifecycle-crm, audience-persona, contextual-copywriter |
| `launch`, `GA`, `roadmap` | campaign-strategist, market-intelligence, cmo |

Always include `marketing-supervisor` as chair. CMO is included whenever the topic is strategic or budget-related.

### 3. Run the Meeting
Per `executive-protocol`'s Board Meeting Protocol:
1. State the agenda.
2. Gather attendee perspectives sequentially (3-5 sentences in quick, longer in full / strategic).
3. Identify points of **agreement** explicitly.
4. Surface points of **tension** explicitly — name who disagrees and why.
5. Synthesize a unified recommendation with confidence rating (low / medium / high).
6. Assign action items: owner + by-when + envelope-type (e.g. "campaign-strategist will emit a CreativeBrief by EOD Friday").

### 4. DecisionRecord
Marketing-supervisor writes a `DecisionRecord` envelope at the top of the output, with `decision_kind: board_meeting`.

### 5. Output
Write to:

```
output/executive/board/marketing-board-<topic-slug>-YYYY-MM-DD.md
```

Memory-steward writes an episodic-memory entry per AGENTS.md §8.

## Example Invocations

```
/marketing-board Should we reallocate Q3 budget from paid_search to CTV?
/marketing-board New brand voice for the relaunch --attendees brand-narrative,contextual-copywriter,cmo --format strategic
/marketing-board Regulated-claims posture for upcoming wealth-management launch --attendees brand-safety-compliance,campaign-strategist,cmo --format full
/marketing-board Lifecycle redesign for DTC winback flow --format quick
```
