<div align="center">

# Nameless Admin

**Official continuation of Nameless Admin.**

A Roblox admin script with commands, plugins, UI tools, settings, and fixes kept in one place.

<p>
  <a href="https://github.com/ltseverydayyou/Nameless-Admin/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" alt="License"></a>
  <a href="https://discord.gg/zzjYhtMGFD"><img src="https://img.shields.io/badge/Discord-Join-5865F2?style=flat-square&logo=discord&logoColor=white" alt="Discord"></a>
  <img src="https://img.shields.io/badge/Luau-Nameless%20Admin-00A2FF?style=flat-square&logo=lua&logoColor=white" alt="Luau">
</p>

<img src="Github_Images/banner.png" alt="Nameless Admin Banner" width="820">

</div>

---

## Load

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"))()
```

<details>
<summary><b>Testing build</b></summary>

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NA%20testing.lua"))()
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

---

## Maintainers

<table>
<tr>
<td align="center" width="50%">
<a href="https://github.com/ltseverydayyou">
<img src="https://avatars.githubusercontent.com/u/117316014?v=4" width="96" style="border-radius:50%"><br>
<b>Vyperia</b><br>
<sub>@ltseverydayyou</sub>
</a>
</td>
<td align="center" width="50%">
<a href="https://github.com/Cosmella-v">
<img src="https://avatars.githubusercontent.com/Cosmella-v" width="96" style="border-radius:50%"><br>
<b>Viper</b><br>
<sub>@Cosmella-v</sub>
</a>
</td>
</tr>
</table>

---

## Original Owner

[FilteringEnabled](https://github.com/FilteringEnabled) / [lxte](https://github.com/lxte)

---

## License

MIT — see [`LICENSE`](LICENSE).
