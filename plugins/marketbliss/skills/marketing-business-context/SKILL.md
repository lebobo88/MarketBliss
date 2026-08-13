---
name: marketing-business-context
description: "Marketing business context — identity, aesthetic, services, portfolio, segments, competitive positioning, strategic goals — parameterized per industry profile."
user-invocable: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
---

# Marketing Business Context Skill

Foundational business knowledge surface that every MarketBliss agent loads at session start. Unlike a fixed identity document, this skill is a **template + framework set** the supervisor populates from the active industry profile (`profiles/<industry>.yaml`) and the client's current strategic goals.

Load order:
1. Read active profile slug from `progress/config.json` -> `profile`.
2. Resolve `profiles/<profile>.yaml` and extract `identity`, `aesthetic`, `services`, `segments`, `positioning`, `kpi_targets`, `gates`.
3. Overlay current goals from `output/executive/strategy/current-goals.md`.
4. Hand the merged context to downstream agents via `context_refs` (MemoryRef handles, not blobs).

## 1. Industry Identity Framework

Every campaign must answer these eight questions before strategy work begins. The `campaign-strategist` is the owner; the answers are immutable for the campaign lifecycle once the brief gate signs off.

| # | Question | Source field |
|---|---|---|
| 1 | What is the brand name and tagline? | `identity.brand`, `identity.tagline` |
| 2 | Which of the 6 industry profiles applies? | `profile` |
| 3 | What region / locale / language is in scope? | `identity.region`, `identity.locale` |
| 4 | What is the primary regulatory regime (if any)? | `gates.regulatory_regime` |
| 5 | What is the year founded / time-in-market? | `identity.founded` |
| 6 | What is the primary URL of record? | `identity.website` |
| 7 | What contact channels are public-facing? | `identity.contacts` |
| 8 | What is the brand archetype (12-archetype model)? | `aesthetic.archetype` |

If any field is missing, the `campaign-strategist` MUST emit an `HITLRequest` (subtype `brief_clarification`) rather than guess.

## 2. Brand Aesthetic Framework

Pull from `profiles/<industry>.yaml -> aesthetic`. The five canonical aesthetic archetypes are defined in the `aesthetic-archetypes` skill. This section captures the **selection** for the active client.

```yaml
aesthetic:
  archetype: "editorial-luxury"          # one of 5 from aesthetic-archetypes
  visual_tone: "refined, restrained, considered"
  palette:
    primary: "#0A0A0A"
    secondary: "#F5F1EA"
    accent: "#8B6B3D"
  typography:
    heading: "Canela Deck 500"
    body: "Inter 400"
  motion: "slow, easeOutQuint, 600-900ms"
  texture: "subtle paper grain, 8% opacity"
  voice: "intentional, sparse, present-tense"
```

`brand-narrative` is the gatekeeper that locks aesthetic at the brief stage and propagates it into every `ShotList` envelope handed downstream to Hydra's `creative` squad.

## 3. Services & Pricing Template

Populate from `profiles/<industry>.yaml -> services[]`. Schema:

| Field | Type | Example |
|---|---|---|
| sku | string | "campaign-pro" |
| name | string | "Integrated Demand-Gen Campaign" |
| scope | string | "Strategy + creative + media + measurement, 90 days" |
| starting_price_usd | number | 35000 |
| pricing_model | enum | fixed / retainer / value / usage |
| deliverables | list | ["brief", "creative-set", "media-plan", "measurement-report"] |
| typical_duration | string | "90 days" |
| target_segment | list | ["b2b-saas-series-b+"] |

DTC and Creative-Production profiles use SKU-level pricing; B2B SaaS and Professional Services use tiered or retainer pricing.

## 4. Portfolio / Solution Categories

Categories are the organizing taxonomy for case studies, landing pages, and SEO clusters. Example sets by profile:

| Profile | Typical categories |
|---|---|
| B2B SaaS | Demand-gen, ABM, PLG growth, retention, integrations |
| DTC E-com | Acquisition, retention, lifecycle, influencer, retail-expansion |
| Pro Services | Brand, demand-gen, content, recruiting, M&A comms |
| Regulated | Compliance comms, patient/customer ed, fair-balance ads, KOL |
| Creative-Production | Brand films, campaign assets, social cuts, event capture |
| Ad-Commercial | Always-on, campaign sprints, brand+performance balance |

## 5. Target Client Segments Framework

For each segment, capture:

- **Segment name** (kebab-case)
- **Demographic / firmographic** (industry, ARR/revenue, employee count, geo, age, income)
- **Psychographic** (values, fears, aspirations)
- **JTBD** (when / I want / so I can — see `audience-segmentation` skill)
- **Buyer journey stage maturity** (cold / warm / hot)
- **Decision-making unit** (champion, economic buyer, technical buyer, blocker)
- **Estimated TAM / SAM / SOM** (from `market-intelligence`)

## 6. Competitive Positioning Template

```yaml
positioning:
  category: "B2B observability platform"
  differentiator: "AI-first incident root-cause in <5 min"
  proof_points:
    - "92% of incidents auto-triaged"
    - "Customer story: cut MTTR 70%"
  market_position: "challenger"          # leader / challenger / niche / disruptor
  geography:
    primary: "North America"
    secondary: ["EMEA", "ANZ"]
  alternatives:
    - name: "Datadog"
      strength: "ecosystem breadth"
      weakness: "cost at scale"
    - name: "Status quo (manual + Splunk)"
      strength: "incumbent"
      weakness: "slow MTTR"
```

## 7. Current Strategic Goals (Dynamic)

Goals load from `output/executive/strategy/current-goals.md`, written by ExecutiveSuite's CMO and reviewed quarterly. If the file is missing, MarketBliss runs in **inferred-goals mode** and the supervisor emits a `HITLRequest` (subtype `strategic_alignment`) before campaign sign-off.

Goal schema:

```yaml
goals:
  - id: "g1"
    horizon: "Q3-Q4"
    objective: "Drive 30% pipeline growth in mid-market"
    key_results:
      - "Generate 1,200 MQLs / quarter"
      - "Hold CAC payback < 14 months"
    owner: "cmo"
    risk_class: "moderate"
```

The supervisor merges goals into every `CSuiteDecisionPacket` summary so downstream squads can verify strategic alignment before execution.

## 8. Profile Slot Defaults

When a profile field is absent, fall back to these defaults (do not invent specifics):

| Slot | Default |
|---|---|
| identity.region | "US-multi-state" |
| identity.locale | "en-US" |
| aesthetic.archetype | "minimalist-editorial" |
| gates.regulatory_regime | "none" |
| kpi_targets | from `marketing-expertise` industry-tuned defaults |

## Research Reference

- Active profile: `profiles/<industry>.yaml`
- Current goals: `output/executive/strategy/current-goals.md`
- Brand book (if exists): `output/executive/marketing/brand-book.md`
