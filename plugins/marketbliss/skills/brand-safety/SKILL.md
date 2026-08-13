---
name: brand-safety
description: "Brand safety and regulated-claims rulebook — toxicity/bias categories, FDA/FTC/FCA/GDPR rules, prohibited-content registry, brand-guideline enforcement, HITL escalation matrix, verdict schema."
user-invocable: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
---

# Brand Safety Skill

Owned by `brand-safety-compliance` (gatekeeper). Applied as the `brand-consistency` and `regulated-claims-review` gates on every outbound asset. Output is a structured verdict (pass / fail / hitl) with evidence; never a free-text opinion.

## 1. Toxicity & Bias Categories

| Category | Examples | Verdict default |
|---|---|---|
| Hate / discrimination | Slurs, dehumanizing language, protected-class attacks | fail |
| Harassment | Targeted attacks, doxxing, threats | fail |
| Sexual content | Explicit, minors-adjacent | fail (minors-adjacent: hard-fail + incident) |
| Self-harm | Glorification, instruction, contagion-risk framing | fail |
| Violence / graphic | Gore, weapons promotion, terrorism | fail |
| Illegal content | Drug sales, fraud, IP theft instructions | fail |
| Stereotyping (soft) | Tokenizing imagery, lazy archetypes | hitl |
| Cultural insensitivity | Sacred symbols misused, appropriation | hitl |
| Political polarization | Partisan stance not aligned with brand | hitl |
| Misleading / manipulative | Dark patterns, false urgency, fake scarcity | fail |

Use a screening model (e.g. Perspective API equivalent) for first-pass scoring; reserve human reasoning for HITL cases.

## 2. Regulated-Claims Rulebook

### FDA (US drugs, devices, supplements, cosmetics, food)

- **Drug claims** require approved indication, dosing, fair balance with risks
- **Disease claims** on supplements/food are prohibited; structure-function claims allowed with disclaimer
- **Devices**: classify Class I/II/III; Class II+ requires substantiation
- **Cosmetics**: cannot make drug claims (e.g. "treats acne" is drug-level)
- **Required**: "Important Safety Information" (ISI), fair balance, IFU (instructions for use) reference, ISI prominence parity with benefit claims
- **Forbidden**: cure / heal / treat / prevent for non-approved indications

### FTC (US advertising)

- **Substantiation**: every objective claim must have prior reasonable basis
- **Endorsements**: disclosed material connection, typical-result framing or clear disclaimer
- **"Made in USA"**: all-or-virtually-all standard; partial-content claims must qualify
- **Health claims**: competent and reliable scientific evidence
- **Comparative**: must be truthful and substantiated; can name competitors
- **Influencer**: `#ad`, `#sponsored` clearly visible; not buried in hashtags
- **Native ads**: clear "Advertisement" or "Sponsored" labeling

### FCA / SEC / FINRA (Financial promotions)

- **Past performance** disclaimer: "past performance is not indicative of future results"
- **Risk disclosure** proportional to benefit claims
- **ESG / sustainable claims**: comply with SEC Climate Disclosure rules, EU SFDR Article 8/9 if applicable
- **No guarantees of return**; no projections without backtesting methodology disclosure
- **Approved person**: financial promotions in UK require FCA-authorized signoff
- **Crypto / high-risk**: jurisdiction-specific cooling-off, suitability assessment

### GDPR / CCPA / Privacy

- **Consent**: explicit opt-in for marketing in GDPR jurisdictions; opt-out + Do-Not-Sell in CCPA
- **Cookie / tracker**: consent banner, granular categories, evidence of consent stored
- **Retention**: declared retention period, deletion process documented
- **DSAR**: data-subject-access-request fulfilled within 30 days (GDPR) / 45 days (CCPA)
- **Marketing data sharing**: declared in privacy policy, opt-out path

### Other regimes (jurisdiction-specific)

| Regime | Scope |
|---|---|
| ASA (UK) | Truthful, decent, legal, honest |
| ACMA / TGA (AU) | Therapeutic-goods advertising |
| LGPD (Brazil) | Privacy parallel to GDPR |
| HIPAA (US health) | PHI cannot appear in marketing without authorization |
| COPPA (US, <13) | No targeted advertising to under-13 |
| PIPL (China) | Cross-border data restrictions |

## 3. Prohibited-Content Registry Template

Maintained at `progress/prohibited-content.yaml`. Updated by `brand-safety-compliance`, audited quarterly.

```yaml
prohibited:
  global:
    - "competitor disparagement by name"
    - "any reference to ongoing litigation"
    - "internal codenames (Project Phoenix, etc.)"
  per_profile:
    regulated:
      - "drug-treats claims for non-approved indications"
      - "patient testimonials without IRB-equivalent consent"
    dtc:
      - "before/after weight-loss without TGA-style disclaimer"
    b2b-saas:
      - "uptime / SLA percentages above contracted SLA"
```

## 4. Brand-Guideline Enforcement Checklist

Applied per asset:

- [ ] Logo: correct lockup, clear-space, color version
- [ ] Color palette: only approved hex codes from `aesthetic-archetypes`
- [ ] Typography: only declared families and weights
- [ ] Voice: matches archetype tone (see `brand-narrative` voice card)
- [ ] Imagery: matches archetype texture / motion / palette
- [ ] Spelling of product / brand / customer names (canonical list)
- [ ] Legal entity name, jurisdiction abbreviations, registered marks (R, TM)
- [ ] Mandatory disclosures for the channel and jurisdiction
- [ ] Approved hashtag set used; banned hashtags absent
- [ ] Required CTAs (if regulated, e.g. "Talk to your doctor")

## 5. HITL Escalation Matrix

Rows: severity. Columns: industry profile category.

| Severity | Standard profiles | Regulated profile |
|---|---|---|
| Critical (hard fail) | Block + incident report | Block + incident + legal notification |
| High | Block + HITL (CMO + brand lead) | Block + HITL (CMO + legal + MLR) |
| Medium | HITL (brand lead) | HITL (CMO + legal) |
| Low | Auto-flag, pass with note | HITL (compliance) |
| Info | Pass | Pass with audit log entry |

MLR = Medical, Legal, Regulatory review board (pharma/healthcare).

## 6. Verdict Schema

Every gate run emits this structure (written to `progress/events.jsonl` and the `DecisionRecord`):

```yaml
verdict:
  gate_id: "brand-consistency"            # or regulated-claims-review
  artifact_ref: "memref://output/campaigns/c-2026Q3/assets/hero-v3.png"
  profile: "regulated-health-finance"
  result: "fail"                          # pass | fail | hitl
  severity: "high"                        # critical | high | medium | low | info
  findings:
    - rule_id: "fda-drug-claim-disease"
      category: "regulated-claim"
      evidence: "Caption: 'cures migraine in 24h' — non-approved indication"
      proposed_fix: "Replace with: 'may help reduce migraine frequency, see ISI'"
  required_approvers:
    - "cmo"
    - "compliance-officer"
  timestamp: "2026-05-19T14:22:11Z"
  agent: "brand-safety-compliance"
```

## 7. Standard Operating Procedure

1. Load `prohibited-content.yaml` and active profile rules.
2. Run automated screening (toxicity, regex on prohibited claims, schema validation).
3. Run brand-guideline checklist (visual + voice).
4. Run regulated-rules pass per active regime.
5. Aggregate findings; compute severity.
6. Emit verdict per schema; if `fail` or `hitl`, emit `HITLRequest` envelope.
7. Append entry to `progress/events.jsonl` (append-only).
8. If pass, return signed verdict to calling squad.

## 8. Anti-patterns

- Pass-with-conditions but conditions not enforced downstream
- Silent edits to the prohibited-content registry without a `DecisionRecord`
- Hard-fail without proposed fix (always include remediation guidance)
- HITL escalation without `required_approvers` list (caller cannot route)
- Re-running gate after asset hash changes without re-verdict

## References

- `marketing-governance` (HITL gate catalog)
- `creative-brief-protocol` (Guardrails section consumed here)
- AGENTS.md sec 7 (gate definitions and HITL rules)
