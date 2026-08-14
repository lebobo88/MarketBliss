---
description: "Generate a campaign microsite spec using one of 5 aesthetic archetypes"
argument-hint: "<campaign> --archetype ethereal-glass|editorial-luxury|soft-structuralism|minimalist-editorial|industrial-brutalist [--industry <profile>]"
model: opus
skills:
  - aesthetic-archetypes
  - frontend-design
  - marketing-expertise
  - creative-brief-protocol
---

# Campaign Landing — MarketBliss

Generate a cinematic, scroll-driven campaign microsite **specification** (not the built site — building is delegated to Hydra `creative` via a `ShotList` envelope and to `frontend-design` for the UI layer). Every section is choreographed to the chosen aesthetic archetype.

**Campaign**: $ARGUMENTS

## Canonical Reference

Read `plugins/marketbliss/skills/aesthetic-archetypes/SKILL.md` for archetype-by-archetype surface / typography / motion / texture / palette specs. This command produces a microsite **spec** that downstream agents and Hydra's `creative` squad execute against.

## Argument Parsing

- `--archetype <name>` — REQUIRED. One of the 5 archetypes:
  - **ethereal-glass** — translucency, soft gradients, frosted overlays. Wellness, beauty, premium SaaS.
  - **editorial-luxury** — magazine-grade typography, generous whitespace, restrained palette. Finance, luxury, B2B.
  - **soft-structuralism** — geometric grids softened by curves and warmth. Health, B2B SaaS.
  - **minimalist-editorial** — black/white/one-accent. Professional services, law, consulting.
  - **industrial-brutalist** — raw concrete, exposed grids, sharp typography. Dev tools, creative agencies.
- `--industry <profile>` — one of the 6 industry profiles. Overrides palette restrictions per profile (e.g. regulated industries cap saturation).
- Everything else → campaign name + description.

## Process

### 1. Brand-Narrative Selects Archetype Fit
If `--archetype` is provided, `brand-narrative` validates fit against the campaign brief and the industry profile. If misaligned (e.g. industrial-brutalist for regulated wealth-management), surface a warning and require explicit override.

### 2. Build the 7-Section Microsite Architecture

#### Section 1 — Navbar
- Fixed, transparent-to-solid on scroll.
- Logo (left), 3-5 nav items + primary CTA (right).
- Archetype-specific micro-interaction: glass blur (ethereal-glass), letterspacing-shift (editorial-luxury), block-flip (industrial-brutalist).

#### Section 2 — Hero
- Full-viewport, scroll-driven entrance.
- Headline (campaign `core_message` from brief) + sub-headline + dual CTA.
- Hero visual: still or short looping video. Brand-narrative emits a `ShotList` entry for this asset.

#### Section 3 — Features / Value Pillars
- 3-6 cards in a bento grid.
- Map directly to `proof_points` from the `CreativeBrief`.
- ScrollTrigger stagger.

#### Section 4 — Philosophy / Brand Story
- Alternating-side narrative blocks with text-reveal-on-scroll.
- Sourced from `brand-narrative` voice samples in semantic memory.

#### Section 5 — Protocol / How-It-Works
- Sticky stacking cards with ScrollTrigger pinning.
- 3-5 steps in the customer journey.
- Maps to `target_audience.jtbd` from the brief.

#### Section 6 — Social Proof / Pricing
- For acquisition campaigns: pricing tiers (3 cards, scale-on-hover).
- For brand campaigns: testimonial wall / press logos.
- For launch campaigns: waitlist signup with progressive disclosure.
- For retention campaigns: loyalty tier overview.

#### Section 7 — Footer
- Subtle fade-in. Legal links, secondary nav, brand mark.
- In regulated profiles, include the mandatory disclosures footer block (per `brand-safety` skill).

### 3. Emit ShotList to Hydra `creative` Squad
For every visual element (hero, cards, philosophy imagery, protocol illustrations), `brand-narrative` emits a `ShotList` envelope addressed to Hydra `creative`:

```yaml
envelope: ShotList
workflow_id: mb-landing-<YYYYMMDD>-<slug>
origin_squad: marketing-creative
target_squad: creative
campaign_id: <id>
shots:
  - id: hero-still
    archetype: ethereal-glass
    surface: full-bleed
    motion: parallax-slow
    constraints: { aspect: "16:9", max_render_cost_usd: 50 }
  - id: protocol-step-1
    ...
context_refs:
  - kind: CreativeBrief
    handle: mem://marketbliss/brief/<campaign-id>
```

### 4. Design System Notes (per archetype)
Per `aesthetic-archetypes` skill, apply:
- Palette (3-5 colors, max).
- Type pairing (display + body).
- Motion vocabulary (easing curves, durations, reduce-motion fallback).
- Texture / noise layer.
- Container radii + spacing scale.

### 5. Accessibility + Quality
- WCAG 2.2 AA contrast on every text block.
- `prefers-reduced-motion` fallback for every GSAP animation.
- Lighthouse perf budget: LCP < 2.5s, CLS < 0.1.
- Brand-safety-compliance gate runs on the assembled spec.

### 6. Output

```
output/campaigns/<campaign-id>/assets/landing-spec-YYYY-MM-DD.md
```

The body contains:
1. The `ShotList` envelope (YAML block).
2. The 7-section spec with archetype-resolved tokens.
3. The design-system block (palette / type / motion / texture).
4. Open HITL items (talent / music / regulated-claims).

The actual implementation is handed off — either to Hydra `creative` for assets or to a pair-programmer `feature-team` run (with `frontend-design` skill) to build the page.

## Example Invocations

```
/campaign-landing Q3 demand-gen for cloud observability --archetype industrial-brutalist --industry b2b-saas
/campaign-landing Sensitive-skin skincare launch --archetype ethereal-glass --industry dtc-ecommerce
/campaign-landing Wealth-management new-practice launch --archetype editorial-luxury --industry regulated-health-finance
/campaign-landing AI compliance copilot GA --archetype soft-structuralism --industry b2b-saas
```
