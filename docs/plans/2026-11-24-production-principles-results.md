# Phase 1 results: production principles

Results for [the plan](2026-11-24-production-principles.md), measured 2026-11-24.

## Method

Each principle was tested blind, per the Eval playbook. Each scenario is a small, realistic project (a Roblox shop, a discord.js bot, a Hono and Drizzle service, a Workers app) with an ordinary prompt. Three candidates (Opus, Sonnet, Haiku) got the skill tree with the principle. Three got the tree one commit earlier, without it. Each candidate received the standard `skiddle-mode` delegate kickoff and nothing that mentioned an evaluation. One Opus judge graded the six diffs under shuffled labels against a fixed rubric. A candidate's reads were checked from its transcript, not its own report. Every judge was a Claude model like the candidates, so the panel's model diversity is reduced.

## Results

| Principle | Overall pass, with it | Overall pass, without it | Variants that opened the principle file | Verdict |
| --- | --- | --- | --- | --- |
| Old and New Run Together | 2/3 (Opus, Sonnet) | 1/3 (Opus) | 2/3 | **Pass.** Sonnet moved from an in-place `RENAME COLUMN` to add, backfill, and sync with a trigger. |
| Design for Partial Failure | 0/3 | 0/3 | 1/3 | **Strict fail, partial effect.** Every author failed the 429 and `Retry-After` criterion. On the principle's other rules, timeouts went from 1/3 to 3/3 and logs with context from 1/3 to 2/3. |
| Server Owns the Truth | 3/3 | 3/3 | 1/3 | **Cut.** Every model already prices on the server and checks the balance. No author added the server-side rate guard the principle asks for. |
| Least Privilege | 3/3 | 3/3 | 2/3 | **Cut.** Every model already keeps the key in a Worker secret. Only the Opus variant also capped input size and ignored `.dev.vars` in git. The planned scenario also covered Discord bot intents, but the run left that half out, so this test was weaker than planned. |

**Observations**

- The one-line index entries carry most of the effect. Only 6 of 12 variant candidates opened their principle's file, and no Haiku candidate opened one. Several cited a principle by name from the index alone.
- A principle earns its place where models don't already know the rule. Pricing on the server and keeping keys server-side are well known, so those scenarios hit a ceiling. Rolling-deploy safety and network timeouts are not, so those principles changed behavior.
- A rule inside a principle can miss even when the principle works. No candidate acted on "Honor `Retry-After` and 429 responses", or on Server Owns the Truth's rule to bound request rates.

**Problems the judges found that the rubrics missed**, for whoever ships these patterns:

- The backfill in the trigger-based renames holds a table lock for the whole migration.
- The sync trigger references the old column, so it must be dropped before that column is.
- Some `/weather` replies echo the user's city without `allowedMentions`.
- No summary endpoint was rate limited or authenticated.

## Cost

Always-on context from `claude plugin details sbrain@sbrain`. The limit was at most 90 tokens per principle and at most 450 in all.

| Branch | Always-on | Added |
| --- | --- | --- |
| trunk | ~3,840 | |
| + Server Owns the Truth | ~3,923 | +83 |
| + Design for Partial Failure | ~3,999 | +76 |
| + Old and New Run Together | ~4,084 | +85 |
| + Least Privilege | ~4,164 | +80 |

The `skiddle-mode` on-invoke size went from ~3.1k to ~3.3k tokens (rounded), within its 600-token limit.

## Decision

- **Ship:** PR0 (the index check) and Old and New Run Together.
- **Kept by the operator (2026-11-25):** Design for Partial Failure, for its effect on timeouts and failure logs. Its `Retry-After` rule showed no effect, so it is the first candidate to cut if a later eval still shows none.
- **Cut, per the plan's rule:** Server Owns the Truth and Least Privilege. Their evaluated branches are kept locally as `eval/principles/*`.
- **Re-test before reviving them:** Least Privilege with the Discord intents scenario, and Server Owns the Truth with a scenario that models get wrong without help.

## Sandbox notes

- Two weather-bot candidates type-checked against discord.js's type definitions, borrowed read-only from another local project. That project was confirmed unchanged afterward.
- One judge made live requests to the public Open-Meteo API to check how it answers unknown cities.
