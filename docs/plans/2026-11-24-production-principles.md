# Plan: production principles for the work SBrain actually does

**Goal.** Add principles that cover the variety of work SBrain runs on (web apps, game servers, Roblox, Discord bots, gateways, edge workers, native apps, AI features), not only how the agent writes code.

**Status (2026-11-25).** Phase 1 has landed. PR0 is [arcestia/sbrain#1](https://github.com/arcestia/sbrain/pull/1), PR3 (Old and New Run Together) is [#2](https://github.com/arcestia/sbrain/pull/2), and PR2 (Design for Partial Failure) is [#3](https://github.com/arcestia/sbrain/pull/3). PR2 failed the strict pass rule and was kept for its partial effect. PR1 (Server Owns the Truth) and PR4 (Least Privilege) were cut, because both arms of their evals passed. Phase 2 and PR7 have not started. [The results](2026-11-24-production-principles-results.md) hold the evidence. The checklists below are the original plan, not a record of what passed.

## What changes

pstack's 24 principles govern how the agent works: scope, sequencing, verification, delegation. None governs how a running system behaves once it ships. Your projects need four rules the set lacks, and two more where the evidence is thinner.

| Need | Evidence from your work | Closest existing principle | Why it falls short |
| --- | --- | --- | --- |
| Who may change state | Roblox games (13 prompts), Simplymmo game server, Next.js Server Actions, Discord commands | Boundary Discipline | Checks the shape of input, not whether the caller may do the thing |
| Calls that fail or stall | Discord-Bot, aeria-gateway, LLM calls, Workers subrequests | Make Operations Idempotent | Makes a retry converge, but says nothing on timeouts, backoff, rate limits, or degraded behavior |
| Data and clients that outlive a deploy | aeria-gateway (24 SQL files), NDS-Project (Drizzle), Roblox saves, Mac-Tracker app versions | Outcome-Oriented Execution | Allows planned intermediate breakage, which is wrong for data and deployed clients |
| Secrets and permissions | Bot tokens and intents, Cloudflare tokens, database users, keys in LLM prompts | none | No principle covers it |
| Output that varies run to run | AI and agent work (13 prompts), SBrain's own skills | Explain the Number | Governs a number you have, not the duty to measure before trusting a prompt change |
| New packages and services | npm-heavy projects, the Workers runtime, Roblox without npm | Laziness Protocol | Minimizes the diff, not the dependency surface |

**Not principles.** These needs are specific to one stack, so they belong in skills, the way the language skills work. Each is a follow-up candidate, outside this plan.

- Roblox and Luau: RemoteEvent patterns, DataStore budgets, session locking. A `luau-best-practices` skill.
- Python (Simplymmo), with tick loops and asyncio. A `python-best-practices` skill.
- Swift (Mac-Tracker). A `swift-best-practices` skill.
- Discord bots: intents, the three-second interaction acknowledgment, sharding. A `discord-bots` skill.
- Cloudflare Workers is already covered by the Cloudflare skills installed in your Claude Code.

## PRs in landing order

| PR | Title | Phase | Depends on | Review-gated |
| --- | --- | --- | --- | --- |
| PR0 | `chore(check): enforce the principle index` | 1 | trunk | no |
| PR1 | `feat(principles): server owns the truth` | 1 | PR0 | yes |
| PR2 | `feat(principles): design for partial failure` | 1 | PR1 | yes |
| PR3 | `feat(principles): old and new run together` | 1 | PR2 | yes |
| PR4 | `feat(principles): least privilege` | 1 | PR3 | yes |
| PR5 | `feat(principles): evaluate nondeterministic changes` | 2 | PR4 | yes |
| PR6 | `feat(principles): earn every dependency` | 2 | PR5 | yes |
| PR7 | `docs: release the production principles` | 2 | PR4 (and PR6 if phase 2 runs) | no |

**Dependency graph.** PR0 branches from trunk. PR1 through PR6 stack in order, because each appends one line to the same block of `skills/skiddle-mode/SKILL.md`, and stacking keeps that shared block conflict-free. Phase 2 (PR5, PR6) can be dropped without touching phase 1. PR7 lands last.

**Files each PR may touch.**

- PR0: `scripts/check.sh`, `AGENTS.md`, `CONTRIBUTING.md`.
- PR1 to PR6: its own new `skills/principle-<name>/` folder (SKILL.md plus the generated `agents/openai.yaml`), the one "Production (SBrain)" block in `skills/skiddle-mode/SKILL.md`, and the consumer skills named in its section. No pstack principle leaf is edited, so upstream merges stay clean.
- PR7: `README.md`, `CHANGELOG.md`, `skills/skiddle-help/SKILL.md`, `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`.

## How every principle PR is verified

- **Unit.** `scripts/check.sh` passes. That covers frontmatter, the index coverage from PR0, the generated Codex opt-out, links, and `claude plugin validate`.
- **Live.** One blinded run per the Eval playbook (`skills/skiddle-mode/playbooks/eval.md`). Three candidates get an organic prompt in a sanitized scaffold with the new principle installed. Three control candidates get the same prompt without it. One blinded judge scores both sets against the PR's pass predicate. The PR passes when at least two of three variant candidates meet the predicate and the variant set beats the control set. Chain-following is graded from transcripts, not self-report.
- **Perf.** Context cost, from `claude plugin details sbrain@sbrain`. Trunk baseline: about 3,840 always-on tokens (measured 2026-11-24). A PR fails if it adds more than 90 always-on tokens. All of phase 1 and 2 together fails if it adds more than 450 (about 12%). The `skiddle-mode` on-invoke size is measured on trunk before PR1, and the Production block may not add more than 600 tokens.

## PR0. Enforce the principle index

- [ ] Depends on: trunk
- [ ] Edits: `scripts/check.sh`, `AGENTS.md`, `CONTRIBUTING.md`
- [ ] Builds: a check that every `skills/principle-*` folder appears in the `skiddle-mode` Principles index, and that every index entry resolves to a folder (by the index's own kebab-case rule, or the leaf name the entry gives). Every principle description must start with "Apply". This catches a principle that is written but never triggers.
- [ ] Result: deleting one index line, or adding a folder without one, makes `check.sh` fail and name the missing pair.
- [ ] Unit: `check.sh` passes on trunk, and fails on both seeded faults (a missing line, an orphan folder).
- [ ] Live: n/a (tooling only). Run the seeded faults by hand and paste the output into the PR.
- [ ] Perf: n/a.

## PR1. Server Owns the Truth

- [ ] Depends on: PR0
- [ ] Edits: `skills/principle-server-owns-the-truth/`, the Production block, and one line each in `react-best-practices` (Server Actions), `go-`, `rust-`, `ruby-`, `php-best-practices` (handlers), and `polyglot-boundaries`
- [ ] Builds the leaf. Draft:

  > **description:** Apply when code receives a request from a client (a browser, a game client, a bot user, another service) that changes shared state or grants something of value: currency, items, permissions, money, rank.
  >
  > - The client sends intent. The server decides, from its own state.
  > - Recompute every value the server already knows (price, damage, cooldown, ownership, balance). Never accept it from the request.
  > - Check the caller's right to act on this object at every entry point. A hidden button is not authorization.
  > - Bound every client-chosen number and rate (quantity, frequency, distance, size) to what a legitimate client can produce.
  > - Anything shipped to a client (a browser bundle, Roblox client scripts and ReplicatedStorage, a desktop app) is public and can be changed.
  > - Boundary Discipline checks the shape of input. This checks whether the caller may do the thing.

- [ ] Result: a task like "add a buy button" makes `skiddle-mode` price the item on the server and check ownership and balance there.
- [ ] Unit: `check.sh`.
- [ ] Live: scaffold a Roblox-style shop (a server script and a client script around a RemoteEvent), with the prompt "add a buy button that spends coins". Pass predicate: the server looks up the price from its own catalog, checks the balance on the server, and ignores any price or item ID the client cannot own.
- [ ] Perf: at most 90 always-on tokens.

## PR2. Design for Partial Failure

- [ ] Depends on: PR1
- [ ] Edits: `skills/principle-design-for-partial-failure/`, the Production block, and one line each in `go-best-practices` (context timeouts), `rust-best-practices`, and `react-best-practices` (fetch in Server Components)
- [ ] Builds the leaf. Draft:

  > **description:** Apply when code calls anything over a network or a rate-limited API: HTTP services, databases, queues, Discord, LLM providers, Roblox DataStores, Workers subrequests.
  >
  > - Every call has a timeout, shorter than the timeout of whatever waits on it.
  > - Retry only operations that are safe to repeat (the **make-operations-idempotent** principle), with capped exponential backoff and jitter. Honor `Retry-After` and 429s.
  > - Decide what the user gets when the dependency is down (an error, stale data, or a queued retry), and make it a deliberate branch.
  > - Every handled failure leaves a trail: one structured log line with the operation, the target, and a request or interaction ID. A swallowed error is a bug.
  > - Rate limits and quotas are part of the spec. Design to the documented limit, not around the first 429.

- [ ] Result: new network code ships with a timeout, a retry policy, a degraded path, and a log line.
- [ ] Unit: `check.sh`.
- [ ] Live: scaffold a discord.js bot command that calls an external HTTP API, with the prompt "add a /weather command". Pass predicate: the call has a timeout, retries only the GET with backoff, handles 429 using `Retry-After`, logs failures with the interaction ID, and replies to the user within Discord's acknowledgment window on failure.
- [ ] Perf: at most 90 always-on tokens.

## PR3. Old and New Run Together

- [ ] Depends on: PR2
- [ ] Edits: `skills/principle-old-and-new-run-together/`, the Production block (with a scope note next to Outcome-Oriented Execution), `polyglot-boundaries`, and the migration bullets in `ruby-best-practices` and `php-best-practices`
- [ ] Builds the leaf. Draft:

  > **description:** Apply when changing anything that outlives one deploy: database schemas, stored records (including game saves), cache and message formats, config, and APIs that deployed clients call (bots, desktop and mobile apps, live game servers).
  >
  > - During a rollout, the old code and the new code run at the same time. Every change must be readable and writable by both.
  > - Expand, migrate, contract. Add the new shape, move readers and writers to it, then remove the old shape in a later deploy.
  > - Never rename or retype a stored field in place. Add, backfill in batches that can resume, then drop.
  > - Version persisted records that you read back later (game saves, cached JSON) so that new code can read old versions.
  > - Keep a rollback that works after the new data has been written.
  > - **Scope note:** Outcome-Oriented Execution allows planned breakage inside code you deploy at once. It never applies to data or contracts that outlive a deploy.

- [ ] Result: a "rename this column" task becomes a multi-deploy plan, not an in-place rename.
- [ ] Unit: `check.sh`.
- [ ] Live: scaffold a Hono and Drizzle service, with the prompt "rename users.name to users.display_name". Pass predicate: the output adds a column, backfills it, switches reads and writes, and drops the old column in a separate step, and states the rollback.
- [ ] Perf: at most 90 always-on tokens.

## PR4. Least Privilege

- [ ] Depends on: PR3
- [ ] Edits: `skills/principle-least-privilege/` and the Production block
- [ ] Builds the leaf. Draft:

  > **description:** Apply when code or config holds a secret, a token, or a permission: API keys, bot tokens and gateway intents, OAuth scopes, database users, cloud and CI tokens, and anything placed in an LLM prompt.
  >
  > - Ask for the narrowest scope that works: the fewest bot intents, a read-only database role where reads suffice, a token scoped to one resource.
  > - Secrets live in the platform's secret store (`wrangler secret`, the CI secret store, the environment), never in code, logs, error messages, client bundles, or prompts.
  > - Anything that reaches a client is public. Keys that must stay secret stay on the server.
  > - Treat a secret that reached a log, a commit, or a chat as exposed. Rotate it, then remove it.

- [ ] Result: new integrations ship with minimal scopes and keys held server-side.
- [ ] Unit: `check.sh`.
- [ ] Live: scaffold a Workers app plus a Discord bot, with the prompt "add an AI summary feature using an LLM API". Pass predicate: the key is a secret binding, never in client code or logs; the bot requests only the intents the feature needs; and no secret appears in any prompt sent to the model.
- [ ] Perf: at most 90 always-on tokens.

## PR5. Evaluate Nondeterministic Changes (phase 2)

- [ ] Depends on: PR4
- [ ] Edits: `skills/principle-evaluate-nondeterministic-changes/`, the Production block, and the authoring-a-skill playbook's validation step (one line pointing at it)
- [ ] Builds the leaf. Draft:

  > **description:** Apply when changing anything whose output varies run to run: a prompt, a model, an agent skill, a sampling setting, or randomized game logic.
  >
  > - One good run proves nothing. Keep a fixed set of cases with the property each must show.
  > - Measure the current version on that set before you change it. Then compare the new version on the same cases.
  > - Report pass rates with run counts, then apply **explain-the-number** before you trust the gap.
  > - Turn every failure you fix into a new case.

- [ ] Result: prompt and skill changes come with a before-and-after on a case set.
- [ ] Unit: `check.sh`.
- [ ] Live: scaffold a bot with a system prompt and a short case file, with the prompt "make the bot's answers friendlier". Pass predicate: the output runs the existing cases before and after the change, and reports both.
- [ ] Perf: at most 90 always-on tokens.

## PR6. Earn Every Dependency (phase 2)

- [ ] Depends on: PR5
- [ ] Edits: `skills/principle-earn-every-dependency/` and the Production block
- [ ] Builds the leaf. Draft:

  > **description:** Apply when adding a package, an SDK, a framework feature, or an external service.
  >
  > - Check the standard library and the platform first (Go's standard library, the Workers runtime, Roblox services, `Intl`).
  > - The dependency must run where the code runs. Workers has no full Node runtime, Roblox has no npm, and edge bundles have size limits.
  > - Check maintenance, license, and size before you add it, and commit the lockfile change with it.
  > - One library per job. Don't add a second library for something one already in the repository does.

- [ ] Result: new dependencies arrive with a reason, and runtime fit is checked first.
- [ ] Unit: `check.sh`.
- [ ] Live: scaffold a Workers app, with the prompt "show dates as 'three days ago'". Pass predicate: the output uses `Intl.RelativeTimeFormat` or an existing dependency, or justifies a new one that runs on Workers.
- [ ] Perf: at most 90 always-on tokens.

## PR7. Release

- [ ] Depends on: PR4 (and PR6 if phase 2 runs)
- [ ] Edits: `README.md` (one line in the pstack-differences list), `CHANGELOG.md` (0.3.0), `skills/skiddle-help/SKILL.md` (the principles paragraph), and both manifests (version 0.3.0)
- [ ] Builds: release notes that name each new principle and when it applies.
- [ ] Unit: `check.sh` and `scripts/test-install.sh`.
- [ ] Live: `skiddle-help` answers "which principle covers Discord rate limits?" with Design for Partial Failure.
- [ ] Perf: the cumulative check, at most 450 always-on tokens over the 3,840 baseline.

## Still unproven

- Whether each principle changes agent behavior. Each PR's live eval is the test, and a principle that fails its eval should be cut, not reworded until it passes.
- The `skiddle-mode` on-invoke size. It is measured on trunk before PR1, not yet.
- Whether a Roblox-style scaffold is a fair stand-in for a real Roblox place. A real place can't be scripted from the shell. PR1's eval uses Luau files and the RemoteEvent pattern without Studio.
