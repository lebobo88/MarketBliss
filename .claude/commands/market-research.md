---
description: "Run the research squad triad — market-intelligence + audience-persona + seo-analyst"
argument-hint: "<topic/market> [--industry <profile>] [--depth quick|standard|deep]"
model: sonnet
skills:
  - marketing-expertise
  - marketing-business-context
  - audience-segmentation
  - semantic-seo
  - marketing-attribution
---

# Market Research — MarketBliss

Run the `marketing-research` squad to produce a consolidated `MarketBrief` envelope across three research lenses: competitive intelligence, audience persona, and SEO / content-gap mapping.

**Topic**: $ARGUMENTS

## Research Process

### 1. Parse Arguments
- Extract the topic / market (free text).
- `--industry <profile>` — one of the 6 industry profiles. Drives KPI targets and HITL thresholds.
- `--depth`:
  - `quick` — 30-min equivalent, 3-5 bullets per lens, no SERP scrape.
  - `standard` (default) — 1-page per lens, top-10 SERP, 3-5 competitors.
  - `deep` — multi-page per lens, top-30 SERP, 8-10 competitors, JTBD interviews simulated.

### 2. Marketing-Supervisor Routing
- Mint `workflow_id` (format: `mb-research-<YYYYMMDD>-<slug>`).
- Dispatch three parallel sub-jobs to the research-squad agents:
  - `market-intelligence` → TAM/SAM/SOM estimate, top competitor matrix, positioning quadrant, recent trend signals.
  - `audience-persona` → 2-3 primary personas, JTBD framing, intent-stage mapping, behavioral cohorts.
  - `seo-analyst` → pillar/cluster map, top SERP entities, content-gap matrix, intent-to-keyword mapping.

### 3. Per-Lens Output

**Market Intelligence (`market-intelligence`)**
- Market size + 3-yr growth trajectory.
- Top 5 competitors with positioning + estimated share.
- Whitespace / underserved segments.
- Trend signals (top 3) with confidence rating.

**Audience Persona (`audience-persona`)**
- 2-3 persona archetypes with JTBD statements.
- Intent stages (problem-aware → solution-aware → vendor-aware → ready-to-buy).
- RFM / behavioral cohort overlays if existing customer data is referenced.

**SEO (`seo-analyst`)**
- Pillar + cluster map (1 pillar, 4-8 clusters).
- Top 10 SERP competitors with entity overlap.
- Content gaps ranked by `(volume × intent_score) / difficulty`.

### 4. Synthesis
Marketing-supervisor consolidates the three outputs into a single `MarketBrief` envelope:

```yaml
envelope: MarketBrief
workflow_id: mb-research-20260519-cloud-observability
topic: "Cloud observability for mid-market SaaS"
industry: b2b-saas
depth: standard
findings:
  market: {...}
  audience: {...}
  seo: {...}
recommended_next_step: campaign-brief
context_refs: [...]
```

### 5. Output
Write to:

```
output/research/<topic-slug>-YYYY-MM-DD.md
```

Header is the YAML envelope; body is the long-form narrative with section headings per lens. Memory-steward writes an episodic-memory entry per AGENTS.md §8.

## Example Invocations

```
/market-research Cloud observability for mid-market SaaS --industry b2b-saas --depth standard
/market-research Sustainable haircare for Gen Z --industry dtc-ecommerce --depth deep
/market-research Wealth management for medical professionals --industry regulated-health-finance --depth standard
```
