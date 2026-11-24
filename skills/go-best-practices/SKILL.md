---
name: go-best-practices
description: Go best practices, including net/http, Chi, Gin, Echo, and Fiber services. Use when reading or editing any .go file, go.mod, or go.sum.
paths: ["**/*.go", "**/go.mod", "**/go.sum"]
disable-model-invocation: true
---

# Go best practices

Apply the **type-system-discipline** and **boundary-discipline** principle skills first. Follow the repository's existing conventions where they are deliberate. These rules decide everything the repository leaves open.

| Rule | Summary |
|------|---------|
| Errors are values | Wrap once per layer that adds context, with `fmt.Errorf("load user %s: %w", id, err)`. Check with `errors.Is` and `errors.As`, never by string. Use a sentinel for an expected outcome and a typed error when callers need its fields. Log an error or return it, not both. |
| Context first | Anything that blocks or does I/O takes `ctx context.Context` as its first parameter and passes it to every DB, HTTP, and RPC call. Never store a context in a struct. `context.WithoutCancel` only for work that must outlive the request, with the reason in the PR. |
| Every goroutine has an owner | Each `go` statement has an exit path (a cancelled context, a closed channel) and someone who waits for it. Prefer `errgroup.WithContext` over a bare `sync.WaitGroup` when errors matter. No fire-and-forget goroutines in request handlers. |
| Small interfaces at the consumer | Define an interface where it is used, with one to three methods. Return concrete types. One implementation gets no interface unless it is an I/O seam a test must replace. |
| Named domain types | `type UserID int64`, not bare `int64`, so IDs can't be swapped. Enums are typed constants with an exhaustive `switch` (the `exhaustive` linter), not strings. Parse request data into domain types at the handler. |
| Useful zero values | Make the zero value safe to use, or hide the type behind a constructor. Don't take pointers to everything to fake optionality. Use a pointer or `omitzero` only where "absent" differs from "zero". |
| Shared state | One goroutine owns mutable state and others talk to it over channels, or a mutex sits beside the fields it guards. Never copy a struct that holds a mutex (`go vet` catches it). |
| Packages by domain | `billing/`, `user/`, not `models/` and `handlers/`. Unexported by default, `internal/` for non-public packages, no `util` or `common`. |
| Generics earn their place | Use type parameters when two or more concrete types already share the algorithm, never for future flexibility. |
| Close what you open | `defer rows.Close()`, `defer resp.Body.Close()`, and check `rows.Err()` after the loop. |
| Real tests | Table-driven tests with `t.Run`, `t.Parallel()` where safe, `httptest` for handlers, a real database through the repository's harness or testcontainers over mocks. Assert on behavior, not on calls. |
| Structured logs | `log/slog` with the request ID and the fields you'd search by. No `fmt.Println` or `log.Printf` in shipped code. |

## HTTP services

All frameworks: the handler decodes, validates, calls a service, and encodes. Business logic never sees the framework's context type, only a `context.Context` and domain types. Set server timeouts (at least `ReadHeaderTimeout`), because `http.ListenAndServe` sets none. Shut down with `srv.Shutdown(ctx)` on `SIGTERM`.

- **`net/http` and Chi.** On Go 1.22 and later, the standard mux routes by method and path (`mux.HandleFunc("GET /users/{id}", h)`, `r.PathValue("id")`). Reach for Chi when the repository uses it or needs route groups and its middleware. Write middleware as `func(http.Handler) http.Handler`, so it works with both.
- **Gin.** Bind with `c.ShouldBindJSON`, not `c.BindJSON`, which writes its own 400. `return` right after `c.AbortWithStatusJSON`. Pass `c.Request.Context()` downstream, never `*gin.Context`.
- **Echo.** Bind with `c.Bind`, validate with the registered `c.Validate`, and pass `c.Request().Context()` downstream. Return errors and let one `HTTPErrorHandler` map them to responses.
- **Fiber.** Fiber runs on fasthttp, not `net/http`. Values from `*fiber.Ctx` (params, body, headers) are reused after the handler returns, so copy anything you keep (`utils.CopyString`), or the repository sets `Immutable`. Check the Fiber major version in `go.mod`. Pass the request's `context.Context` downstream (`c.UserContext()` in v2, `c.Context()` in v3). `net/http` middleware plugs in only through Fiber's adaptor.

## Verify

Run the repository's own target first (`make`, `task`, `just`, or a `scripts/` entry), because it carries the flags CI uses. Otherwise:

- `go build ./...` and `go vet ./...`
- `go test -race ./...`, scoped with `-run` while iterating, and in full before the PR
- `golangci-lint run` when `.golangci.yml` or `.golangci.yaml` exists, and `staticcheck ./...` when the repository uses it
- `govulncheck ./...` when `go.mod` changed
- For a service, start it and call the changed endpoint with `curl`. For a CLI, run the built binary. That output is the evidence, not the test count.

If the Go toolchain is missing on the host, run these in the repository's container or version manager. A skipped check is not a pass.
