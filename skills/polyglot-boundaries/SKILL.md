---
name: polyglot-boundaries
description: Change data that crosses a language or service boundary without breaking the other side. Use for any change to an HTTP, gRPC, or GraphQL API, a queue or event message, a webhook, or a database table that code in another language or service reads, such as a TypeScript frontend calling a Go, Rust, Ruby, or PHP backend.
disable-model-invocation: true
---

# Polyglot boundaries

Outside Cursor, read your agent's adapter in [`skiddle-mode/references/harness/`](../skiddle-mode/references/harness/README.md) once per session before you follow this skill. It maps the Cursor names in SBrain skills to your agent's tools.

Apply the **boundary-discipline** and **migrate-callers-then-delete-legacy-apis** principle skills. A boundary between two languages is where each side's type system stops seeing the other. The wire format is the only shared truth, so treat it as the design.

## Steps

1. **Find the contract.** Look for the source of truth: an OpenAPI spec, `.proto` files with `buf`, a GraphQL schema, JSON Schema, or a tRPC router. When none exists, the contract is implicit, split between a serializer on one side (a Laravel API Resource, a Rails serializer or Jbuilder view, Go struct tags, serde derives) and a type on the other. Name both files, and say in the reply that the contract is implicit.
2. **List every consumer.** Run **blast-radius** with every repository that reads the boundary in scope: web and mobile frontends, other services, jobs, webhook receivers, analytics, and data exports. A consumer you can't see is a risk to name in the reply, not one to assume away.
3. **Change the contract first.** Edit the spec or schema, then regenerate with the tool the repository already uses (for example `openapi-typescript`, `orval`, `oapi-codegen`, `buf generate`, `graphql-codegen`). Never hand-edit generated code. With an implicit contract, change the producer's serializer and the consumer's type in the same PR, or in stacked PRs that land in the order of step 5.
4. **Map each field across the languages.** Check every new or changed field against the table below before you write either side.
5. **Stay compatible: expand, migrate, contract.** Add new fields as optional, and make readers tolerate them before writers send them. Move every caller. Stop writing the old field before any reader stops accepting it. Delete it last. Never rename or retype a field in place. Write the deploy order into the PR's `## Blast Radius`.
6. **Prove both sides.** Run one real call through the real stack, with the frontend or client calling the running backend, and capture the serialized payload. Check that payload against the schema or the consumer's parser. Each side's unit tests passing on its own is not proof that the two sides agree.

## Crossings that break

| Data | What goes wrong | Do this |
|------|-----------------|---------|
| 64-bit integers and IDs | JavaScript numbers lose precision above 2^53, so a Go `int64`, a Rust `i64`, or a database bigint arrives wrong in the browser | Send them as strings (Go `json:",string"`, serde `DisplayFromStr` or a newtype, cast in Rails or Laravel serializers) |
| Money and decimals | Floats round | Integer minor units, or decimal strings with the currency |
| Time | Zone and precision drift. Go's zero `time.Time`, Ruby `Time` and `DateTime`, PHP Carbon, and JS `Date` all differ | RFC 3339 strings with an explicit offset, normalized to UTC. Never a bare epoch number without its unit in the field name |
| Null, absent, and empty | Go zero values (`""`, `0`) can't say "absent". PHP `null` differs from a missing key. TypeScript `?:` differs from `\| null` | Decide per field whether it can be absent, null, both, or neither. Go uses a pointer or `omitzero` deliberately. Rust uses `Option` with `skip_serializing_if`. The TypeScript type says exactly the same thing |
| Enums and unions | A new variant crashes an old consumer | String literals, and tagged unions with one discriminant field (`kind` or `type`): serde `#[serde(tag = "kind")]`, a Go type with custom JSON methods, a TypeScript discriminated union. Consumers handle an unknown variant without crashing |
| Field names | camelCase on one side and snake_case on the other drift apart one field at a time | Pick one casing per API and set it in the serializer (serde `rename_all`, Go struct tags, the Laravel Resource, the Rails serializer). Don't convert by hand at each call site |
| Errors | Every service invents its own error JSON | One envelope for the whole system, such as RFC 9457 `application/problem+json`, with a stable machine-readable `type` or `code` |
| Pagination and limits | Each side assumes a different default page size or cursor format | Put defaults and maximums in the contract, and use opaque cursor strings |

## Reply

Name the contract file (or the two files of an implicit one), the generated outputs, every consumer and whether you changed it, the deploy order, and the captured payload or contract test that proves both sides agree.
