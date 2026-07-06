# INSTALL — Windows build dependencies (one-time)

`server\install.bat` sets up everything the server build needs. Run it **once
per machine**.

## Prerequisites

- **git** on PATH.
- **Visual Studio 2022** with the **"Desktop development with C++"** workload
  (provides MSVC, CMake, and Ninja).

## What it does

1. Picks a vcpkg location: `%VCPKG_ROOT%` if that env var is set, otherwise
   `%USERPROFILE%\vcpkg`.
2. If vcpkg isn't there yet: clones `microsoft/vcpkg` and runs
   `bootstrap-vcpkg.bat`.
3. Installs the dependencies: `asio:x64-windows` and `wxwidgets:x64-windows`.

First run compiles wxWidgets from source — **can take 30+ minutes**. Later
runs are near-instant (already installed).

## Run

```bat
server\install.bat
```

On success it prints the vcpkg path and tells you to run `release.bat`.

## Failure messages

| Message | Fix |
| :--- | :--- |
| `ERROR: git required on PATH.` | Install Git, reopen the terminal. |
| `clone failed` / `bootstrap failed` | Check network / the vcpkg path is writable. |
| `dependency install failed` | Re-run; if it persists, check the vcpkg output above. |

## Custom vcpkg location

Already have a vcpkg elsewhere? Set `VCPKG_ROOT` before running, and both
`install.bat` and `release.bat` use it:

```bat
setx VCPKG_ROOT "D:\dev\vcpkg"
```

(reopen the terminal after `setx`)

## Next

See [RELEASE.md](RELEASE.md) to build and package.
