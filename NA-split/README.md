# Chunked Nameless Admin runtime

`Source.lua` and `NA testing.lua` are small bootstraps. They load the ordered
files in `common/`, compile each file independently, and execute them in the
same private environment.

On each run the bootstrap checks the small remote `manifest.lua`. If its build
version differs from the local manifest, the new chunks are downloaded and
written to the local cache after a successful load. The remote manifest also
keeps a validated local copy of whichever loader is being used, so the last
working `Source.lua` / `NA testing.lua` can be used when GitHub is unavailable.

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
executor with one 5 MB source/bytecode unit.

To split a future monolithic source file, pass it explicitly:

```text
python tools/build_split_na.py --input path/to/monolith.lua
```

The builder is intended for a monolithic input. Normal changes
should be made in the generated chunks once the split distribution is in use.
