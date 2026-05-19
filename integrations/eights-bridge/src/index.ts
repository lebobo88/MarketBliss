/**
 * MarketBliss <-> TheEights bridge (v1 stub)
 * =========================================
 *
 * This file is a placeholder. In v1, MarketBliss integrates with TheEights by
 * calling the `mcp__eights__*` MCP tools directly from agent sessions. There
 * is no in-process daemon hookup yet.
 *
 * In v2, this file becomes a real bridge that mirrors the pattern used by
 *   - C:\AiAppDeployments\TheEights\daemon\src\adapters\pp-bridge.ts
 *   - C:\AiAppDeployments\TheEights\daemon\src\adapters\execsuite-bridge.ts
 *
 * Responsibilities in v2:
 *   1. Listen to MarketBliss `progress/events.jsonl` and `output/` writes.
 *   2. Normalize each event into an Eights `Envelope` and call
 *      `eights.memory.add` / `eights.evolution.propose` with appropriate scopes.
 *   3. Resolve `MemoryRef` handles back into artifact paths under `output/`.
 *   4. Surface HITL escalations for `critical`-risk resource changes
 *      (brand-voice, regulated-claims rules, gate definitions).
 *
 * NOTE: deps are NOT installed in v1. Type imports are commented out so this
 * file remains syntactically valid as a reference skeleton.
 */

// import type {
//   Envelope,
//   MemoryAdd,
//   EvolutionPropose,
//   MemoryRef,
//   HITLRequest,
// } from '@eights/sdk';

export const MARKETBLISS_PROJECT_ID = 'marketbliss';
export const DOMAIN = 'marketing';
export const DEFAULT_SCOPES: readonly string[] = [
  'public',
  'team:marketing',
  'sensitive:no',
];

/**
 * The 15 MarketBliss agent slugs from AGENTS.md §4
 * (12 v1 specialists + 3 Phase J production-squad additions).
 * Each registers as a distinct actor under project_id=marketbliss.
 */
export const ACTOR_SLUGS: readonly string[] = [
  'marketing-supervisor',
  'market-intelligence',
  'audience-persona',
  'seo-analyst',
  'campaign-strategist',
  'analytics-experimentation',
  'contextual-copywriter',
  'brand-narrative',
  'media-buyer-bidder',
  'lifecycle-crm',
  'brand-safety-compliance',
  'memory-steward',
  // Phase J — marketing-production squad
  'executive-producer',
  'shot-list-designer',
  'talent-ip-coordinator',
] as const;

/**
 * TODO(v2): registerProject
 * -----
 * Calls eights.identity.register_project with:
 *   { name: 'marketbliss', domain: 'marketing', scopes_default: DEFAULT_SCOPES }
 * Idempotent — safe to call on daemon startup.
 */
export async function registerProject(): Promise<string> {
  // TODO(v2): replace with real MCP client call.
  throw new Error('v1 stub — use mcp__eights__eights_identity_register_project directly');
}

/**
 * TODO(v2): registerActors
 * -----
 * Iterates ACTOR_SLUGS, calling eights.identity.register_actor for each:
 *   { name: <slug>, kind: 'agent', parent: 'marketbliss' }
 * Idempotent.
 */
export async function registerActors(): Promise<string[]> {
  // TODO(v2): replace with real MCP client call.
  throw new Error('v1 stub — use mcp__eights__eights_identity_register_actor directly');
}

/**
 * TODO(v2): recordCampaignDecision
 * -----
 * Writes a campaign-level decision (CreativeBrief approval, KPI snapshot,
 * gate verdict, DecisionRecord) into episodic memory.
 *
 * record: {
 *   campaign_id: string,
 *   kind: 'brief' | 'kpi_snapshot' | 'gate_verdict' | 'decision_record',
 *   summary: string,
 *   memory_refs: string[],            // pointers to artifacts in output/
 *   industry_profile: string,         // matches profiles/<id>.yaml
 *   regulated: boolean,               // upgrades scope to 'sensitive:yes'
 * }
 */
export async function recordCampaignDecision(record: Record<string, unknown>): Promise<string> {
  // TODO(v2): construct Envelope + MemoryAdd, call eights.memory.add(type='episodic').
  void record;
  throw new Error('v1 stub — use mcp__eights__eights_memory_add directly');
}

/**
 * TODO(v2): proposePromptEvolution
 * -----
 * Submit a prompt / persona / rubric drift candidate to the evolution engine.
 *
 * Routing rules (per AGENTS.md §8):
 *   - low-risk (docs prompts, example libraries) -> auto-commit
 *   - medium (agent persona tweaks, channel-mix priors) -> HITL queue
 *   - critical (brand voice, regulated-claims rules) -> HITL only, never auto
 */
export async function proposePromptEvolution(
  rid: string,
  candidate: string,
  justification: string,
): Promise<string> {
  // TODO(v2): call eights.evolution.propose with evidence memory ids.
  void rid; void candidate; void justification;
  throw new Error('v1 stub — use mcp__eights__eights_evolution_propose directly');
}

async function main(): Promise<void> {
  throw new Error('v1 stub — use mcp__eights__* MCP tools directly');
}

// Run when invoked as a script (no-op in v1).
if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((err) => {
    console.error(err);
    process.exit(1);
  });
}
