<div align="center">

# Nameless Admin

**Official continuation of Nameless Admin.**

A Roblox admin script with commands, plugins, UI tools, settings, and fixes kept in one place.

<p>
  <a href="https://github.com/ltseverydayyou/Nameless-Admin/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" alt="License"></a>
  <a href="https://discord.gg/zzjYhtMGFD"><img src="https://img.shields.io/badge/Discord-Join-5865F2?style=flat-square&logo=discord&logoColor=white" alt="Discord"></a>
  <a href="https://ko-fi.com/ltseverydayyou"><img src="https://img.shields.io/badge/Ko--fi-Support-FF5E5B?style=flat-square&logo=kofi&logoColor=white" alt="Ko-fi"></a>
  <img src="https://img.shields.io/badge/Luau-Nameless%20Admin-00A2FF?style=flat-square&logo=lua&logoColor=white" alt="Luau">
</p>

<img src="Github_Images/banner.png" alt="Nameless Admin Banner" width="820">

</div>

---

## Load

The entrypoints below are intentionally small bootstraps. They load the
ordered runtime chunks from `NA-split/common/`, so executors do not have to
compile the former 5 MB monolith as one unit.

The bootstrap checks the remote chunk manifest and refreshes stale local
chunks automatically when a new version is published. Runtime chunks and the
loader itself are cached under `NA-split/`, so the last complete copy can run
when GitHub is unavailable.

```lua
local url = "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"
local cache = "NA-split/Source.lua"
local ok, source = pcall(game.HttpGet, game, url)
local chunk, compileError

if ok and type(source) == "string" and source ~= "" then
    chunk, compileError = loadstring(source)
    if chunk and type(writefile) == "function" then
        if type(makefolder) == "function" then pcall(makefolder, "NA-split") end
        pcall(writefile, cache, source)
    end
end

if not chunk and type(readfile) == "function" then
    local readOk, cached = pcall(readfile, cache)
    if readOk and type(cached) == "string" and cached ~= "" then
        chunk, compileError = loadstring(cached)
    end
end

assert(chunk, compileError or "Nameless Admin loader unavailable and no local cache exists")
chunk()
```

<details>
<summary><b>Testing build</b></summary>

Use the same resilient launcher with the testing entrypoint/cache:

```lua
local url = "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NA%20testing.lua"
local cache = "NA-split/NA testing.lua"
local ok, source = pcall(game.HttpGet, game, url)
local chunk, compileError

if ok and type(source) == "string" and source ~= "" then
    chunk, compileError = loadstring(source)
    if chunk and type(writefile) == "function" then
        if type(makefolder) == "function" then pcall(makefolder, "NA-split") end
        pcall(writefile, cache, source)
    end
end

if not chunk and type(readfile) == "function" then
    local readOk, cached = pcall(readfile, cache)
    if readOk and type(cached) == "string" and cached ~= "" then
        chunk, compileError = loadstring(cached)
    end
end

assert(chunk, compileError or "Nameless Admin testing loader unavailable and no local cache exists")
chunk()
```

</details>

---

## Plugins

Put plugins here:

| Folder | Type |
|---|---|
| `Nameless-Admin/Plugins` | `.na` plugins |
| `Nameless-Admin/PluginsIY` | `.iy` plugins |

`.na` plugins use the newer `Plugin.new(...)` API.

<details open>
<summary><b>Small .na example</b></summary>

```lua
local plugin = Plugin.new("Hello")

plugin:cmd("hello", "hi")
    :args("<name>")
    :info("Say hi")
    :requiresArgs()
    :run(function(ctx, name)
        ctx:notify("Hello " .. tostring(name), 3)
    end)

plugin:cmd("fastfly")
    :info("Starts fly at speed 50")
    :run(function(ctx)
        ctx:run("fly 50")
    end)
```

</details>

Useful plugin calls:

```lua
ctx:notify("message", 3)
ctx:run("fly 50")
ctx:run("to", "random")
ctx:run({"noclip"})
```

Full docs: **https://ltseverydayyou.github.io/NA-docs/**

---

## Links

- Main file: [`Source.lua`](Source.lua)
- Testing file: [`NA testing.lua`](NA%20testing.lua)
- Commands data: [`commands.json`](commands.json)
- Discord: https://discord.gg/zzjYhtMGFD
- Support Ko-fi: https://ko-fi.com/ltseverydayyou

---

## Maintainers

<table>
<tr>
<td align="center" width="50%">
<a href="https://github.com/ltseverydayyou">
<img src="https://avatars.githubusercontent.com/u/117316014?v=4" width="96"><br>
<b>Vyperia</b><br>
<sub>@ltseverydayyou · active maintainer</sub>
</a>
</td>
<td align="center" width="50%">
<a href="https://github.com/Cosmella-v">
<img src="https://avatars.githubusercontent.com/Cosmella-v" width="96"><br>
<b>Viper</b><br>
<sub>@Cosmella-v · retired maintainer</sub>
</a>
</td>
</tr>
</table>

---

## Original Owner

<table>
<tr>
<td align="center" width="50%">
<a href="https://github.com/FilteringEnabled">
<img src="https://github.com/FilteringEnabled.png?size=96" width="96"><br>
<b>FilteringEnabled</b><br>
<sub>original account</sub>
</a>
</td>
<td align="center" width="50%">
<a href="https://github.com/yeku">
<img src="https://github.com/yeku.png?size=96" width="96"><br>
<b>yeku</b><br>
<sub>same owner / later account</sub>
</a>
</td>
</tr>
</table>

---

## License

MIT — see [`LICENSE`](LICENSE).
