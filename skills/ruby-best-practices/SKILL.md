---
name: ruby-best-practices
description: Ruby best practices, including Rails, Sinatra, Hanami, and plain Ruby services. Use when reading or editing any .rb, .erb, or .rake file, a Gemfile, or a Rails migration.
paths: ["**/*.rb", "**/*.erb", "**/*.rake", "**/Gemfile", "**/Gemfile.lock", "**/*.gemspec"]
disable-model-invocation: true
---

# Ruby best practices

Apply the **boundary-discipline** and **model-the-domain** principle skills first. Follow the repository's existing conventions where they are deliberate. These rules decide everything the repository leaves open.

| Rule | Summary |
|------|---------|
| Parse at the edge | Turn raw input (params, JSON, ENV) into a typed object at the boundary, using strong params, a form object, or a `dry-validation` contract. Never pass a raw `params` hash past the controller. |
| Value objects | `Data.define` (Ruby 3.2+) for immutable values. `Struct` with keywords only where the repository already does. |
| Explicit failure | Failures raise a specific error class that inherits from `StandardError`, or return a result object. Not `nil`. A chain of three `&.` calls means a missing model. |
| Rescue narrowly | Rescue the classes you expect. No bare `rescue` that swallows, and never `rescue Exception`. |
| Keyword arguments | Three or more parameters, or any boolean, become keyword arguments. |
| Types when the repo has them | With Sorbet, every new method gets a `sig` at the file's strictness, and `srb tc` passes. With RBS and Steep, `steep check` passes. Don't add a type system the repository doesn't use. |
| No monkey patching | Don't reopen core or gem classes. If you must, use a refinement or a clearly named initializer, with the reason in the PR. |
| Structured logs | Use the repository's logger with tags and fields. No `puts` or `p` in shipped code. |
| Real tests | RSpec or Minitest, whichever the repository uses. Request and system specs over controller internals. Minimal factories (`build_stubbed` where possible). No `allow_any_instance_of`. |

## Rails

- **N+1.** `includes` or `preload` every association a view, serializer, or loop reads. Respect `strict_loading` and Bullet when the repository enables them.
- **Callbacks.** Model callbacks keep the record's own data consistent, and nothing else. Emails, jobs, and API calls run from the caller or in `after_commit`, never `after_save`, which runs inside the transaction.
- **Jobs.** Make every job idempotent (the **make-operations-idempotent** principle). Pass IDs, not records. Enqueue after the transaction commits.
- **Queries.** Scopes return relations. Use `find_each` for batches, `exists?` over `present?` on a relation, and `pluck` for columns. Placeholders or hash conditions only, never string interpolation in `where`.
- **Migrations.** Reversible, and safe on a large table: add the column as nullable, backfill in batches, then add the constraint. On Postgres, add indexes with `algorithm: :concurrently` and `disable_ddl_transaction!`. Follow `strong_migrations` when it's installed. Apply the **old-and-new-run-together** principle.
- **Security.** Strong params on every write. `html_safe` and `raw` only on sanitized content. Keep CSRF protection on.
- **Where code goes.** Controllers stay thin. Domain logic goes in models or plain Ruby objects under the repository's existing folder (`app/models`, `app/services`, `app/operations`), not into a god model.

## Sinatra, Hanami, and plain Ruby

- **Hanami 2.** Actions are classes with `handle(request, response)`. Validate in the action's `params` block. Take dependencies through `Deps[...]`, and keep persistence in repos and relations.
- **Sinatra.** Routes stay thin and call plain objects. Test with `Rack::Test`.
- **Plain services.** `bin/` entry points, a committed `Gemfile.lock`, and Zeitwerk when the repository autoloads.

## Verify

Run the repository's own entry point first (`bin/ci`, `bin/rails test`, a `Rakefile` task, or `bin/` scripts), because it carries the flags CI uses. Otherwise:

- `bundle exec rspec`, or `bin/rails test`, scoped to the touched files while iterating, and in full before the PR
- `bundle exec rubocop` (or `standardrb`) when the repository configures it
- `bundle exec srb tc` or `steep check` when the repository has types
- For a migration, `bin/rails db:migrate`, `db:rollback`, then `db:migrate` again against the development database
- `bundle exec brakeman` for a security-relevant Rails change when the repository has it
- For a web change, run the app (`bin/dev` or `bin/rails server`) and drive the changed page or endpoint. That output is the evidence, not the spec count.

If Ruby or Bundler is missing on the host, run these in the repository's container or version manager (`mise`, `rbenv`, `asdf`). A skipped check is not a pass.
