---
name: principle-design-for-partial-failure
description: "Apply when code calls anything over a network or a rate-limited API: HTTP services, databases, queues, Discord, LLM providers, Roblox DataStores, Workers subrequests. Bound every wait, retry only what is safe to repeat, and make every handled failure visible."
disable-model-invocation: true
---

# Design for Partial Failure

Any call that leaves the process can be slow, fail, or be refused. Decide each outcome before it happens.

- Every call has a timeout, shorter than the timeout of whatever waits on it.
- Retry only operations that are safe to repeat (the **make-operations-idempotent** principle), with capped exponential backoff and jitter. Honor `Retry-After` and 429 responses.
- Rate limits and quotas are part of the spec. Design to the documented limit, not around the first 429.
- Decide what the user gets while the dependency is down (an error, stale data, or a queued retry), and write it as a deliberate branch.
- Every handled failure leaves a trail: one structured log line with the operation, the target, and a request or interaction ID. A swallowed error is a bug.
