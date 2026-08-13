---
name: experimentation-design
description: "Experimentation toolkit — A/B test design, sample-size from MDE+power, MAB, sequential testing, causal inference (DiD/synth-control/RDD), pitfalls, reporting template."
user-invocable: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
---

# Experimentation Design Skill

Owned by `analytics-experimentation`. Produces statistically defensible decisions about creative, copy, channel, audience, and lifecycle. Every experiment in MarketBliss must pre-register hypothesis, primary metric, MDE, power, and stopping rule before launch.

The `attribution-soundness` gate from `marketing-governance` enforces this.

## 1. A/B Test Design Checklist

For every A/B test:

- [ ] **Hypothesis** stated as a falsifiable prediction
- [ ] **Single variable** changed between control and treatment (or factorial design declared)
- [ ] **Primary metric** declared (one)
- [ ] **Secondary metrics** declared (1-3, observational only)
- [ ] **Guardrail metrics** declared (no-go thresholds)
- [ ] **Randomization unit** defined (user / session / account / device)
- [ ] **Sample size** calculated from MDE + power + alpha
- [ ] **Test duration** = max(sample-size duration, business-cycle min, novelty period)
- [ ] **Pre-registered** stopping rule (no peeking)
- [ ] **Segments to analyze** declared a priori (avoid p-hacking)

### Hypothesis Template
```
We believe that [change X]
will result in [metric Y moving by Z%]
because [theory of why].
We will know we are right when [observed result] within [time window].
```

## 2. Sample-Size Calculation

For a two-sided proportion test (conversion rate):

```
n_per_arm = 2 * (Z_{1-alpha/2} + Z_{1-beta})^2 * p_bar * (1 - p_bar) / delta^2
```

Where:
- alpha = significance level (typically 0.05)
- beta = 1 - power (power typically 0.80, sometimes 0.90)
- p_bar = (p_control + p_treatment) / 2
- delta = MDE (minimum detectable effect) = p_treatment - p_control

### Common Z-values
- Z_{0.975} = 1.96 (alpha=0.05 two-sided)
- Z_{0.80} = 0.84 (power=0.80)
- Z_{0.90} = 1.28 (power=0.90)

### MDE Selection Guidance
- DTC checkout-level test: MDE 3-5% (large baseline volume)
- Email subject-line test: MDE 5-10% (open-rate baseline 20-30%)
- B2B lead-form test: MDE 10-20% (low volume, large delta needed)
- Onboarding-flow test: MDE 5-15% (cohort-dependent)

### Worked Example
Conversion rate baseline 4%, MDE = 0.4 absolute points (10% relative), alpha=0.05, power=0.80:
```
p_bar = 0.042
n_per_arm = 2 * (1.96 + 0.84)^2 * 0.042 * 0.958 / 0.004^2
        ~= 19,700 per arm
```
At 10k sessions/day, 50/50 split: ~4 days to power. Round up to 7 (full week to control day-of-week effects).

## 3. Multi-Armed Bandit (MAB) — When to Choose

| Use A/B | Use MAB |
|---|---|
| Hypothesis-driven, want clear answer | Exploit-then-exploit, want to minimize regret |
| Need shareable result | Operating-mode optimization |
| One-shot decision | Continuous (multiple creatives in rotation) |
| Mature feature | Cold-start (e.g. recommendation engine) |
| Effects expected stable | Effects may drift |
| Need confidence interval | Need ongoing allocation |

### MAB Variants
- **Epsilon-greedy**: explore with prob epsilon, exploit otherwise
- **Thompson Sampling**: Bayesian, samples from posterior; preferred default
- **UCB (Upper Confidence Bound)**: deterministic optimism
- **Contextual bandits**: when user features should personalize

MAB is NOT a replacement for A/B when the goal is learning. Use A/B for the decision; MAB for the always-on rotation that follows.

## 4. Sequential Testing & Peeking

Standard A/B test math assumes one look at the data. Peeking inflates false-positive rate.

### Solutions
- **Pre-registered sample size**: do not look until n reached (purist)
- **Optimizely-style mSPRT / Sequential Likelihood Ratio**: adjusted p-value at every look
- **Always-valid p-values (Howard et al.)**: confidence sequences
- **Group sequential design** (O'Brien-Fleming, Pocock): pre-specified interim looks

Default in MarketBliss: pre-register sample size; if peeking is required (executive pressure), use mSPRT.

## 5. Causal Inference Patterns

When randomization is not possible (geo-level, non-randomizable channels):

### Difference-in-Differences (DiD)
- Pre/post in treatment and control
- Identifying assumption: parallel trends before treatment
- Estimate: (Y_post,treat - Y_pre,treat) - (Y_post,ctrl - Y_pre,ctrl)
- Best for: geo rollouts, policy changes, channel launches

### Synthetic Control (Abadie et al.)
- Construct weighted combination of untreated units to mimic treated unit pre-treatment
- Compare post-treatment treated unit vs synthetic
- Best for: single-unit treatments (one geo, one customer segment)

### Regression Discontinuity (RDD)
- Treatment assigned by threshold on a continuous score
- Compare just-above-threshold to just-below
- Best for: loyalty-tier thresholds, credit-score cutoffs, eligibility cutoffs

### Instrumental Variables (IV)
- Variable that affects treatment but only affects outcome through treatment
- Useful when treatment is endogenous
- Rare in marketing; useful for media-channel-spend natural experiments

## 6. Common Pitfalls

| Pitfall | Mitigation |
|---|---|
| Peeking | Pre-register sample size; use mSPRT if peeking unavoidable |
| Multiple comparisons | Bonferroni, BH-FDR, pre-register family of tests |
| Novelty effect | Run >=1 week; analyze early vs late period |
| Primacy effect | Filter out first session per user |
| Network effects | Cluster-randomize (geo or account level) |
| Sample ratio mismatch (SRM) | Check randomization daily; SRM = test invalid |
| Simpson's paradox | Pre-specify subgroup analyses; check stratified results |
| Survivorship bias | Define cohort at randomization, not at analysis |
| Outcome window too short | Match window to user behavior cycle |
| Underpowered tests | Reject low-MDE asks; aggregate or postpone |

## 7. Reporting Template

```markdown
# Experiment Report — <experiment_id>

## Hypothesis
<falsifiable prediction>

## Design
- Primary metric: <name + definition>
- Secondary metrics: <list>
- Guardrails: <list with thresholds>
- Randomization unit: <user/session/account>
- Sample size target: <per arm>
- MDE (relative): <%>
- Alpha: 0.05; Power: 0.80
- Stopping rule: <pre-registered>
- Duration: <start -> end>

## Result
- N per arm: <actual>
- SRM check: <pass/fail + p-value>
- Primary metric:
  - Control: <value + 95% CI>
  - Treatment: <value + 95% CI>
  - Delta: <absolute and relative + p-value>
- Secondary metrics: <table>
- Guardrail status: <pass/fail per metric>

## Decision
[ship] [hold] [revert] [iterate]

## Rationale
<2-4 sentences>

## Follow-up
- <next experiment>
- <segments to investigate>
```

## 8. Pre-Registration

Every experiment writes a pre-registration to `output/campaigns/<id>/measurement/preregistrations/<exp_id>.md` BEFORE launch. The `attribution-soundness` gate validates:

- Pre-registration exists
- Sample size, MDE, power, alpha declared
- Stopping rule declared
- Primary metric is one (not "any of these")
- Subgroup analyses listed if any

Missing or post-hoc changes to pre-registration -> gate fails.

## 9. Output Deliverables

- `output/campaigns/<id>/measurement/preregistrations/<exp_id>.md` — pre-registered design
- `output/campaigns/<id>/measurement/experiments/<exp_id>.md` — final report
- `output/campaigns/<id>/measurement/experiment-log.md` — index of all tests

## References

- `marketing-attribution` (causal methods for non-A/B contexts)
- `audience-segmentation` (cohorts as randomization units)
- `lifecycle-marketing` (lifecycle A/B specifics)
- `marketing-governance` (attribution-soundness gate)
