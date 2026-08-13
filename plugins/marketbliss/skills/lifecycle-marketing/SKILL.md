---
name: lifecycle-marketing
description: "Onboarding, retention, and winback playbooks — cadence templates, behavioral triggers, frequency rules per industry, sunset/suppression rules."
user-invocable: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
---

# Lifecycle Marketing Skill

Owned by `lifecycle-crm`. Designs and operates the email / SMS / push / in-app cadence across the customer journey. Activated by behavioral triggers from the CDP/CRM (see `audience-segmentation`).

Three phases: **Onboarding** (acquire -> activate), **Retention** (engaged -> loyal), **Winback** (at-risk / churned).

## 1. Onboarding Cadence

Standard sequence for new signups / first-purchasers. Adjust thresholds per profile.

| Day | Channel | Purpose | Template hook |
|---|---|---|---|
| D0 | Email | Welcome + confirm | Brand story, what to expect, first-step CTA |
| D0 | SMS (optional) | Confirm channel opt-in | "You're in. Reply HELP / STOP." |
| D1 | Email | Activation push | "Take your first [action] — here's how" |
| D1 | Push (in-app) | Activation reminder | "1 step left to get started" |
| D3 | Email | Value reinforcement | Social proof, customer story |
| D3 | Email (conditional) | Activation rescue | If D1 action not taken |
| D7 | Email | Feature / category discovery | Curated path #2 |
| D7 | Email | First-purchase nudge (DTC) | First-time-buyer incentive |
| D14 | Email | Community / advocacy invite | UGC, reviews, referrals |
| D14 | Email | Educational | Power-user tip, advanced use |
| D30 | Email | Milestone | "30 days with us — your stats" |
| D30 | Email | Conversion to paid (SaaS) or repeat (DTC) | Tier upgrade or 2nd purchase |

### Onboarding Goals (by industry)

| Profile | D7 activation target | D30 retention target |
|---|---|---|
| B2B SaaS | 70%+ activate to AHA moment | 60%+ engaged-user state |
| DTC | 50%+ engage with second touchpoint | 25%+ second purchase |
| Pro Services | n/a (consultative cycle) | 80%+ engagement with onboarding doc |
| Regulated | 60%+ confirm setup | adherence/usage benchmarks |

## 2. Retention Playbook

Stages: activation -> engagement -> loyalty -> advocacy.

### Engagement deepening (D30-D90)
- Weekly digest with personalized highlights
- Triggered comms on power-user behaviors
- Cross-sell to adjacent categories or features
- Educational content escalating in depth

### Loyalty (D90+)
- Loyalty program enrollment (DTC)
- Account-expansion plays (B2B SaaS)
- VIP perks, early access, exclusive content
- Anniversary moments (account birthday, milestone reached)

### Advocacy
- Referral program with double-sided incentive
- Review request post-positive-experience trigger
- UGC ask with branded hashtag
- Case study / testimonial outreach (B2B)

### Retention KPI Targets

| Metric | DTC | B2B SaaS | Pro Services |
|---|---|---|---|
| 90-day repeat / NRR | 30%+ | 105-115% | 40%+ |
| Engaged-user % MAU | n/a | 50%+ | n/a |
| Loyalty enrollment | 30%+ | n/a | n/a |
| Referral % of new | 10-25% | 15-25% | 25-40% |

## 3. Winback Cadence (post-churn)

Trigger: customer enters `dormant` or `churned` state (see `audience-segmentation`).

| Day post-churn | Channel | Purpose | Offer |
|---|---|---|---|
| D30 | Email | Soft re-engagement | "We've improved — see what's new" |
| D45 | Email | Personalized value reminder | Their last action + what to do next |
| D60 | Email | Incentivized return | DTC: 15-25% off; SaaS: extended trial; Pro Services: free assessment |
| D75 | Email | Last-chance framing | "We don't want to lose you" |
| D90 | Email + decision | Suppression decision | Reactivate or move to suppression |

### Winback success rules
- Stop the sequence at first re-engagement event (open + click + visit)
- Cap incentive escalation; never deepen beyond brand's discount floor
- Profile match: in regulated, no incentive plays — value-only winback

## 4. Email / SMS / Push Frequency Rules

| Profile | Email/wk max | SMS/wk max | Push/day max | Quiet hours (local) |
|---|---|---|---|---|
| B2B SaaS | 3 | 0-1 | 2 | 21:00 - 07:00 |
| DTC | 5 | 2-3 | 3 | 22:00 - 08:00 |
| Pro Services | 2 | 0 | 1 | 21:00 - 08:00 |
| Regulated | 2 | 0 | 1 | per consent + regulation |
| Creative-Production | 1-2 | 0 | n/a | n/a |
| Ad-Commercial | n/a (client-driven) | per client | per client | per client |

Hard caps; never override without HITL + recorded `DecisionRecord`.

## 5. Behavioral Trigger Taxonomy

| Trigger | Definition | Suggested response |
|---|---|---|
| Welcome | account created | Onboarding D0 |
| Activation | first meaningful action | Engagement deepening |
| Activation-rescue | signup but no activation by D2 | Activation prompt |
| Cart abandon (DTC) | items in cart, no checkout, 1+ hr | Email +1hr, +24hr, +72hr |
| Browse abandon (DTC) | viewed category 3+ times, no purchase | Curated email +24hr |
| Wishlist back-in-stock | item returns to stock | Real-time email/push |
| Price drop | watched item drops 10%+ | Real-time push |
| Milestone | usage / time / spend threshold | Celebratory + advocacy ask |
| Anniversary | account birthday | Personalized retrospective |
| Dormant | inactive 30+ days | Winback D30 |
| At-risk | usage decay signal | Personalized re-engagement |
| NPS-detractor | NPS score 0-6 | CS-handoff, no marketing send |
| Complaint / opt-out | explicit | Full suppression |

## 6. Sunset / Suppression Rules

A subscriber moves to suppression when ANY of:

- Hard bounce (1 hard bounce or 3 soft bounces in 30 days)
- Marked as spam complaint (immediate)
- Explicit unsubscribe (immediate, all marketing channels)
- No open / click in 180 days AND no other engagement (sunset candidate)
- GDPR consent expired without renewal (immediate in EEA)
- CCPA "Do Not Sell / Share" requested (process within 15 days)

Suppression is **never reversible** without explicit re-opt-in evidence.

### Sunset Workflow
1. Identify candidates (180-day no-engage)
2. Send "still want to hear from us?" re-permission email
3. If no click/confirm in 14 days, move to suppressed
4. Log suppression event in `progress/events.jsonl`

## 7. Industry-Specific Patterns

### B2B SaaS
- Trial-conversion sequence: D-7 / D-3 / D-1 to expiry
- In-product over email when possible (higher engagement)
- Account-level signals (not just user-level)

### DTC E-com
- Replenishment timing tied to product consumption cycle
- Loyalty-tier-aware messaging
- Inventory-aware triggers (back-in-stock, low-stock urgency)

### Pro Services
- Sparse but high-touch; founder/senior signature emails
- Event-driven (industry news, regulation changes)
- Quarterly executive briefings

### Regulated
- Consent re-confirmation per regime
- Adherence reminders (health) with required disclosures
- All marketing comms pre-cleared by `brand-safety-compliance`

## 8. Output Deliverables

- `output/campaigns/<id>/lifecycle/cadence-map.md` — full journey map
- `output/campaigns/<id>/lifecycle/triggers.yaml` — trigger -> message rules
- `output/campaigns/<id>/lifecycle/suppression-policy.md` — sunset/suppress logic

## 9. Anti-patterns

- Sending all triggers to all subscribers (no segmentation)
- Frequency caps not enforced cross-channel
- Re-engagement of suppressed users
- Lifecycle messages without consent-flag check
- Discount-laddering teaching customers to wait for incentives

## References

- `audience-segmentation` (cohort definitions, RFM, behavioral states)
- `experimentation-design` (lifecycle A/B testing)
- `brand-safety` (regulated marketing rules)
