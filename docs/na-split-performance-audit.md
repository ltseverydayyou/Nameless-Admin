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
| FastFlags | Budget availability checks and application batches. Skip a repeated write only after reading the current flag and confirming it still matches; repair changes made elsewhere. |
| Executor | Construct the complete autocomplete dataset only on first use; reuse it and its index thereafter. Release bootstrap helper source strings after their modules load. |
| Tasks and unload | Do not retain synchronously completed tasks or cancel dead task references again. Cancel timed-out/skipped workers and release their tracking entries. Register flashback and plugin-maker input connections. Use raw table traversal and stored disconnect methods so cleanup does not activate borrowed metatables or probe arbitrary userdata. Clean managed namespaces and direct runtime connections while excluding host/registry roots and borrowed global tables. Preserve the designated unload thread even when cleanup runs in another thread. Legacy signal cleanup checks callback environments before trusting a shared source name; editor cleanup queries UI classes instead of all CoreGui descendants. Restore the previous global caller and prevent delayed cleanup from affecting a reloaded runtime. |

## Validation

`tests/na_split_regression.py` compiles both launchers, the manifest, all 29 chunks, and the optional client probe. It also verifies CRLF/no BOM for runtime files, chunk and loader fingerprints, and generator parity. The behavioral suite extracts the current implementation into a deterministic Luau scheduler with mocked Roblox signals and instances.

Thirty-eight scenarios pass **77,406 assertions**. They cover cold/warm/offline/delta/incomplete loads, content caches, duplicate guards, cache-write and lock failures, failed-load retries, cancellation, event bursts and yielding callbacks, traversal limits, respawns, stale cache workers, queue ordering/concurrency/errors, settings completion, lighting changes/restoration, input rebinding, task timeouts, unload ownership, and quick reloads. Both normal unload and failed-load fallback avoid borrowed roots, synthetic methods, custom iterators, and dead-task cancellation. The executor dataset is compared recursively with the original dataset.

Reproducible CLI observations:

| Fixture | Before | After |
| --- | ---: | ---: |
| Connection records inspected while appending 2,000 live connections to one bucket | 2,760,856 | 7,288 |
| Full chat-frame queries for 1,000 incremental normalization calls | One full scan per original notification | 0 |
| Character part queries over 600 cache reads | One per original frame callback | 1 initial query |
| Executor autocomplete table allocated during ordinary startup | Eager | Deferred until first use |

The deferred executor table adds approximately **1,093 KiB** of live allocations when first constructed in the tested Luau CLI. This measures that table, not the complete Roblox/client memory footprint. Source and bytecode for the dataset still compile as part of its containing chunk.

## Live-client validation

The full script was executed through the connected Windows client using Potassium v2.5.1. The pinned baseline produced post-loading maximum frames of **100.8 and 149.0 ms**. Completed captures after the FastFlag fix ranged from **26.1 to 67.0 ms**, with no post-loading frames above 100 ms in those captures. These are observations on one desktop, with different cache/session conditions, rather than a controlled low-end benchmark. See [the client results](na-split-client-results.md) and [capture data](na-split-client-captures.json) for individual measurements, lifecycle checks, and limitations.

Physical low-end hardware and long-running gameplay remain unmeasured. Compare identical settings/plugins on those devices, including chat-history restoration, NPC/ESP activity, executor first open, respawn, and repeated unload/reload. Compare maximum frame duration and retained memory after settling as well as total readiness time. More frequent yields can increase elapsed initialization time while reducing concentrated frame work. Individual native compilation, asset loading/cloning, and arbitrary plugin callbacks remain indivisible unless their implementations cooperate with the budgets. Repeated desktop reloads retained weakly observed runtime objects; neither the engine memory counters nor the audit prove complete garbage collection or the elimination of every leak.

Use a fresh baseline cache when testing the old launcher: it does not understand the new fingerprint cache layout. Current launchers accept legacy flat caches and the new layout.

To run the runtime from `main`, unload an existing NA session first and clear any previous chunk URL override before executing its launcher:

```lua
getgenv().__NA_SPLIT_BASE_URL = nil
loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"))()
```

When testing another branch or pinned commit, set `getgenv().__NA_SPLIT_BASE_URL` to its matching `NA-split/common/` URL before loading that reference's launcher. Clear the override when returning to `main`.
