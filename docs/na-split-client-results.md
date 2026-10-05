# NA split client results

Captured on 2026-10-05 against baseline `a2276c3cd5b79392b8021f01678a28523ae639d6`. The final code check used `29e9042c1d60d5c06438b8792495050d333e4c51`. The desktop client ran Potassium v2.5.1 on Windows in a baseplate place, at a 240 FPS cap, with 16 logical CPUs and approximately 16 GB RAM. It was not a physical low-end device.

## Method

The optional [client probe](../tests/na_split_client_probe.lua) pins both `Source.lua` and the runtime chunk URL to the same commit. A Heartbeat listener records frame durations separately before loading closes, between loading close and settings readiness, and after settings readiness. It stops after the configured post-loading interval, settings have been ready for five seconds, and startup work is idle, or at a deadline. Frame samples and diagnostic records have bounded storage; the frame listener disconnects and releases its frame arrays when finished.

The probe adds timing calls around chunk reads, compilation, and execution. Those durations are elapsed wall time: execution can include cooperative waits and network work. They are not CPU timings. Optional `traceSegments` wraps `Wait` and collects bounded stack traces; use that only for diagnosis, since native yields and instrumentation can affect the intervals.

These are successive development captures with different jobs, cache states, and client resource pressure. Saved NetworkPause and FastFlag settings remained enabled. A content-warm capture reuses chunk fingerprints, but UI/dependency HTTP requests may still occur. Comparisons establish observed behavior and the usefulness of individual fixes; they are not randomized benchmarks or guarantees for every game/device. The checked-in [capture data](na-split-client-captures.json) preserves individual frame summaries, cache versions, memory counters, chunk timings, and unload results.

## Completed startup captures

Times start when the probe is launched, including launcher retrieval. The post-loading maximum includes all recorded frames after the loading screen closes, not just settings construction. The threshold count is strictly greater than 100 ms.

| Capture | Code | Loading closes (s) | Launcher returns (s) | Settings ready (s) | Post-loading window (s) | Post-loading max (ms) | Frames >100 ms |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Baseline 1 | `a2276c3` | 3.262 | 3.320 | 7.391 | 20 | 149.041 | 2 |
| Baseline 2 | `a2276c3` | 2.577 | 2.639 | 7.093 | 20 | 100.820 | 1 |
| NetworkPause fix, delta cache | `c3f33ad` | 2.809 | 3.032 | 9.295 | 20 | 171.727 | 2 |
| FastFlag fix, delta cache | `3e1552b` | 3.076 | 3.661 | 10.894 | 20 | 26.138 | 0 |
| Content warm | `b4afe3b` | 2.412 | 2.540 | 10.055 | 20 | 34.436 | 0 |
| Published unload fix, reload 1 | `a4cad66` | 2.358 | 2.599 | 8.621 | 20 | 37.952 | 0 |
| Published unload fix, content warm 2 | `a4cad66` | 3.810 | 4.039 | 13.296 | 60 | 66.998 | 0 |
| Final code, retry after injected failure | `29e9042` | 1.693 | 1.982 | 10.948 | 20 | 35.037 | 0 |

The NetworkPause fix alone did not remove the post-loading hitch. Segment tracing subsequently identified unbudgeted FastFlag initialization/maintenance, including a roughly 158 ms maintenance interval. Budgeting checks/writes and skipping already-correct values removed the observed >100 ms post-loading frames in the five completed captures thereafter. Settings took longer to finish than the baseline in these captures; work is spread across more frames rather than concentrated into the original blocking batches.

An earlier candidate blocked the split loader in the initial NetworkPause descendant traversal. One source run completed after approximately 149 seconds; another live trace remained in that traversal after 110 seconds. Those runs exceeded the probe's deadline and are excluded from the startup table. Deferring and narrowing the scan reduced `part-016` execution to approximately 4.5 ms in the first successful capture after that fix; full launcher completion then returned to a few seconds. This is a fix to that specific traversal under the saved setting, not a claim that every settings/dependency path completes within that time.

Native compilation still contributes frame work. In the content-warm captures, `part-023` compiled in approximately 32–46 ms and `part-027` in approximately 27–55 ms. The loader yields between chunks, but cannot yield inside an individual native compile call. The last slow warm capture is retained in the results rather than excluded. Compilation does not explain every recorded post-loading frame; the probe does not provide a complete native CPU profile.

## Unload, cancellation, and ownership

Early candidate unloads interrupted the client bridge. Persisted phase traces narrowed the failure to cleanup of `NAmanage`. Cleanup was reading disconnect properties on arbitrary userdata/tables and invoking custom table iteration. The final tree walker uses raw iteration and explicitly stored table methods, recognizes native connections by type, skips dead tasks, and avoids borrowed host/registry/runtime roots.

Two unmodified `a4cad66` unloads completed in **0.276 and 0.316 seconds** without restarting the client. Each reported **zero cleanup errors**, 51 cleanup callbacks, 794 destroyed instances, and zero connections left connected in the pre-unload tracked connection set. The returned summaries counted 1,425 and 1,437 connection cleanup operations; those counters are not counts of distinct native connections.

A final fresh client loaded unmodified `29e9042` in **1.982 seconds**, reached settings readiness at **10.038 seconds**, and unloaded in **0.244 seconds**. Unload reported zero errors, cleared registry/global runtime state, and left zero of its 3,184 previously tracked connections connected. This lifecycle check did not use the startup timing instrumentation.

A separate targeted inspection after the unload fix found zero callbacks belonging to the unloaded environment on RunService Heartbeat/RenderStepped/Stepped, input begin/end/change, CoreGui descendant add/remove, and player add/remove signals. This checks those roots rather than every Roblox signal. Registry testing state and global loading state were cleared. A successful reload followed.

The final loader was also tested with an intentional error before chunk 5, before the full unload implementation exists. Its error handler produced the expected audit error report, cleared the runtime/loader guards, and allowed the immediate successful retry shown above. The regression suite additionally checks cancellation, cyclic ownership graphs, timed-out tasks, borrowed connections, custom iterators, replacement protectors, and delayed cleanup during quick reload.

## Memory and remaining coverage

Memory counters cover the whole running client. Engine Lua heap, executor `gcinfo()`, total memory, and instance counts are useful observations but do not isolate NA allocations. Across these repeated instrumented reloads, executor heap grew and weak references to older runtime objects remained observable after unload. The checks did not identify a retained old callback in the inspected host tables and signal roots. Probe/executor retention and native caches are possible contributors; no root-cause attribution or complete garbage-collection claim is established.

Concrete retention fixes include releasing consumed descendant-event references, disposing part/workspace caches, tracking input and loading connections, cancelling abandoned workers, dropping downloaded source strings, and removing stale task/connection records. The CLI verifies those ownership and lifetime paths. Deferring the autocomplete table saves its approximately **1,093 KiB** construction until first use in the CLI measurement; its source/bytecode still compiles at startup. Long-session retained memory, every executor hook, arbitrary plugins, every command, and physical low-end behavior remain outside the measured coverage.

Interrupted bridge/script execution can leave an empty filesystem load-lock directory. A diagnostic attempt was retried only after confirming no runtime or active loading state and removing that exact stale job lock; preferences and caches were preserved. This audit adds cleanup for handled failures, not a cross-process lock lease/recovery protocol.

## Repeating a capture

Unload the previous runtime, keep device/place/settings/plugins and FPS cap identical, then configure and execute the probe:

```lua
getgenv().__NA_AUDIT_CONFIG = {
    ref = "29e9042c1d60d5c06438b8792495050d333e4c51";
    label = "device-and-cache-label";
    postSeconds = 60;
    maxSeconds = 120;
}
```

Run `tests/na_split_client_probe.lua` through the executor, then read `getgenv().__NA_AUDIT_CAPTURE.summary` after `running` becomes false. Keep deadline/load-error captures separate from completed captures. Use a separate baseline cache when running the old launcher, which does not understand the new fingerprint layout. Clear `getgenv().__NA_SPLIT_BASE_URL` before returning to the default branch. Repeat on actual low-end hardware, include long-running gameplay and command activity, and compare settings readiness as well as frame spikes and retained memory.
