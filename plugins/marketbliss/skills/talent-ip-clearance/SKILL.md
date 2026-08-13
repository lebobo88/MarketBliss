---
name: talent-ip-clearance
description: "Talent releases, IP clearance, music licensing, stock-asset usage rights, location permits, and rights-of-publicity pre-flight for marketing production."
user-invocable: true
allowed-tools: [Read, Glob, Grep, Write]
---

# Talent and IP Clearance Skill

Canonical clearance protocol for marketing-production assets. Used by `talent-ip-coordinator`, `brand-safety-compliance`, and the `/production-brief` command. Every external publish from MarketBliss MUST clear the verdict schema in §8 before distribution.

## 1. Release Templates Catalog

| Release type           | Who signs                  | What it grants                                                | Retention             |
|------------------------|----------------------------|----------------------------------------------------------------|-----------------------|
| Model Release (adult)  | Subject                    | Likeness, voice, name; territory + term + media               | Term + 4 yrs          |
| Minor Release          | Parent or legal guardian   | Same; COPPA for under-13 if data collected                    | Term + 4 yrs after 18 |
| Group / Event Release  | Each attendee or signage   | Likeness in group context; opt-out workflow                   | Term + 4 yrs          |
| Location Release       | Property owner or manager  | Right to film + distribute imagery of premises                | Term + 4 yrs          |
| Property Release       | Owner of distinctive item  | Right to feature trademarked or identifiable object           | Term + 4 yrs          |
| Logo / Trademark Release| Mark owner                | License of mark in derivative work; scope of use              | Per license term      |
| Quote / Testimonial    | Quoted individual          | Right to attribute and reproduce testimonial; FTC compliance  | Term + 4 yrs          |

## 2. Music Licensing Tiers

| Tier                  | Examples                                          | Cost range (USD)    | Exclusivity         | Term                  |
|-----------------------|---------------------------------------------------|---------------------|---------------------|-----------------------|
| Royalty-free library  | Artlist, Epidemic Sound, Musicbed, PremiumBeat    | $200-1,200 / yr sub | Non-exclusive       | Subscription period   |
| Sync license          | One-time use of an existing recording             | $500-50,000+        | Project-specific    | Defined media+territory|
| Master license        | Specific recording (paired with sync)             | $1,000-100,000+     | Project-specific    | Defined               |
| Composition license   | Cover or re-record an existing composition        | $500-25,000+        | Project-specific    | Defined               |
| Custom composition    | Commissioned original                             | $2,000-100,000+     | Buyout possible     | Buyout: perpetual     |

Both **sync** and **master** are typically required to use a commercial recording in advertising. Subscription libraries grant sync + master via their TOS — always re-read the TOS for the specific use case (broadcast, paid social, OOH).

## 3. Stock Asset Usage Rights Matrix

| Library         | Standard            | Editorial only       | Extended / Enhanced    | Indemnification |
|-----------------|---------------------|----------------------|------------------------|-----------------|
| Getty Images    | Digital ad, web     | News, commentary     | Merch, broadcast, OOH  | Up to $10K-$1M  |
| Shutterstock    | Digital, social     | Editorial use only   | Unlimited reproduction | Up to $10K-$10K |
| Adobe Stock     | Digital, print      | News + editorial     | Extended (merch/POS)   | Up to $10K-$1M  |
| Pond5           | Digital, broadcast  | Editorial            | Extended (templates)   | Varies          |
| iStock          | Digital, print      | Editorial only       | Extended (merch)       | Up to $10K      |

Distribution cap rules: Standard licenses typically cap reproduction at 500K impressions or copies. Extended licenses lift the cap. **Editorial-only** assets MUST NOT appear in advertising. Verify per asset, per use.

## 4. UGC and Influencer Disclosure

| Jurisdiction | Authority    | Rule                                                          | Required disclosure        |
|--------------|--------------|---------------------------------------------------------------|----------------------------|
| US           | FTC §255     | Material connection must be clearly and conspicuously disclosed| #ad, #sponsored            |
| UK           | ASA          | Ad recognition required; CAP Code 2.1                          | "Ad" prefix                |
| India        | ASCI         | Disclosure label upfront on all influencer content             | "#Advertisement" or "#Ad"  |
| France       | ARPP         | Mandatory disclosure for partnerships                          | "Partenariat rémunéré"     |
| EU broad     | UCPD + DSA   | Material commercial communication must be identifiable        | Per member state           |

FTC sweep risk areas: undisclosed gifting, family-relationship endorsements without disclosure, ambiguous tags (#partner, #thanks), affiliate links without disclosure.

## 5. Likeness, Publicity, Privacy

| Regime                        | Scope                                                          | Lead time     |
|-------------------------------|----------------------------------------------------------------|---------------|
| US right of publicity         | State-by-state — California Civil Code §3344, NY Civil Rights §50-51 most stringent | Check per state |
| GDPR Article 6                | Lawful basis required for processing likeness (consent or LI) | Pre-shoot     |
| CCPA / CPRA                   | "Sale" implications when likeness fuels ad targeting           | Pre-launch    |
| COPPA                         | Under-13: verifiable parental consent before data collection   | Pre-shoot     |
| HIPAA (when applicable)       | Patient likeness + health context = PHI                        | Pre-shoot     |

## 6. Chain of Title Checklist

Every asset in a finished campaign must trace to a complete chain:

- [ ] Written agreement on file
- [ ] Assignment of rights or exclusive license clause
- [ ] Consideration documented (payment, comp, or recital)
- [ ] Effective date and term defined
- [ ] Scope: territory + term + permitted media
- [ ] Moral rights waiver where applicable (France, Germany strict)
- [ ] Indemnification clause naming MarketBliss + client
- [ ] Governing law and venue specified
- [ ] Counter-signatures on file (PDF + signed-on date)
- [ ] Registered in chain-of-title ledger at `output/campaigns/<id>/production/clearance.md`

## 7. Per-Geography Permit Map

| Region    | Authority                    | Lead time | Fee range (USD)  | Triggers                                             |
|-----------|------------------------------|-----------|------------------|------------------------------------------------------|
| US — city | City film office             | 5-15 d    | $50-1,500/day    | Street, public building, school, hospital, park      |
| US — drone| FAA Part 107 + state/local   | Same-day to 30 d | $0-500    | Any commercial drone                                 |
| UK        | Local council + FilmFixer    | 5-15 d    | £50-2,000/day    | Public realm, transport hubs                         |
| EU broad  | Per member state + city      | 7-30 d    | €100-3,000/day   | Public space, monuments, schools                     |
| Canada    | Provincial + municipal       | 5-20 d    | C$100-2,000/day  | Public realm                                         |
| Australia | State film commission + LGA  | 10-21 d   | A$100-2,000/day  | Public realm, beaches                                |

## 8. Pass / Fail / HITL Verdict Schema

```json
{
  "asset_id": "<id>",
  "verdict": "pass | fail | hitl-required",
  "violations": [
    {
      "category": "talent | music | stock | location | trademark | privacy",
      "severity": "low | med | high | critical",
      "evidence_ref": "<path or memref>"
    }
  ],
  "required_actions": ["<action>"],
  "approved_by": "<agent-slug-or-human-id>",
  "decided_at": "<iso8601>"
}
```

Routing: any `severity >= high` or any minor / un-released talent / un-licensed music routes to HITL with subtype `ip_release_review`.

## 9. Retention Rules

- Signed releases retained for **term of use + 4 years** (US statute-of-limitations safe margin).
- EU GDPR: retention basis must be tied to a documented processing purpose; default 4 years post-term unless a longer legal basis exists.
- Minor releases: retain until subject's age of majority + 4 years.
- Storage: encrypted at rest in `output/campaigns/<id>/production/releases/` plus a redundant archive.
- Destruction log required on expiry.

## References

- `brand-safety` skill — guardrails registry
- `marketing-governance` skill — approval gates and audit trail
- AGENTS.md §7 — gatekeeper roster (the `ip-clearance` gate is owned by `talent-ip-coordinator`)
