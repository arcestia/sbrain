---
name: principle-design-for-partial-failure
description: "Apply when code calls anything over a network or a rate-limited API: HTTP services, databases, queues, Discord, LLM providers, Roblox DataStores, Workers subrequests. Bound every wait, retry only what is safe to repeat, and make every handled failure visible."
disable-model-invocation: true
---

# Design for Partial Failure

Any call that leaves the process can be slow, fail, or be refused. Decide each outcome before it happens.

- Every call has a timeout, shorter than the timeout of whatever waits on it.
- Retry only operations that are safe to repeat (the **make-operations-idempotent** principle), and only failures that can clear (timeouts, 429, 5xx, not 400 or 404), with capped exponential backoff and jitter. Honor `Retry-After` and 429 responses. Stop retrying when the caller's deadline would pass.
- Rate limits and quotas are part of the spec. Design to the documented limit, not around the first 429.
- Decide what the user gets while the dependency is down (an error, stale data, or a queued retry), and write it as a deliberate branch.
- Every handled failure leaves a trail: one structured log line with the operation, the target's host and route (never a token, key, or credential from its URL or headers), and a request or interaction ID. A swallowed error is a bug.
