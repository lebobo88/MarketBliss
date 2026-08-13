---
name: campaign-playbook
description: "Six industry-specific campaign playbooks — funnel stages, KPI targets, channel mix, cadence, critical gates, failure modes, blueprint examples."
user-invocable: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
---

# Campaign Playbook Skill

Owned by `campaign-strategist`. One playbook per MarketBliss industry profile. The strategist loads the playbook matching the active profile and merges it with the client's strategic goals and brief.

Each playbook is a starting blueprint — not a ceiling. Override fields are documented in the brief.

---

## Playbook 1 — B2B SaaS

| Stage | Channels | Primary KPI | Cadence |
|---|---|---|---|
| Awareness | Content/SEO, LinkedIn ads, podcasts, PR | Brand search lift, share-of-voice | Always-on |
| Consideration | Webinars, ungated guides, comparison content, retargeting | MQL rate, content engagement | Bi-weekly campaigns |
| Decision | Demo requests, free trial, ABM, sales-enablement | SQL rate, pipeline created | Continuous |
| Retention | Onboarding, in-product, CS-led nurture | Activation, NRR | Lifecycle-triggered |
| Advocacy | Reviews (G2/Capterra), case studies, referral | Reviews/qtr, referral % of new | Quarterly |

- **KPI targets**: MQL->SQL 25-40%, CAC payback <14mo, NRR >=110%
- **Channel mix default**: 35% paid social/search, 25% content/SEO, 20% ABM/sales-led, 10% events, 10% other
- **Critical gates**: ICP fit on every account list; brand-consistency on demo collateral; attribution-soundness on PLG experiments
- **Failure modes**: chasing MQLs not pipeline, gated content suppressing top-funnel discovery, attribution credit-stealing by last-touch
- **Blueprint**: Q3 demand-gen — pillar page on category + 4 cluster posts + LinkedIn always-on + ABM on Tier-1 ICP list + monthly webinar + customer story drop

---

## Playbook 2 — DTC E-commerce

| Stage | Channels | Primary KPI | Cadence |
|---|---|---|---|
| Awareness | Paid social (Meta/TikTok), influencer, YouTube, OOH | New customer rate, brand search | Always-on + tentpoles |
| Consideration | Retargeting, email capture, quizzes, UGC | Add-to-cart rate, list growth | Daily creative refresh |
| Decision | Promo, cart abandon, checkout optimization | Conversion rate, AOV | Real-time triggers |
| Retention | Lifecycle email/SMS, loyalty, replenishment | Repeat rate, 90-day LTV | Triggered + weekly |
| Advocacy | Reviews, UGC reposts, referral, ambassador | Reviews/order, referral revenue | Continuous |

- **KPI targets**: ROAS by stage (1.5x prospecting, 4x+ retargeting, 6x+ retention), 30%+ repeat in 90d
- **Channel mix default**: 45% paid social, 15% paid search, 15% email/SMS, 10% influencer, 10% retargeting/display, 5% affiliate
- **Critical gates**: brand-consistency on creative; budget-cap on prospecting; ip-clearance on UGC reposts
- **Failure modes**: prospecting-only ladders (no retention), discount addiction, attribution gaming by retargeting, creative fatigue
- **Blueprint**: Q4 holiday — 6-week creative test ladder on Meta/TikTok + influencer drop weeks 2,4 + email lifecycle reactivation + retention promo for VIPs only

---

## Playbook 3 — Professional Services

| Stage | Channels | Primary KPI | Cadence |
|---|---|---|---|
| Awareness | Thought-leadership, LinkedIn, podcasts, speaking | Brand mentions, content reach | Monthly |
| Consideration | Case studies, gated research, newsletter | Inquiry rate, list quality | Weekly |
| Decision | Referrals, partner intros, sales convos | Inquiry->engagement rate | Continuous |
| Retention | Account expansion, IP reuse, advisory | Account NRR | Quarterly |
| Advocacy | Client co-marketing, awards, referrals | Referral % of new revenue | Ongoing |

- **KPI targets**: inquiry->engagement 30-50%, referral % of new >=25%, avg engagement size growth y/y
- **Channel mix default**: 30% content/PR, 30% referral/partner, 20% LinkedIn/ABM, 10% events, 10% search
- **Critical gates**: brand-consistency on outbound; ip-clearance on client case studies
- **Failure modes**: opaque pricing kills inbound, founder-led marketing doesn't scale, case studies blocked by client confidentiality
- **Blueprint**: 6-month thought-leadership program — 1 flagship research piece + 6 cluster articles + LinkedIn always-on + quarterly executive dinners + co-marketed case study

---

## Playbook 4 — Regulated (Health / Finance / Insurance)

| Stage | Channels | Primary KPI | Cadence |
|---|---|---|---|
| Awareness | Brand campaigns (TV/audio/OOH), PR | Aided/unaided brand awareness | Quarterly waves |
| Consideration | Educational content (MLR-approved), KOL | Content engagement, intent signals | Monthly |
| Decision | Branded search, lead-gen forms with consent | Qualified-lead rate (not just MQL) | Always-on |
| Retention | Patient/customer education, adherence comms | Adherence/retention metrics | Lifecycle |
| Advocacy | Patient advocates, ambassador programs (rare) | NPS, advocacy panel size | Ongoing |

- **KPI targets**: cost-per-qualified-lead within regulated benchmark; complaint rate <0.1%; MLR throughput >90% on-time
- **Channel mix default**: 25% brand TV/audio, 20% educational content, 20% KOL/sponsorships, 15% search, 10% PR, 10% lifecycle
- **Critical gates**: regulated-claims-review HARD-REQUIRED on every external piece; brand-consistency HITL on every claim variant; ip-clearance on patient stories
- **Failure modes**: claim drift across creative variants, influencer non-disclosure, retroactive disclosures, social-listener missed adverse-event reports
- **Blueprint**: annual brand+education campaign — TV/audio hero + MLR-approved educational hub + 4 KOL videos + branded search always-on + adherence email program; every external piece gated by MLR

---

## Playbook 5 — Creative-Production

| Stage | Channels | Primary KPI | Cadence |
|---|---|---|---|
| Awareness | Portfolio drops, Instagram/TikTok reels, press | Reel views, portfolio visits | Weekly drops |
| Consideration | Portfolio deep-dives, behind-the-scenes, case studies | Inquiry rate | 2-3 per month |
| Decision | Discovery call, scope, proposal | Inquiry->engagement rate | Per inquiry |
| Retention | Repeat-client rhythm, expansion to new formats | % revenue from repeat | Annual |
| Advocacy | Awards, client co-tagging, referrals | Referral % of new | Continuous |

- **KPI targets**: inquiry->engagement 40-60%, repeat-client revenue 40%+, awards/qtr
- **Channel mix default**: 40% organic social, 20% portfolio/SEO, 20% referrals/partners, 10% PR/awards, 10% paid
- **Critical gates**: ip-clearance on every published asset (talent, music, location); brand-consistency on portfolio updates
- **Failure modes**: portfolio looks like portfolio of other studios (sameness), behind-scenes overshare leaks client confidentiality, talent release gaps
- **Blueprint**: 90-day brand sprint — refreshed portfolio site + 12 reel cuts + 2 long-form case studies + 1 awards submission + referral program activation

---

## Playbook 6 — Advertising / Commercial (Agency-of-Record)

| Stage | Channels | Primary KPI | Cadence |
|---|---|---|---|
| Awareness | Multi-channel media plan (TV/digital/OOH/audio/social) | Reach, brand lift | Always-on + bursts |
| Consideration | Mid-funnel content, video, audience-curated buys | Brand+performance hybrid metrics | Wave-based |
| Decision | DR / performance media | CPA, ROAS | Continuous optimization |
| Retention | CRM-fed lookalike audiences | Repeat-purchase lift | Monthly |
| Advocacy | Social amplification, UGC programs | Earned reach | Tentpole-driven |

- **KPI targets**: composite brand+performance scorecard; minimum delta-brand-awareness +3pts/yr; CPA tracked vs target by channel
- **Channel mix default**: 35% video (TV+CTV+YouTube), 25% paid social, 15% search, 10% audio (podcast+streaming), 10% OOH/programmatic, 5% sponsorship
- **Critical gates**: budget-cap (HARD); attribution-soundness on every channel claim; brand-consistency across all variants; ip-clearance on talent/music/stock
- **Failure modes**: brand vs performance silos, last-touch attribution favors search disproportionately, channel teams optimize locally not jointly, talent renegotiations mid-flight
- **Blueprint**: annual integrated campaign — Q1 hero film + Q1-Q4 always-on performance + Q2/Q4 tentpole bursts + monthly MMM read + quarterly geo-lift calibration

---

## Cross-Playbook Notes

- All playbooks adopt the funnel-metrics targets from `marketing-expertise` as starting points; profile overrides come from `profiles/<industry>.yaml -> kpi_targets`.
- Channel mix percentages are starting allocations — `media-buyer-bidder` optimizes against the channel-mix solver inputs (see `media-mix-modeling`).
- `campaign-strategist` MUST justify any deviation from playbook in the brief's "Strategic Rationale" section.

## References

- `marketing-expertise` (funnel metrics, pricing, content taxonomy)
- `media-mix-modeling` (channel-mix optimization)
- `lifecycle-marketing` (retention cadence)
- `brand-safety` (gate definitions per profile)
