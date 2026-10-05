# NA split performance audit

Audited against `a2276c3cd5b79392b8021f01678a28523ae639d6` on 2026-10-05. The review covered the two launchers, all 29 runtime chunks, the split manifest, and the generator, with focused tracing of startup work, frame callbacks, descendant traversal, connection ownership, and unload paths.

## Changes

| Area | Finding and change |
| --- | --- |
| Split loading | Added frame yields between chunks. Local completeness checks use file existence rather than reading every source twice. Matching fingerprints avoid downloading unchanged chunks. |
| Cache updates | Cache changed chunks by fingerprint without overwriting the preceding build. Publish the manifest only after successful execution and cache writes; discard obsolete cached fingerprints after publication. Release downloaded source strings after each chunk. |
| Loader lifecycle | Preserve the active caller on duplicate execution. Release filesystem locks on failures. Cancel partial initialization and clean owned tasks, connections, and loading UI when a chunk fails or loading is cancelled. |
| Manifest and generator | Manifest execution has no caching side effects. Loader caching happens once after successful loading and follows the selected branch URL. Generator output matches both launchers; metadata can be refreshed without splitting a monolith. |
| Startup queue | Honor UI initializer spacing, limit simultaneous work on mobile/low-end profiles, defer heavy queued jobs until settings finish, and retain jobs enqueued by the final running job. |
| Post-load startup | Keep instance and command-registration budgets active after the loading screen closes. Continue frame monitoring through background startup, command rebuilding, and a short settling interval, bounded to 60 seconds. |
| Settings | Reduce control batches and time budgets. Avoid repeated final mounts, preserve the selected tab, and mark construction complete after the final mount. Skip unchanged tab visuals during background construction. |
| Connections | Avoid rescanning growing connection buckets on every append. Periodic maintenance visits each bucket at most once per call and stops at its time budget. |
| Descendant events | Filter irrelevant classes before scheduling, batch queued events across frames, release consumed references, and keep yielding callbacks independent. Correct separate addition/removal class gates. |
| CoreGui startup | Replace the blocking, duplicate NetworkPause tree walk with deferred class queries. Coalesce scans, install watchers before scanning, cancel stale work, release removed GUI connections, and restore the original enabled state on unload. |
| World caches | Cancel asynchronous builders by generation so an old worker cannot overwrite a newer cache or mark a released cache complete. Stream world traversal with count/time limits; use native snapshots for UI trees. Apply configured sleeps at count boundaries only and yield once at each budget boundary. |
| Character/NPC commands | Cache part membership for noclip, creep, netless, client bring, and NPC bring. Track additions/removals and character replacement. Remove per-frame queries, repeated target callbacks, and per-NPC task creation. |
| ESP | Remove the redundant periodic part rescan from models already covered by descendant watchers. |
| Chat UI | Normalize added objects in batches instead of scanning the entire chat frame for each added descendant. Skip unchanged Z-index assignments. |
| Lighting | Replace per-frame lighting/camera descendant scans with initial scans and additions/camera watchers. Throttle cached effect/shader enforcement and avoid unchanged property writes. Restore the original no-fog baseline. |
| Executor | Construct the complete autocomplete dataset only on first use; reuse it and its index thereafter. Release bootstrap helper source strings after their modules load. |
| Tasks and unload | Do not retain synchronously completed tasks. Cancel timed-out/skipped workers and release their tracking entries. Register flashback and plugin-maker input connections. Clean managed namespaces and direct runtime connections while excluding host/registry roots and borrowed global tables. Preserve the designated unload thread even when cleanup runs in another thread. Restore the previous global caller and prevent delayed cleanup from affecting a reloaded runtime. |

## Validation

`tests/na_split_regression.py` compiles both launchers, the manifest, and all 29 chunks. It also verifies CRLF/no BOM for runtime files, chunk and loader fingerprints, and generator parity. The behavioral suite extracts the current implementation into a deterministic Luau scheduler with mocked Roblox signals and instances.

Thirty-three scenarios cover cold/warm/offline/delta/incomplete loads, content caches, duplicate guards, cache-write and lock failures, failed-load retries, cancellation, event bursts and yielding callbacks, traversal limits, respawns, stale cache workers, queue ordering/concurrency/errors, settings completion, lighting changes/restoration, input rebinding, task timeouts, unload ownership, and quick reloads. The executor dataset is compared recursively with the original dataset.

Reproducible CLI observations:

| Fixture | Before | After |
| --- | ---: | ---: |
| Connection records inspected while appending 2,000 live connections to one bucket | 2,760,856 | 7,288 |
| Full chat-frame queries for 1,000 incremental normalization calls | One full scan per original notification | 0 |
| Character part queries over 600 cache reads | One per original frame callback | 1 initial query |
| Executor autocomplete table allocated during ordinary startup | Eager | Deferred until first use |

The deferred executor table adds approximately **1,093 KiB** of live allocations when first constructed in the tested Luau CLI. This measures that table, not the complete Roblox/client memory footprint. Source and bytecode for the dataset still compile as part of its containing chunk.

## Live-client validation

The full script was not executed in Roblox during this audit. Mock tests establish specific control-flow and ownership behavior; they cannot measure device FPS, renderer cost, executor compatibility, native allocation behavior, or arbitrary plugin work.

Before merging, compare the pinned baseline and this branch in the same place on a low-end device with identical settings/plugins. Capture cold and warm startup, the first 60 seconds after the loading screen closes, settings interaction during construction, long chat-history restoration, NPC/ESP activity, executor first open, respawn, and repeated unload/reload. Compare maximum frame duration and retained memory after settling as well as total readiness time. More frequent yields can increase elapsed initialization time while reducing concentrated frame work. Individual native compilation, asset loading/cloning, and arbitrary plugin callbacks remain indivisible unless their implementations cooperate with the budgets.

Use a fresh baseline cache when testing the old launcher: it does not understand the new fingerprint cache layout. Current launchers accept legacy flat caches and the new layout.

To test this draft branch, unload an existing NA session first, then select its chunk URL before executing its launcher:

```lua
getgenv().__NA_SPLIT_BASE_URL = "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/perf/na-split-audit-20261005/NA-split/common/"
loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/perf/na-split-audit-20261005/Source.lua"))()
```

Clear `getgenv().__NA_SPLIT_BASE_URL` when returning to the default branch. Loading only the branch launcher without the override still selects the default branch's runtime chunks.
