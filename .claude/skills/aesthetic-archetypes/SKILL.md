---
name: aesthetic-archetypes
description: "Five named aesthetic bundles (Ethereal Glass, Editorial Luxury, Soft Structuralism, Minimalist Editorial, Industrial Brutalist) with surface / typography / motion / texture specs and a profile-to-archetype decision matrix."
user-invocable: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
---

# Aesthetic Archetypes Skill

Locks visual identity for a campaign by selecting one of five named aesthetic bundles. The selection is propagated into every `CreativeBrief` -> `ShotList` -> `AssetJob` envelope MarketBliss hands to Hydra's `creative` squad. `brand-narrative` is the owning agent.

Why five and not infinite: a finite vocabulary forces commitment, prevents aesthetic drift across a multi-asset campaign, and gives the downstream production pipeline (ComfyUI prompts, frontend-design tokens, motion specs) a deterministic seed.

## Selection Rule

Pick ONE archetype per campaign. Sub-archetypes (e.g. "Editorial Luxury with Industrial Brutalist accent for the editorial spread") are allowed only at the asset level and must be flagged in the `ShotList` `style_notes` field.

## Archetype 1 — Ethereal Glass

| Dimension | Spec |
|---|---|
| Surfaces | Frosted glass, light gradients (#FAFBFC -> #E8EEF5), soft blur layers, white 60-80% opacity |
| Materials | Holographic foils, satin, brushed acrylic, soft pearl |
| Typography heading | Inter Display 300, ABC Diatype Light, or Söhne Light — wide tracking |
| Typography body | Inter 400, 16-18px, 1.6 line-height |
| Typography mono | JetBrains Mono 300 |
| Shadows | 0 1px 3px rgba(0,0,0,0.04), 0 8px 24px rgba(60,80,120,0.06) — cool, diffuse |
| Motion | easeOutExpo, 400-600ms, slight 1.02 scale on hover, no springs |
| Icons | 1.25px stroke, rounded ends, line style |
| Texture | 3-5% subtle gradient noise, no grain |
| Best fit | Wellness DTC, SaaS PLG, modern fintech, lifestyle-tech |

## Archetype 2 — Editorial Luxury

| Dimension | Spec |
|---|---|
| Surfaces | Deep black (#0A0A0A), ivory (#F5F1EA), brass accent (#8B6B3D), generous whitespace |
| Materials | Matte paper, embossed foil, hand-bound, vellum overlays |
| Typography heading | Canela Deck 500, GT Sectra Display 400, or Söhne Mono — serif or display |
| Typography body | Inter 400 or Tiempos Text 400, 17px, 1.5 line-height |
| Typography mono | Söhne Mono 400 |
| Shadows | 0 2px 4px rgba(0,0,0,0.08), 0 16px 48px rgba(0,0,0,0.12) — warm, contained |
| Motion | easeOutQuint, 600-900ms, deliberate, no bounce |
| Icons | 1.5px stroke, sharp terminals, monoline |
| Texture | Subtle paper grain 8% opacity, vignette on hero imagery |
| Best fit | Premium DTC, hospitality, Creative-Production, luxury Pro Services, financial wealth |

## Archetype 3 — Soft Structuralism

| Dimension | Spec |
|---|---|
| Surfaces | Warm off-white (#F8F5F0), terracotta (#C56F4D), sage (#7A8B6B), muted block colors |
| Materials | Textured paper, ceramic, raw linen, soft-touch laminate |
| Typography heading | GT Alpina 500, Tiempos Headline 500, or Recoleta 500 |
| Typography body | Söhne Buch 400, 16-17px, 1.55 line-height |
| Typography mono | Berkeley Mono 400 |
| Shadows | 0 4px 12px rgba(80,60,40,0.10) — warm, soft |
| Motion | spring(damping=22, stiffness=160), 500-800ms, gentle bounce |
| Icons | 2px stroke, rounded, friendly |
| Texture | 12% paper texture overlay, occasional shape blocks |
| Best fit | DTC home/food/beauty, family-brand SaaS, healthcare-consumer, hospitality |

## Archetype 4 — Minimalist Editorial

| Dimension | Spec |
|---|---|
| Surfaces | True white (#FFFFFF), pure black (#000000), single accent (often #FF3B30 or #0066FF) |
| Materials | Glossy and matte juxtapositions, clean print |
| Typography heading | Inter 600 or Söhne Halbfett, tight tracking |
| Typography body | Inter 400, 15-16px, 1.5 line-height |
| Typography mono | Söhne Mono 400 |
| Shadows | None or 0 1px 2px rgba(0,0,0,0.06) — almost flat |
| Motion | easeInOut, 200-350ms, no decoration |
| Icons | 1.5px stroke, geometric, no flourish |
| Texture | None — pure geometry |
| Best fit | B2B SaaS, professional services (legal/consulting), tech-first DTC, AI tools |

## Archetype 5 — Industrial Brutalist

| Dimension | Spec |
|---|---|
| Surfaces | Concrete grays (#2A2A2A, #6B6B6B), safety yellow (#FFD400), exposed grids, raw rules |
| Materials | Concrete, raw steel, kraft paper, screenprint |
| Typography heading | Söhne Breit Kräftig, Druk Wide 700, or PP Mori Bold |
| Typography body | Söhne Buch 400, 15px, 1.4 line-height |
| Typography mono | IBM Plex Mono 500 |
| Shadows | 4px 4px 0 #000 hard-offset, no blur |
| Motion | linear or stepped, 150-300ms, snap transitions |
| Icons | 2.5-3px stroke, blocky, no rounding |
| Texture | Halftone, riso grain 20%, visible grid overlays |
| Best fit | Challenger DTC, agency-of-record (Ad-Commercial), youth/streetwear, dev-tool SaaS |

## Decision Matrix — Profile x Positioning -> Archetype

Rows: industry profile. Columns: positioning quadrant (Volume-Mass / Volume-Premium / Bespoke-Mass / Bespoke-Premium).

| Profile | Volume-Mass | Volume-Premium | Bespoke-Mass | Bespoke-Premium |
|---|---|---|---|---|
| B2B SaaS | Minimalist Editorial | Minimalist Editorial | Ethereal Glass | Editorial Luxury |
| DTC E-com | Soft Structuralism | Editorial Luxury | Industrial Brutalist | Editorial Luxury |
| Professional Services | Minimalist Editorial | Editorial Luxury | Soft Structuralism | Editorial Luxury |
| Regulated | Minimalist Editorial | Ethereal Glass | Minimalist Editorial | Editorial Luxury |
| Creative-Production | Soft Structuralism | Editorial Luxury | Industrial Brutalist | Editorial Luxury |
| Ad-Commercial | Industrial Brutalist | Editorial Luxury | Industrial Brutalist | Editorial Luxury |

When archetype recommendation is ambiguous or the brand has explicit aesthetic equity that contradicts the matrix, `brand-narrative` documents the override rationale in the brief.

## Output Schema (used in CreativeBrief)

```yaml
aesthetic_archetype:
  primary: "editorial-luxury"
  accent: null                            # optional, for hybrid asset
  surfaces:
    bg: "#0A0A0A"
    fg: "#F5F1EA"
    accent: "#8B6B3D"
  typography:
    heading: "Canela Deck 500"
    body: "Inter 400"
    mono: "Söhne Mono 400"
  motion:
    easing: "easeOutQuint"
    duration_ms: 700
  texture:
    type: "paper-grain"
    opacity: 0.08
  prompt_seed: "editorial luxury, matte black background, ivory typography..."
```

The `prompt_seed` is a free-text string consumed by ComfyUI / gemini-image prompt builders inside Hydra's `creative` squad. Keep it under 80 words.

## Anti-patterns

- Mixing archetypes without explicit accent declaration — produces visual drift.
- Choosing Industrial Brutalist for regulated industries (compliance friction).
- Choosing Editorial Luxury for high-volume DTC promo (cognitive mismatch).
- Allowing per-asset overrides without `style_notes` documentation.

## Reference

- Frontend-design tokens reference: `C:\AiAppDeployments\RLM-CLI-Starter\.claude\skills\frontend-design\` (downstream consumer).
- Hydra `creative` squad asset spec: `C:\AiAppDeployments\Hydra\squads\creative\squad.yaml`.
