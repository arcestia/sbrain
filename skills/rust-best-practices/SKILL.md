---
name: rust-best-practices
description: Rust best practices, including Tokio and Axum services. Use when reading or editing any .rs file, Cargo.toml, or Cargo.lock.
paths: ["**/*.rs", "**/Cargo.toml", "**/Cargo.lock"]
disable-model-invocation: true
---

# Rust best practices

Apply the **type-system-discipline** and **boundary-discipline** principle skills first. Follow the repository's existing conventions where they are deliberate. These rules decide everything the repository leaves open.

| Rule | Summary |
|------|---------|
| Illegal states unrepresentable | Model states as enums with data, not structs of `Option`s and `bool`s. Replace a `bool` parameter with a two-variant enum. |
| Newtypes for meaning | `struct UserId(Uuid)`, `struct Cents(i64)`, so units and IDs can't be swapped. Parse at the boundary with `TryFrom` or `FromStr`, then trust the type. |
| Typed errors | Libraries and domain code return `thiserror` enums. Binaries and the outermost app layer may use `anyhow` with `.context("what was being done")`. Propagate with `?`. |
| No `unwrap` in shipped paths | `unwrap` and `expect` belong in tests, in `main` setup, and where the line above proves the invariant. Then use `expect("why this cannot fail")`, never `unwrap`. |
| Borrow in, own out | Parameters borrow (`&str`, `&[T]`, `impl AsRef<Path>`), and structs own their fields. A `.clone()` added to quiet the borrow checker is a design question. Answer it before you ship it. |
| Async never blocks | No `std::fs`, `std::thread::sleep`, blocking clients, or long CPU loops on the runtime. Use `tokio::fs`, `tokio::time`, or `spawn_blocking`. Never hold a `std::sync::MutexGuard` across `.await` (clippy's `await_holding_lock`). Use `tokio::sync::Mutex` only when the guard must cross an await. |
| Tasks have owners | Every `tokio::spawn` has a `JoinHandle`, `JoinSet`, or cancellation token that someone awaits or cancels. Shared app state is `Arc<...>`, never `Rc`. |
| `unsafe` is a last resort | Keep the block minimal, with a `// SAFETY:` comment naming the invariant it relies on. `no-comments` keeps `SAFETY` comments. Run Miri over it, and consider **create-formal-verification-skill** for it. |
| Traits earn their place | One implementation gets no trait. Use generics for static dispatch on hot paths, and `dyn Trait` at plugin boundaries. |
| Iterators over indexes | Prefer iterator chains. Collect fallible results with `collect::<Result<Vec<_>, _>>()`. |
| Wire types apart from domain types | Inbound DTOs derive `Deserialize`, with `#[serde(deny_unknown_fields)]` where the API is strict. Convert them into domain types. Tagged unions shared with a TypeScript client use `#[serde(tag = "kind")]`. |
| Structured logs | `tracing` with spans and fields. No `println!` or `dbg!` in shipped code. |
| Real tests | Unit tests in a `mod tests` beside the code, integration tests in `tests/`. Property tests (`proptest`) for parsers and codecs. Real databases through the repository's harness over mocks. |

## Axum services

- **Extractor order.** A body-consuming extractor (`Json`, `Form`, `Bytes`, `Request`) must be the last handler argument.
- **State.** One `AppState: Clone` holding `Arc`s, read through `State<AppState>`, with `FromRef` for sub-states. No globals or `lazy_static` for app state.
- **Errors.** One `AppError` enum that implements `IntoResponse` maps domain errors to status codes in one place. Never send internal error text to clients.
- **Middleware.** Use `tower-http` layers (`TraceLayer`, `TimeoutLayer`, `CorsLayer`). With chained `Router::layer` calls, the last one added runs first on a request. `ServiceBuilder` runs top to bottom.
- **Shutdown.** `axum::serve(listener, app).with_graceful_shutdown(signal)`.
- **Tests.** Call the `Router` with `tower::ServiceExt::oneshot`, with no port and no mocks of Axum itself.
- **sqlx.** Prefer `query!` and `query_as!` for compile-time-checked SQL. When the repository builds offline (a `.sqlx/` folder), run `cargo sqlx prepare` after every query change and commit the result.

## Verify

Run the repository's own target first (`make`, `just`, `cargo xtask`, or a `scripts/` entry), because it carries the flags CI uses. Otherwise:

- `cargo fmt --check`
- `cargo clippy --all-targets --all-features -- -D warnings`
- `cargo nextest run` when the repository uses nextest, else `cargo test`
- `cargo +nightly miri test` for code that touches `unsafe`
- `cargo deny check` or `cargo audit` when `Cargo.toml` changed and the repository configures one
- For a service, run it and call the changed endpoint with `curl`. That output is the evidence, not the test count.

If `cargo` is missing on the host, run these in the repository's container, devcontainer, or `rustup` toolchain. A skipped check is not a pass.
