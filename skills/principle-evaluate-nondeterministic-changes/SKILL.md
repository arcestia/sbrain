---
name: principle-evaluate-nondeterministic-changes
description: "Apply when changing anything whose output varies run to run: a prompt, a model or its settings, an agent skill, or randomized game logic. Run the old and the new version on the same fixed cases, several runs each, before you trust the change."
disable-model-invocation: true
---

# Evaluate Nondeterministic Changes

One good output proves nothing when the next run can differ.

- Keep a fixed set of cases, each with the property its output must show (mentions the policy, refuses, stays under a word limit, parses as JSON). Check the property in code where you can.
- Measure the current version on that set before you change it. Then run the new version on the same cases with the same settings, several runs per case.
- Report both pass rates with their run counts, such as 11/15 before and 14/15 after. Then apply **explain-the-number** before you trust the gap.
- A new requirement gets its own cases before the change, and every failure you fix becomes a case.
- If you can't run the cases, say so, and leave the exact before-and-after commands. Never call the change better because it reads better.
