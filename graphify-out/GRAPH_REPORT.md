# Graph Report - c:\\TRAV\\_DEV\\PERSO\\wslManager  (2026-04-29)

## Corpus Check
- Corpus is ~10,957 words - fits in a single context window. You may not need a graph.

## Summary
- 120 nodes · 147 edges · 17 communities detected
- Extraction: 86% EXTRACTED · 14% INFERRED · 0% AMBIGUOUS · INFERRED: 21 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Win32 Window Lifecycle|Win32 Window Lifecycle]]
- [[_COMMUNITY_Project Docs & Epics|Project Docs & Epics]]
- [[_COMMUNITY_Flutter App Entry Point|Flutter App Entry Point]]
- [[_COMMUNITY_CMake Build & Plugins|CMake Build & Plugins]]
- [[_COMMUNITY_WSL Service & Dashboard|WSL Service & Dashboard]]
- [[_COMMUNITY_UAC & Security Design|UAC & Security Design]]
- [[_COMMUNITY_Windows Utils & Entry|Windows Utils & Entry]]
- [[_COMMUNITY_Flutter Window Bridge|Flutter Window Bridge]]
- [[_COMMUNITY_Default App Scaffold|Default App Scaffold]]
- [[_COMMUNITY_Changelog & V2 Backlog|Changelog & V2 Backlog]]
- [[_COMMUNITY_Icon & Window Class|Icon & Window Class]]
- [[_COMMUNITY_Plugin Registrant Header|Plugin Registrant Header]]
- [[_COMMUNITY_Windows Resource Header|Windows Resource Header]]
- [[_COMMUNITY_Utilities Header|Utilities Header]]
- [[_COMMUNITY_Win32 Window Header|Win32 Window Header]]
- [[_COMMUNITY_Project README|Project README]]
- [[_COMMUNITY_Portable EXE Packaging|Portable EXE Packaging]]

## God Nodes (most connected - your core abstractions)
1. `EPIC 2 — WSL Service` - 12 edges
2. `Create()` - 7 edges
3. `Destroy()` - 6 edges
4. `WSL Manager Project README` - 6 edges
5. `EPIC 1 — Setup & Infrastructure` - 6 edges
6. `OnCreate()` - 5 edges
7. `wWinMain()` - 5 edges
8. `MessageHandler()` - 5 edges
9. `Runner CMake Executable Target (wsl_manager)` - 5 edges
10. `Local JSON Schemas (templates/snapshots/config)` - 5 edges

## Surprising Connections (you probably didn't know these)
- `UpdateTheme (dark mode via registry)` --semantically_similar_to--> `TASK-004 Mica/Acrylic Effect`  [INFERRED] [semantically similar]
  wsl_manager/windows/runner/win32_window.cpp → wsl_manager_output/TODO.md
- `Utf8FromUtf16 Converter` --semantically_similar_to--> `TASK-010 WslService.listInstances (UTF-16 decode)`  [INFERRED] [semantically similar]
  wsl_manager/windows/runner/utils.h → wsl_manager_output/TODO.md
- `OnCreate()` --calls--> `RegisterPlugins()`  [INFERRED]
  wsl_manager\windows\runner\flutter_window.cpp → wsl_manager\windows\flutter\generated_plugin_registrant.cc
- `OnCreate()` --calls--> `Show()`  [INFERRED]
  wsl_manager\windows\runner\flutter_window.cpp → wsl_manager\windows\runner\win32_window.cpp
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  wsl_manager\windows\runner\main.cpp → wsl_manager\windows\runner\utils.cpp

## Hyperedges (group relationships)
- **WSL Instance Lifecycle (list → start/stop → export/import → delete)** — todo_epic2_wslservice, todo_wslmodel_wslinstance, todo_wslparser_spec, todo_wsl_commands, todo_task010_wslservice_list [INFERRED 0.88]
- **Portable EXE Build Pipeline (CMake → Flutter build → PowerShell script → ZIP)** — windows_cmakelists_project, runner_cmakelists_binary, flutter_cmakelists_flutter_assemble, todo_epic13_packaging [INFERRED 0.85]
- **Windows Native Host Layer (Win32Window + FlutterWindow + utils + entry point)** — win32_window_h_win32window, flutter_window_h_flutterwindow, utils_h_utf8fromutf16, main_cpp_wwinmain [EXTRACTED 0.95]

## Communities

### Community 0 - "Win32 Window Lifecycle"
Cohesion: 0.15
Nodes (19): OnCreate(), RegisterPlugins(), Create(), Destroy(), EnableFullDpiSupportIfAvailable(), GetClientArea(), GetThisFromHandle(), GetWindowClass() (+11 more)

### Community 1 - "Project Docs & Epics"
Cohesion: 0.14
Nodes (19): Installation Guide, WSL Manager V1 Feature List, Local Data Storage Layout (%LOCALAPPDATA%\WSLManager), WSL Manager Project README, EPIC 11 — System Tray, EPIC 12 — Settings Screen, EPIC 1 — Setup & Infrastructure, EPIC 8 — Snapshots (+11 more)

### Community 2 - "Flutter App Entry Point"
Cohesion: 0.13
Nodes (13): package:flutter/material.dart, package:flutter_test/flutter_test.dart, package:wsl_manager/main.dart, build, _incrementCounter, main, MaterialApp, MyApp (+5 more)

### Community 3 - "CMake Build & Plugins"
Cohesion: 0.19
Nodes (13): flutter_assemble CMake Custom Target, flutter_wrapper_app Static Library, flutter_wrapper_plugin Static Library, FlutterWindow Class, RegisterPlugins (no-op generated), wWinMain Entry Point, Runner CMake Executable Target (wsl_manager), CreateAndAttachConsole (+5 more)

### Community 4 - "WSL Service & Dashboard"
Cohesion: 0.17
Nodes (13): Commands Reference (Flutter/WSL/Dart), CPU Parsing Algorithm (/proc/stat), EPIC 10 — URL Download Service, EPIC 2 — WSL Service, EPIC 4 — Dashboard, EPIC 5 — Instance Creation Wizard, EPIC 6 — Instance Detail, EPIC 7 — Templates (+5 more)

### Community 5 - "UAC & Security Design"
Cohesion: 0.25
Nodes (9): Developer Notes (encoding/async/security/registry), EPIC 3 — UAC & Elevation, TASK-010 WslService.listInstances (UTF-16 decode), TASK-021 setupUser (post-import user creation), TASK-030 UacService.isElevated (win32 token), TASK-031 UacService.relaunchAsAdmin (ShellExecuteEx runas), TASK-143 UAC Manifest asInvoker Rationale, WslInstance Data Model (+1 more)

### Community 6 - "Windows Utils & Entry"
Cohesion: 0.38
Nodes (5): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16(), SetQuitOnClose()

### Community 7 - "Flutter Window Bridge"
Cohesion: 0.4
Nodes (1): FlutterWindow()

### Community 8 - "Default App Scaffold"
Cohesion: 0.5
Nodes (4): MyApp Root Widget, MyHomePage StatefulWidget, _MyHomePageState (counter state), Counter Increments Smoke Test

### Community 9 - "Changelog & V2 Backlog"
Cohesion: 0.5
Nodes (4): V1 Scope Additions over ChatGPT Study, CHANGES v1.0.0 — Initial Deliverable, Features Deferred to V2, V2 Feature Backlog

### Community 10 - "Icon & Window Class"
Cohesion: 1.0
Nodes (2): IDI_APP_ICON Resource Definition, WindowClassRegistrar Singleton

### Community 11 - "Plugin Registrant Header"
Cohesion: 1.0
Nodes (0): 

### Community 12 - "Windows Resource Header"
Cohesion: 1.0
Nodes (0): 

### Community 13 - "Utilities Header"
Cohesion: 1.0
Nodes (0): 

### Community 14 - "Win32 Window Header"
Cohesion: 1.0
Nodes (0): 

### Community 15 - "Project README"
Cohesion: 1.0
Nodes (1): wsl_manager README (scaffold placeholder)

### Community 16 - "Portable EXE Packaging"
Cohesion: 1.0
Nodes (1): EPIC 13 — Portable EXE Packaging

## Knowledge Gaps
- **32 isolated node(s):** `MyApp`, `MyHomePage`, `_MyHomePageState`, `main`, `build` (+27 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Icon & Window Class`** (2 nodes): `IDI_APP_ICON Resource Definition`, `WindowClassRegistrar Singleton`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Plugin Registrant Header`** (1 nodes): `generated_plugin_registrant.h`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Windows Resource Header`** (1 nodes): `resource.h`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Utilities Header`** (1 nodes): `utils.h`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Win32 Window Header`** (1 nodes): `win32_window.h`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Project README`** (1 nodes): `wsl_manager README (scaffold placeholder)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Portable EXE Packaging`** (1 nodes): `EPIC 13 — Portable EXE Packaging`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `EPIC 2 — WSL Service` connect `WSL Service & Dashboard` to `Project Docs & Epics`, `UAC & Security Design`?**
  _High betweenness centrality (0.121) - this node is a cross-community bridge._
- **Why does `TASK-010 WslService.listInstances (UTF-16 decode)` connect `UAC & Security Design` to `CMake Build & Plugins`, `WSL Service & Dashboard`?**
  _High betweenness centrality (0.068) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `EPIC 2 — WSL Service` (e.g. with `Project Directory Structure` and `EPIC 4 — Dashboard`) actually correct?**
  _`EPIC 2 — WSL Service` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `MyApp`, `MyHomePage`, `_MyHomePageState` to the rest of the system?**
  _32 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Project Docs & Epics` be split into smaller, more focused modules?**
  _Cohesion score 0.14 - nodes in this community are weakly interconnected._
- **Should `Flutter App Entry Point` be split into smaller, more focused modules?**
  _Cohesion score 0.13 - nodes in this community are weakly interconnected._