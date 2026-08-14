# MarketBliss Claude Code Hooks

This is the canonical Claude Code plugin hook location for MarketBliss.

The former repository-root `hooks.json` was not loaded as a Claude Code plugin
hook, and its supposed guards were no-op placeholders. The Phase 3
`PreToolUse` handler now denies edits to sealed briefs, clearly destructive
shell operations, and Eights evolution proposals without a DecisionRecord or
HITL context reference. Run `../scripts/test-pre-tool-guard.ps1` to exercise
the accepted and denied fixtures.

The canonical protected campaign artifact is
`output/campaigns/<campaign-id>/brief.md` after its brief gate is signed off.
The plugin runs as a Hydra source pack, so cross-pack provider resolution is
declared in `../contracts/ecosystem-dependencies.json`.
