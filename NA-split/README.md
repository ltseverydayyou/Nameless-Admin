# Chunked Nameless Admin runtime

`Source.lua` and `NA testing.lua` are small bootstraps. They load the ordered
files in `common/`, compile each file independently, and execute them in the
same private environment.

On each run the bootstrap checks the small remote `manifest.lua`. Matching
chunk fingerprints reuse the local copy; only changed or missing chunks are
downloaded. Downloaded chunks are cached separately in `common/.parts/`, using
their fingerprint as the filename. The local manifest is updated after all
chunks execute successfully and their cache writes succeed. A failed update
therefore keeps the previous cached build usable.

The manifest contains data only. After a successful load, the bootstrap caches
a compile-checked copy of the selected loader and its version marker.

The bootstrap checks these local chunk paths first:

- `NA-split/common/`
- `Nameless-Admin/NA-split/common/`
- `Nameless Admin/NA-split/common/`

The matching loader is cached one directory above `common/`, for example
`NA-split/Source.lua` or `NA-split/NA testing.lua`. The loader cache has its own
version marker, so it does not need to redownload the loader every run.

If the files are not present, it downloads them from the repository's raw
GitHub URL. An executor can override the chunk URL with
`getgenv().__NA_SPLIT_BASE_URL` before loading Nameless Admin.

The loader yields between chunks when `task.wait` is available. This spreads
compilation and top-level startup work across frames instead of presenting the
executor with one large source/bytecode unit. Settings construction and queued
startup jobs keep their instance budgets after the loading screen closes.
Heavy queued jobs wait for the settings build to finish; startup frame tracking
continues until queued work settles, with a 60-second limit.

To split a future monolithic source file, pass it explicitly:

```text
python tools/build_split_na.py --input path/to/monolith.lua
```

The builder is intended for a monolithic input. Normal changes
should be made in the generated chunks once the split distribution is in use.

After editing existing chunks or launchers, refresh their metadata without
splitting a monolith again:

```text
python tools/build_split_na.py --refresh-metadata
```

Run the regression suite with Luau tools on `PATH`, or supply their paths:

```text
python tests/na_split_regression.py --luau /path/to/luau --compiler /path/to/luau-compile
```

The suite uses the pinned pre-audit commit for comparisons, so that commit must
be available in the local Git history. `--baseline` can select another baseline.
See [the audit notes](../docs/na-split-performance-audit.md) for coverage and
[client results](../docs/na-split-client-results.md) for pinned captures,
measurement limits, and instructions for the optional client probe.
