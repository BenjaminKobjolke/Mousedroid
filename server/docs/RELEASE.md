# RELEASE — build + deploy the Windows server

`server\release.bat` compiles the server (x64-Release) and packages it into
`server\dist\`. Run it after every code change.

**Prerequisite:** run [`install.bat`](INSTALL.md) once first (vcpkg + deps).

## Run

```bat
server\release.bat
```

## What it does

1. Locates Visual Studio via `vswhere` (any edition: Community/Pro/Enterprise).
2. Finds vcpkg (`%VCPKG_ROOT%`, else `%USERPROFILE%\vcpkg`) and captures it in
   a private `VCPKG_DIR` var.
3. Loads the MSVC dev environment (`VsDevCmd.bat`) — adds `cl`, `cmake`, `ninja`.
4. Wipes a stale `out\build\x64-Release\CMakeCache.txt` if present (a cached
   toolchain can't be changed on reconfigure).
5. Configures + builds with Ninja and the vcpkg toolchain →
   `out\build\x64-Release\bin\Mousedroid.exe`.
6. Copies the binary + DLLs into `dist\`, copies `adb\` and `app.ico`, and
   writes `distconfig.ini`.

Output: `server\dist\`.

## Failure messages

| Message | Fix |
| :--- | :--- |
| `ERROR: Visual Studio 2022 not found.` | Install VS 2022. |
| `ERROR: VS C++ tools not installed.` | Add the "Desktop development with C++" workload. |
| `ERROR: vcpkg not found at "..."` | Run [`install.bat`](INSTALL.md) first. |
| `Could not find a package ... "asio"` | Stale build dir — delete `server\out\` and re-run (the script auto-wipes the cache, but a manual delete is the fallback). |
| `Build failed` | Read the compiler errors above the message. |

## Notes

- Re-run any time after editing source — it reconfigures and rebuilds.
- To force a fully clean build, delete `server\out\` before running.
