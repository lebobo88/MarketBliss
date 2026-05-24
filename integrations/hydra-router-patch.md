# Hydra router patch — MarketBliss keyword fingerprints

## Purpose

MarketBliss ships 5 Hydra squad packs (`marketing-research`,
`marketing-strategy`, `marketing-creative`, `marketing-production`,
`marketing-ops`) under `C:\AiAppDeployments\MarketBliss\squads\`. For
Hydra's router to deterministically route marketing prompts to the right
squad — instead of falling through to the LLM-fallback classifier — its
`_KEYWORDS` dict needs 5 new tuples.

The router lives at:

```
C:\AiAppDeployments\Hydra\hydra_core\router.py
```

The `_KEYWORDS` dict is defined near the top of the file (around line 25).
This document specifies the exact additions and the verification steps.

## The 5 keyword tuples

Add these entries to `_KEYWORDS`:

```python
"marketing-research": (
    "market research", "competitor", "competitive intel", "TAM", "SAM", "SOM",
    "persona", "audience", "segment", "ICP", "SERP", "keyword", "topic cluster",
    "trends", "industry analysis",
),
"marketing-strategy": (
    "campaign strategy", "go-to-market", "GTM", "positioning", "channel mix",
    "marketing plan", "campaign brief", "OKR", "marketing OKR",
    "marketing budget", "demand generation", "demand gen", "ABM",
    "funnel strategy",
),
"marketing-creative": (
    "copywriting", "creative", "brand voice", "tagline", "headline", "ad copy",
    "landing page copy", "marketing copy", "brand narrative", "aesthetic",
    "tone of voice", "messaging framework", "creative brief",
),
"marketing-ops": (
    "media buying", "bid", "PPC", "paid media", "budget allocation",
    "media plan", "MMM", "MTA", "attribution", "lifecycle marketing",
    "email marketing", "CRM", "marketing automation", "A/B test",
    "conversion rate optimization", "CRO",
),
"marketing-production": (
    "shoot", "shot list", "production plan", "shoot day", "location scout",
    "talent release", "model release", "music license", "stock footage",
    "IP clearance", "post-production", "cinematographer", "DP",
    "director of photography", "storyboard", "scheduling", "production budget",
    "production schedule", "permit", "crew", "gaffer", "grip",
),
```

Notes on a few keywords that overlap with existing tuples:

- `"competitive intel"` already appears in the `sales-gtm` tuple. Both will
  fire; the industry-tag boost in `classify_intent()` (line ~96) breaks the
  tie when the prompt also carries a marketing industry tag.
- `"OKR"` is unique to `marketing-strategy` because the existing
  `executive` tuple uses the lowercase `"okr"` and Python's `_KEYWORDS`
  comparison is performed against `text.lower()` (router.py line 84). The
  matcher will treat them as identical — expect both to score; again the
  industry-tag boost decides.
- `"ICP"` is also in `sales-gtm`. Same tie-break.

## Patch instructions

1. Open `C:\AiAppDeployments\Hydra\hydra_core\router.py`.
2. Locate the `_KEYWORDS = {` block (around line 25).
3. Add the 5 tuples above as new keys inside the dict (order doesn't matter;
   convention is to append at the end before the closing `}`).
4. Save.
5. If the Hydra daemon is running and caches the module in memory, restart it:
   ```
   hydra restart
   ```
   Otherwise the next `hydra run` invocation will pick up the change on import.

## Verification

After applying the patch:

```
# 1) Discovery — all 5 marketing-* squads must appear
hydra squads | grep marketing-

# 2) Strategy routing
hydra run "design a B2B SaaS demand-gen campaign"
#   expected: routes to marketing-strategy (keywords: 'demand gen', 'campaign')

# 3) Research routing
hydra run "research the competitive landscape for vertical X"
#   expected: routes to marketing-research (keywords: 'competitor', 'competitive')

# 4) Creative routing
hydra run "write landing page copy for our new pricing page"
#   expected: routes to marketing-creative (keywords: 'landing page copy', 'copy')

# 5) Ops routing
hydra run "reallocate budget across paid channels using MMM"
#   expected: routes to marketing-ops (keywords: 'budget allocation', 'paid media', 'MMM')

# 6) Production routing
hydra run "build shot list and schedule for the Q3 product launch video"
#   expected: routes to marketing-production (keywords: 'shot list', 'schedule')
```

If any route falls through to LLM fallback (`used_fallback: true` in the
RoutingDecision), check that:

- the squad's `squad.yaml` declared its slug (must match the `_KEYWORDS` key);
- `industries:` in `squad.yaml` matches the MarketBliss industry profile tags
  (see `profiles/*.yaml#industry_tags`);
- the prompt actually contains one of the listed keywords as a **whole word**
  (the router uses `\b...\b` boundaries at line 91).

## Optional v2 enhancements

1. **Industry-tag boosting** — already supported. Each MarketBliss squad
   declares `industries: [marketing, b2b, dtc, ...]` in its `squad.yaml`;
   the router boost at router.py ~line 96 picks these up automatically. No
   code change needed — just confirm the squad YAMLs are correct.
2. **LLM-fallback prompt update** — when adding 5 new domains, update the
   LLM classifier's prompt to include the new squad descriptions so the
   fallback path is also accurate.
3. **Per-squad weight tuning** — if marketing prompts consistently
   under/over-score relative to other domains, adjust the `0.2 + 0.15 * hits`
   coefficient (router.py line 93) on a per-domain basis (would require a
   small refactor).

## Rollback

Just remove the 5 tuple entries from `_KEYWORDS`. The squads will still
discover via `hydra squads` (they're loaded from the filesystem, not the
router), but routing falls back to LLM classification or industry-tag-only
matching. No data loss; no daemon-state migration required.
