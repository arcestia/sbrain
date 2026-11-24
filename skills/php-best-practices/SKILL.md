---
name: php-best-practices
description: PHP best practices, including Laravel. Use when reading or editing any .php or .blade.php file, composer.json, or composer.lock.
paths: ["**/*.php", "**/composer.json", "**/composer.lock"]
disable-model-invocation: true
---

# PHP best practices

Apply the **type-system-discipline** and **boundary-discipline** principle skills first. Follow the repository's existing conventions where they are deliberate. These rules decide everything the repository leaves open.

| Rule | Summary |
|------|---------|
| Strict types | New files start with `declare(strict_types=1);` unless the repository deliberately doesn't use it. Type every property, parameter, and return. `mixed` only at a boundary, before parsing. |
| Static analysis is the type system | PHPStan (Larastan in Laravel) at the repository's level must pass. Never lower the level or add baseline entries to get green. Use PHPDoc generics and shapes (`list<User>`, `array{id: int, name: string}`, `@template`) where native types stop. |
| Enums and readonly values | States are backed enums (8.1+). Value objects and DTOs are `readonly` classes or properties with constructor promotion. |
| No associative arrays across layers | An array shape that crosses a layer becomes a DTO. Arrays are for lists and local data. |
| Strict comparisons | Always `===`. Pass `true` as `in_array`'s third argument. Prefer `match`, which compares strictly and throws on an unhandled value, over `switch`. |
| Specific exceptions | Throw specific exception classes. No `@` error suppression, and no `catch (\Throwable)` that swallows. |
| Safe SQL and output | Bound parameters always. `DB::raw` and `whereRaw` only with bindings. Escape output (Blade `{{ }}`). Use `{!! !!}` only for sanitized HTML. Never `unserialize` user input. |
| Composer hygiene | Commit `composer.lock` for applications. PSR-4 autoloading. Add a dependency only when the standard library or the framework doesn't already cover it. |
| Real tests | Pest or PHPUnit, whichever the repository uses. Feature tests through HTTP over unit tests of controllers. Fake only external edges (`Http::fake()`, `Queue::fake()`, `Mail::fake()`). |

## Laravel

- **Validation.** Validate in a `FormRequest`, and read only `$request->validated()`, never `$request->all()`. List `$fillable` explicitly. Never set `$guarded = []`.
- **Authorization.** Use policies and gates, checked with `Gate::authorize` or the `FormRequest`'s `authorize()`, never with ad hoc `if` checks in a controller.
- **N+1.** Eager-load with `with()`. Keep or add `Model::shouldBeStrict(! app()->isProduction())` (or `preventLazyLoading`) in a service provider. Use `chunkById` or `lazyById` for large sets.
- **Response shape.** API Resources define the JSON a frontend reads. Treat them as the contract (see **polyglot-boundaries**).
- **Thin controllers.** Controllers call actions or services. Reusable query parts become Eloquent scopes.
- **Queues.** Make every job idempotent (the **make-operations-idempotent** principle). Use `ShouldBeUnique` when duplicates hurt. Dispatch after commit (`afterCommit()`).
- **Config.** Call `env()` only inside `config/*.php`. Everywhere else use `config()`, because a cached config makes `env()` return `null`.
- **Migrations.** Never edit a migration that has run outside your machine. Add a new one. Make foreign keys and their delete behavior explicit (`->constrained()->cascadeOnDelete()` or `->restrictOnDelete()`).

## Verify

Run the repository's own entry point first (`composer test`, a `Makefile`, or Sail), because it carries the flags CI uses. Otherwise:

- `php artisan test`, `vendor/bin/pest`, or `vendor/bin/phpunit`, scoped to the touched files while iterating, and in full before the PR
- `vendor/bin/phpstan analyse`
- `vendor/bin/pint` on the changed files before commit, and `vendor/bin/pint --test` to check. Use `vendor/bin/php-cs-fixer` instead when the repository configures it. The format-on-edit hook skips PHP, because both tools can delete a `use` line before the code that needs it is written.
- `composer validate` and `composer audit` when `composer.json` changed
- For a migration, `php artisan migrate`, `migrate:rollback`, then `migrate` again against the development database
- For a web change, run the app and call the changed route or drive the page. That output is the evidence, not the test count.

If PHP or Composer is missing on the host, prefix commands with `./vendor/bin/sail` when the repository uses Sail, or run them with `docker compose exec <service>`. A skipped check is not a pass.
