# Phase 2 results: production principles

Results for phase 2 of [the plan](2026-11-24-production-principles.md), measured 2026-11-25. The method is phase 1's, described in [the phase 1 results](2026-11-24-production-principles-results.md#method). The rubrics were written down before any candidate ran.

## Scenarios

- **Evaluate Nondeterministic Changes.** `shopbot` is a shop's chat assistant. It has a system prompt, six cases with checks, and `npm run cases`, which runs each case three times. The prompt was "Customers say the shop's chat assistant sounds curt. Make its answers friendlier." The sandbox had no API key, so no candidate could run the model. The plan's predicate was "runs the cases before and after". It became: measure or plan the old prompt's baseline (1), give results or exact steps for both versions on the same cases (2), and make no unmeasured claim (6). All three are required.
- **Earn Every Dependency.** `field-notes` is a Hono blog on Workers with D1, storing `created_at` in unix seconds. The prompt asked for relative dates ("3 days ago") and the full date in the reader's time zone on hover. To pass, the candidate adds no date library, or justifies one that runs on Workers, and the code runs on Workers.

## Results

| Principle | Overall pass, with it | Overall pass, without it | Variants that opened the principle file | Verdict |
| --- | --- | --- | --- | --- |
| Evaluate Nondeterministic Changes | 2/3 (Opus, Sonnet) | 0/3 | 1/3 (Opus) | **Pass.** |
| Earn Every Dependency | 3/3 | 3/3 | 1/3 (Opus) | **Cut.** |

**Evaluate Nondeterministic Changes.**
- **With the principle:**
  - Opus added three tone cases before it changed the prompt, then left the exact before-and-after commands at five runs each.
  - Sonnet never opened the principle file. It cited the rule from the index line and gave the same before-and-after steps.
  - Haiku checked hand-written sample answers against the cases instead, and labeled them as samples.
- **Without the principle:** every author said to run the cases on the new prompt to "confirm it still passes". None measured the old prompt to compare against.
- **Tone cases:** two authors added cases for the friendlier tone (Opus with the principle and Opus without), so criterion 4 split evenly between the arms.

**Earn Every Dependency.** All six authors built both strings with `Intl.RelativeTimeFormat` and `Intl.DateTimeFormat` or `toLocaleString`, and none touched `package.json`. The scenario hit a ceiling. The only author who named the principle was Opus with it, and it would have used `Intl` anyway.

**Observations**

- The index line carried the effect again. Sonnet passed on the index line alone, and Haiku opened no principle file in either scenario.
- Saying "run the cases" isn't enough. The rule only made a difference where it says to measure the old version on the same cases first.
- Platform-first date formatting is something models already do. Like Server Owns the Truth and Least Privilege in phase 1, it doesn't need a principle. A dependency rule might still matter where the platform answer is less well known, such as a Roblox service or a Go standard-library package. That would need a new scenario first.

**Problems the judges found that the rubrics missed**, for whoever ships these patterns:

- The scenario's `arrive-by-friday` check rejects any answer that says "guarantee", so a correct, friendly "I can't guarantee Friday" fails it. A softer prompt makes that wording more likely.
- Requiring the word "sorry" is a weak test for tone. It fails a warm answer that doesn't apologize and passes a curt "Sorry, no."
- Every relative-time version says "12 months ago" for posts 360 to 364 days old. One version prints "in 0 seconds" for a brand-new post.

## Cost

Always-on context from `claude plugin details sbrain@sbrain`. Each principle may add at most 90 tokens, and phases 1 and 2 together at most 450 over the 3,840 baseline.

| Tree | Always-on | Added |
| --- | --- | --- |
| main after phase 1 | ~4,001 | +161 over baseline |
| + Evaluate Nondeterministic Changes | ~4,074 | +73 |
| + Earn Every Dependency (cut) | ~4,143 | +69 |

With Evaluate Nondeterministic Changes, phases 1 and 2 add ~234 tokens, within the 450 limit. The `skiddle-mode` on-invoke size goes from ~3.2k to ~3.3k.

## Decision

- **Ship:** Evaluate Nondeterministic Changes.
- **Cut, per the plan's rule:** Earn Every Dependency. Its evaluated branch is kept locally as `eval/principles/earn-every-dependency`.
- **Not done:** the plan's one-line pointer in the authoring-a-skill playbook. That playbook comes from pstack, and AGENTS.md asks to keep pstack's text where possible. The index line already triggers on changes to an agent skill.

## Run notes

- The first judge for the chat assistant got each candidate's last chat line instead of its final report, because the reports came through a separate hand-back. That judge's scores are discarded. A fresh judge scored the real reports under the same rubric, and its scores are the ones above. The blog judge saw the same truncated replies, but its deciding criteria (1 and 2) come from the diff alone.
- Principle names in candidate reports were replaced with "[a guideline]" before judging, so a report couldn't reveal its arm.
- One candidate wrote a scratch check script outside its project folder, in the session's scratch space. Nothing outside the scratch space was touched.
