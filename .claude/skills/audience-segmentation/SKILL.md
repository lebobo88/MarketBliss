---
name: audience-segmentation
description: "Audience segmentation toolkit — RFM, behavioral cohorts, JTBD, ICP for B2B, CDP/CRM integration patterns, persona archetype templates."
user-invocable: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
---

# Audience Segmentation Skill

Owned by `audience-persona`; consumed by `campaign-strategist`, `lifecycle-crm`, `contextual-copywriter`, and `media-buyer-bidder`. Four lenses: **RFM** (transactional), **Behavioral cohorts** (event-based), **JTBD** (motivational), **ICP** (B2B firmographic). Use multiple lenses in combination — no single lens is sufficient.

## 1. RFM Segmentation (Recency / Frequency / Monetary)

For each customer, compute:

- **R** = days since most-recent purchase (lower = better)
- **F** = count of purchases over window (e.g. last 365 days)
- **M** = sum of monetary value over window

Bin each into 1-5 quintiles (5 = best). Concatenate to RFM score (e.g. "545").

### Standard RFM Segments

| Segment | RFM pattern | Action |
|---|---|---|
| Champions | 4-5, 4-5, 4-5 | Loyalty, referrals, early access |
| Loyal | 3-5, 4-5, 3-5 | Upsell, advocacy ask |
| Potential loyalist | 4-5, 1-2, 1-3 | Onboarding deepening, second purchase |
| New customers | 4-5, 1, 1 | Welcome series, expectation setting |
| Promising | 3-4, 1, 1-2 | Activation triggers |
| Needs attention | 2-3, 2-3, 2-3 | Targeted re-engagement |
| About to sleep | 2-3, 1-2, 1-2 | Re-engagement campaign |
| At risk | 1-2, 2-5, 2-5 | Winback before churn |
| Can't lose them | 1, 4-5, 4-5 | High-touch, possible HITL |
| Hibernating | 1-2, 1-2, 1-2 | Low-cost reactivation |
| Lost | 1, 1, 1 | Suppress or sunset |

### Cutoff Guidance by Industry

| Industry | R quintile window | F window |
|---|---|---|
| DTC fast-moving (beauty, food) | 30/60/90/180/365 days | 365 days |
| DTC durable (apparel, home) | 60/120/180/365/730 days | 730 days |
| B2B SaaS (subscription) | Use active/churn lifecycle instead |
| Pro Services | 180/365/730/1095 days | 1095 days |

## 2. Behavioral Cohorts

Define cohorts by event sequence, not demographics. Standard funnel:

```
signed_up -> activated -> engaged -> power_user -> at_risk -> churned
```

### Threshold Reference

| State | Trigger | Typical threshold |
|---|---|---|
| signed_up | account created | t = 0 |
| activated | first meaningful action | within D1-D3, varies by product |
| engaged | recurring meaningful action | >=3 sessions in 7 days |
| power_user | top-decile usage | top 10% by frequency or depth |
| at_risk | usage decay | 50% drop in 14-day rolling avg |
| dormant | no activity | no event in 30 days |
| churned | cancellation or 90-day dormant | explicit cancel or no event 90d |

### Cohort Retention Curve Template

| Day | D0 | D1 | D7 | D14 | D30 | D60 | D90 |
|---|---|---|---|---|---|---|---|
| % active | 100% | x | x | x | x | x | x |

Compare cohorts week-over-week to detect activation regressions.

## 3. Jobs-To-Be-Done (JTBD)

Frame the customer's underlying motivation, not features.

### JTBD Template

```
When [situation],
I want to [motivation / desired progress],
So I can [desired outcome / emotional or social payoff].
```

Example (B2B observability SaaS):
> When a production incident wakes my on-call at 3am, I want to find the root cause in under 10 minutes, so I can restore service before customers notice and protect my team's morale.

### Job Statement Validation Checklist
- [ ] Solution-agnostic (no feature/product names)
- [ ] Includes context (when), motivation (I want to), and outcome (so I can)
- [ ] Outcome is emotional/social, not just functional
- [ ] Falsifiable — could a customer disagree?
- [ ] Verbatim quotes from customer interviews supporting it

## 4. Ideal Customer Profile (ICP) — B2B

Firmographic + technographic + behavioral.

### ICP Template

```yaml
icp:
  firmographic:
    industry: ["SaaS", "Fintech"]
    revenue_band: "$50M - $500M ARR"
    employee_count: "200 - 2000"
    region: ["North America", "EMEA"]
    funding_stage: "Series B - D"
  technographic:
    must_have: ["Kubernetes", "AWS or GCP"]
    integrations_used: ["PagerDuty", "Slack"]
    excludes: ["mainframe-only", "fully on-prem"]
  behavioral:
    growth_signals: ["hiring SREs", "recent funding"]
    triggers: ["recent outage news", "platform team posted"]
  buying_committee:
    champion: "Sr. SRE / Platform Eng Manager"
    economic_buyer: "VP Engineering / CTO"
    technical_buyer: "Lead SRE"
    blocker: "Security / Compliance"
  disqualifiers:
    - "Hard requirement for on-prem"
    - "Annual contract value < $25k"
```

### ICP Scoring

Score = w1*firmographic_match + w2*technographic_match + w3*behavioral_signal. Use 0/0.5/1 per field. Score >= 0.7 = Tier-1 ICP.

## 5. CDP / CRM Integration Patterns

| System | Family | Marketing role | Notes |
|---|---|---|---|
| Segment | CDP | Source-of-truth event router | Best for product-led data |
| mParticle | CDP | Enterprise event router with consent mgmt | Strong for regulated |
| RudderStack | CDP | Open-source / warehouse-native | Cost-effective at scale |
| HubSpot | CRM | Mid-market sales+marketing | Native marketing automation |
| Salesforce + Pardot/MCAE | CRM | Enterprise B2B | Powerful but heavy |
| Klaviyo | ESP/CRM | DTC ecommerce | Best-in-class for DTC lifecycle |
| Braze | Cross-channel | Cross-channel orchestration | Mobile-first lifecycle |
| Customer.io | Cross-channel | Mid-market event-based | Strong for SaaS |

### Standard Event Schema

```json
{
  "userId": "u_123",
  "anonymousId": "a_456",
  "event": "Product Viewed",
  "properties": {
    "sku": "...",
    "category": "...",
    "price": 39.99
  },
  "context": {
    "campaign": {"name": "...", "source": "...", "medium": "..."},
    "consent": {"marketing": true, "analytics": true}
  },
  "timestamp": "2026-05-19T12:34:56Z"
}
```

Consent flag must be carried on every event — required for GDPR/CCPA.

## 6. Persona Archetype Templates

Three example personas across industries (substitute per profile).

### Persona A — "Priya the Platform Manager" (B2B SaaS, ICP-aligned)
- Role: Sr. Platform Engineering Manager, 8 yr exp, leads team of 6
- Context: On-call rotation, recent outage led to exec scrutiny
- JTBD: cut MTTR, retain team, justify tooling spend
- Channels: HackerNews, LinkedIn, technical podcasts, peer Slack groups
- Objections: "Yet another agent on our nodes," cost-per-host

### Persona B — "Maya the Modern Mom" (DTC home goods)
- Demographics: 32-45, HHI $90-180k, suburban, kid(s) at home
- Psychographics: design-conscious, time-poor, brand-loyal once trust earned
- JTBD: home that feels considered without a designer's budget
- Channels: Instagram (saves > likes), Pinterest, TikTok cleantok, podcast ads
- Objections: returns friction, fit risk, brand authenticity

### Persona C — "Daniel the Decisional Director" (Pro Services buyer)
- Role: VP Marketing / Brand Director at a $200M-$1B company
- Context: under-resourced internal team, board pressure on growth
- JTBD: predictable pipeline without a 6-month agency RFP
- Channels: LinkedIn, peer referrals, executive newsletters, podcasts
- Objections: agency churn, opaque pricing, scope creep

## References

- `marketing-attribution` (cohorts feed MTA)
- `lifecycle-marketing` (cohorts drive cadence)
- `experimentation-design` (cohorts are randomization units)
