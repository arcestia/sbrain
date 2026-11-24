---
name: react-best-practices
description: React and Next.js best practices for components, hooks, Server Components, and routes. Use when reading or editing any .tsx or .jsx file, or a Next.js app's routes and config.
paths: ["**/*.tsx", "**/*.jsx", "**/next.config.*", "**/app/**/route.ts", "**/middleware.ts"]
disable-model-invocation: true
---

# React best practices

Apply **typescript-best-practices** first for `.tsx`, then the **model-the-domain** principle skill. Follow the repository's existing conventions where they are deliberate. These rules decide everything the repository leaves open.

| Rule | Summary |
|------|---------|
| Derive, don't sync | Compute values from props and state during render. An effect that only sets state from other state is a bug waiting to happen. Delete it. |
| Effects sync with the outside | `useEffect` is for subscriptions, timers, and browser APIs. Fetch data through the repository's data layer (Server Components, TanStack Query, SWR), not in an effect. |
| One status, not many flags | Async UI state is a discriminated union (`idle`, `loading`, `error`, `success`), not `isLoading` plus `error` plus `data`. |
| Keep state close | Colocate state with its only reader and lift it only when two components share it. Reset state with `key`, not with an effect. |
| Render is pure | No mutation of props, state, or module variables during render, and no reading `ref.current` during render. |
| React Compiler | When the repository enables it (`babel-plugin-react-compiler`, or `reactCompiler` in `next.config`), don't hand-write `useMemo`, `useCallback`, or `memo`. Keep components pure so it can optimize them. Without it, memoize only a cost you measured. |
| Stable keys | Keys come from data IDs. An index key only for a static list that never reorders. |
| Forms | On React 19, use actions with `useActionState` and `useFormStatus` where the repository does. Use a controlled input only when something reads each keystroke. |
| Accessible by default | Semantic elements first (`button`, `label`, `nav`). Every input has a label, and everything a mouse can do, a keyboard can do. |
| Hook lint passes | The repository's React hooks lint rules pass without disables. A disable needs the reason in the PR. |

## Next.js

Read the Next.js major version in `package.json` before touching caching, routing, or config, because their semantics changed in 15 and again in 16.

- **Server first.** Components are Server Components by default. Put `"use client"` on the smallest leaf that needs state, effects, or browser APIs. Mark server-only modules with `import "server-only"`.
- **Server Actions are public endpoints.** Parse the input with the repository's schema library and check authorization inside every action, as you would in an API route.
- **Caching is explicit.** For every cached value, name what is cached, for how long, and what revalidates it (`revalidatePath`, `revalidateTag`, or the version's cache directives). Don't assume a default. Check it for the version in use.
- **Route handlers.** Parse the request body at the top of `route.ts` into a typed value, and return a typed response. The response is a contract (see **polyglot-boundaries** when a non-TypeScript service consumes it).
- **Env.** Only values safe in a public bundle get the `NEXT_PUBLIC_` prefix, since they are inlined at build time.
- **Hydration.** No `Date.now()`, `Math.random()`, `window`, or locale formatting in render paths shared by server and client. Compute them on the server and pass them down, or render them only on the client.
- **One router per feature.** In a repository that still has the Pages Router, follow the router the feature already lives in. Don't mix them inside one feature.

## Verify

Run the repository's own scripts first (`package.json` scripts, `turbo`, `nx`), with its package manager (the lockfile tells you which). Otherwise:

- Type-check (`tsc --noEmit` or the `typecheck` script)
- Lint with the repository's lint script (ESLint or Biome)
- Unit and component tests (Vitest or Jest)
- `next build` for a Next.js change, because it catches server and client import mistakes and route errors that the dev server hides
- Drive the changed page in a browser (the built-in browser, Claude in Chrome, or Playwright) on a real build or the dev server. Check the console for hydration and key warnings. That is the evidence, not the test count.
