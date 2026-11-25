---
name: principle-old-and-new-run-together
description: "Apply when changing anything that outlives one deploy: database schemas, stored records (including game saves), cache and message formats, config, and APIs that deployed clients call (bots, desktop and mobile apps, live game servers). Every change must work while old and new code run side by side."
disable-model-invocation: true
---

# Old and New Run Together

During a rollout, the old code and the new code run at the same time and share the same data. Some clients never update.

- Expand, migrate, contract. Add the new shape, move every reader and writer to it, and remove the old shape in a later deploy, once nothing reads or writes it.
- Never rename or retype a stored field in place. Add the new one and have new code write both. Backfill in batches that can resume, once no running instance writes only the old one (or a sync trigger copies its writes). Then move readers over, and drop the old one once nothing reads or writes it, removing any sync trigger first.
- Version the records you read back later (game saves, cached JSON, queued messages). New code reads old versions, and old code tolerates the new version before anything writes it, because old instances and a rollback will read it.
- Keep a rollback that still works after the new code has written data.
- Outcome-Oriented Execution allows planned breakage inside code you deploy at once. It never covers data or contracts that outlive a deploy.
