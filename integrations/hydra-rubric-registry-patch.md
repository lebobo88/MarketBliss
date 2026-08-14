# Hydra rubric registry patch — MarketBliss

The source files in `plugins/marketbliss/rubrics/` define the following
MarketBliss-owned immutable IDs: `marketing-brief-clarity@1`,
`creative-brief-completeness@1`, `attribution-soundness@1`,
`regulated-claims-check@1`, `brand-consistency@1`,
`experimentation-design@1`, `shot-list-coverage@1`,
`production-plan-completeness@1`, and `ip-clearance@1`.

Hydra currently rejects these IDs because its static registry has no matching
entries. Register matching immutable bodies in
`Hydra/hydra_core/judge/registry.py`, with registry coverage tests, before
enabling the corresponding judge stages. This source pack intentionally does
not modify Hydra directly.
