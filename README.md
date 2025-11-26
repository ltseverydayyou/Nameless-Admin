[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/ltseverydayyou/Nameless-Admin/blob/main/LICENSE)

# Nameless Admin (Official Continuation)

<p align="center">
  <img src="Github_Images/na_Proof.png" alt="Proof of Ownership" />
</p>

> Nameless Admin is the official continuation of the original script. The project maintains legacy functionality and introduces new commands and features.

---

## Maintainers

Click a badge to view profiles.

<div align="left">
  <a href="https://github.com/ltseverydayyou">
    <img src="https://img.shields.io/badge/Aervanix%20(@ltseverydayyou)-black?logo=github&logoColor=white&labelColor=black" alt="Aervanix GitHub" />
  </a>
  <a href="https://github.com/Cosmella-v">
    <img src="https://img.shields.io/badge/Viper%20(@Cosmella)-darkgreen?logo=github&logoColor=white" alt="Viper GitHub" />
  </a>
</div>

<div align="left">
  <a href="https://scriptblox.com/u/Aervanix">
    <img src="https://img.shields.io/badge/Aervanix-black.svg?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAACBVGfHAAAAKlBMVEVHcEyMff+Mff+Mff+Mff+Mff+Mff+Mff+Mff+Mff+Mff+Mff+Mff+Mff+DauQDAAAADnRSTlMADFUlMrlw/5X0g+On0vgqudEAAADnSURBVHgBYiAZMKILMIEIZmMgcHFxNgRUIc+IEYUBFIVvbLuKFpE2O4htl3HuQ8wdRH1s2+xiZ9YyePzndOcDEAAgkGa5QBKAidn5Zq0mFXgA/PpglMVafwKhnSaU8DlIBoLbTCDbphRvWGK7COoqOSjC4wEJARJIdgEIN6GF5KANfigh+2BDUDTJTQFaMkkZAhy8ku0iUKUcLYA/yW0I4Ev2FYkQSOZ2ixBKBV4QwGwDKo7UkxPH6cMlDCBJyhWvMOGLZF9lkWLBAimPVVAG/CUNgqj3jJR2DfwM4B/TNEDyid7ZjbYuEbNd7qs3kgsAAAAASUVORK5CYII=" alt="Aervanix on ScriptBlox" />
  </a>
  <a href="https://scriptblox.com/u/Viper">
    <img src="https://img.shields.io/badge/Viper-darkgreen.svg?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAACBVGfHAAAAKlBMVEVHcEyMff+Mff+Mff+Mff+Mff+Mff+Mff+Mff+Mff+Mff+Mff+Mff+Mff+DauQDAAAADnRSTlMADFUlMrlw/5X0g+On0vgqudEAAADnSURBVHgBYiAZMKILMIEIZmMgcHFxNgRUIc+IEYUBFIVvbLuKFpE2O4htl3HuQ8wdRH1s2+xiZ9YyePzndOcDEAAgkGa5QBKAidn5Zq0mFXgA/PpglMVafwKhnSaU8DlIBoLbTCDbphRvWGK7COoqOSjC4wEJARJIdgEIN6GF5KANfigh+2BDUDTJTQFaMkkZAhy8ku0iUKUcLYA/yW0I4Ev2FYkQSOZ2ixBKBV4QwGwDKo7UkxPH6cMlDCBJyhWvMOGLZF9lkWLBAimPVVAG/CUNgqj3jJR2DfwM4B/TNEDyid7ZjbYuEbNd7qs3kgsAAAAASUVORK5CYII=" alt="Viper on ScriptBlox" />
  </a>
</div>

---

## Project Information

- **Legacy Script Support:** Old scripts are being fixed and kept functional.
- **Upcoming Features:** New commands and improvements are in active development.

---

## Community

<div align="left">
  <a href="https://discord.gg/zzjYhtMGFD">
    <img src="https://img.shields.io/badge/Nameless_Admin_Discord-969ef2?logo=discord&logoColor=blue&labelColor=969ef2" alt="Join the Discord" />
  </a>
</div>

---

## Loadstrings

### Original Script
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/FilteringEnabled/NamelessAdmin/refs/heads/main/Source"))()
```

### Current Versions
**Main**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"))()
```

**Testing**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NA%20testing.lua"))()
```

--- 

## Plugin Support — How It Works

Add custom commands to Nameless Admin by dropping `.na` plugin files in the `Plugins` folder.

### Getting Started

1. Open your executor’s `Workspace` folder.
2. Create `Nameless-Admin/Plugins/` if it doesn’t exist.
3. Add a `.na` file (e.g., `Workspace/Nameless-Admin/Plugins/test.na`).
4. Put commands into that file using one of the supported formats below.

---

### Supported Formats

You can define commands separately or as a grouped array, and you may mix both styles inside the same file.

#### Separate Command Definitions

```lua
cmdPluginAdd = {
    Aliases = {"test", "balls"},
    ArgsHint = "<arg>",
    Info = "Displays the argument using DoNotif",
    Function = function(arg)
        DoNotif("result: "..tostring(arg))
    end,
    RequiresArguments = true
}

cmdPluginAdd = {
    Aliases = {"mixalis"},
    Info = "test",
    Function = function()
        print("g")
    end,
    RequiresArguments = false
}
```

#### Grouped as an Array

```lua
cmdPluginAdd = {
    {
        Aliases = {"test", "balls"},
        ArgsHint = "<arg>",
        Info = "Displays the argument using DoNotif",
        Function = function(arg)
            DoNotif("result: "..tostring(arg))
        end,
        RequiresArguments = true
    },
    {
        Aliases = {"mixalis"},
        Info = "test",
        Function = function()
            print("g")
        end,
        RequiresArguments = false
    }
}
```

---

### Command Fields

* **Aliases**: first item is the main command name; others are aliases.
* **ArgsHint**: optional usage hint shown in help (e.g., `"<player> <amount>"`).
* **Info**: short description shown in the command list.
* **Function**: code that runs when the command is executed. Receives your arguments if `RequiresArguments` is true.
* **RequiresArguments**: set to `true` if the command must be called with args.

---

### Running Other Commands From Plugins

Inside plugin files you can call existing commands using any of these aliases:

* `cmdRun(...)`
* `RunCommand(...)`
* `runCommand(...)`

They behave like `cmd.run` and accept:

* a single string: `runCommand("fly 50")`
* varargs: `runCommand("fly", "50")`
* a token table: `runCommand({"fly","50"})`

Examples:

```lua
cmdPluginAdd = {
    Aliases = {"callfly"},
    ArgsHint = "<speed>",
    Info = "run 'fly <speed>'",
    Function = function(speed)
        local _, err = runCommand("fly "..tostring(speed))
        if err then DoNotif("run error: "..tostring(err)) end
    end,
    RequiresArguments = true
}

cmdPluginAdd = {
    Aliases = {"openlogs"},
    Info = "run 'chatlogs'",
    Function = function()
        local _, err = RunCommand("chatlogs")
        if err then DoNotif("run error: "..tostring(err)) end
    end,
    RequiresArguments = false
}
```

---

### Load Notification

When plugins load, you’ll see which file contributed which commands, for example:

```
Loaded plugins:

plugin.na (test, mixalis)
```

---

## Credits (Original Owner)

We appreciate the original creator of Nameless Admin.

<div align="left">
  <a href="https://github.com/FilteringEnabled">
    <img src="https://img.shields.io/badge/FilteringEnabled-black?logo=github&logoColor=white&labelColor=black" alt="FilteringEnabled GitHub" />
  </a>
  <a href="https://github.com/lxte">
    <img src="https://img.shields.io/badge/lxte-black?logo=github&logoColor=white" alt="lxte GitHub" />
  </a>
</div>

---

## License

Licensed under the [MIT License](https://github.com/ltseverydayyou/Nameless-Admin/blob/main/LICENSE).

---

Feel free to open issues, submit PRs, or drop by the Discord with questions.

