# Building Mousedroid Server

Mousedroid uses a cross-platform CMake build system. Follow the instructions below based on your operating system.

---

## Prerequisites

### **Windows (Visual Studio + vcpkg)**
* **IDE:** [Visual Studio 2022/2026](https://visualstudio.microsoft.com/vs/) with the **"Desktop development with C++"** workload.
* **Package Manager:** [vcpkg](https://github.com/microsoft/vcpkg) is required for dependency management.

### **Linux (Ubuntu/Debian)**
* **Compiler:** GCC 11+ or Clang.
* **Build Tools:** CMake and Make.
* **Dependencies:** `asio` and `wxWidgets 3.3`.

---

## Build Instructions

### **Windows**

**Prerequisites:** `git` on PATH, and Visual Studio 2022 with the
**"Desktop development with C++"** workload.

1.  **One-time setup** — clones vcpkg to `%USERPROFILE%\vcpkg` and builds the
    dependencies (asio + wxWidgets; first run can take 30+ min):
    ```bat
    server\install.bat
    ```

2.  **Build + deploy** — compiles x64-Release and copies the result into
    `server\dist\`:
    ```bat
    server\release.bat
    ```
    Re-run this after any code change. If you keep vcpkg elsewhere, set the
    `VCPKG_ROOT` environment variable and both scripts use it.

Details: [docs/INSTALL.md](docs/INSTALL.md), [docs/RELEASE.md](docs/RELEASE.md).



---

### **Linux**

1.  **Install Dependencies** Install the required development packages via `apt`:
    ```bash
    sudo apt update
    sudo apt install build-essential cmake libwxgtk3.3-dev libasio-dev adb
    ```

2.  **Configure & Compile** Use the standard CMake out-of-source build workflow:
    ```bash
    cmake -B"cmake" -DCMAKE_BUILD_TYPE=Release
    cd cmake
    make
    ```

3.  **System Installation** Run the installation script to set up `uinput` permissions (allowing mouse control without root) and create the desktop launcher:
    ```bash
    cd ..
    chmod +x release.sh
    ./release.sh

    chmod +x install.sh
    ./install.sh
    ```



---

## 🔒 Password protection

By default any device on the network that reaches the server can control this PC.
Set a shared password to require it:

* **Server:** open the **Settings** tab and type a password in the **Security**
  box (saved to `config.ini` as `PASSWORD=`). Empty = no password.
* **Client:** enter the same password in the **Password** field of the add-device
  dialog when saving the WiFi device.

Notes:
* USB (adb) connections are **exempt** — a physical cable already implies access.
* The password is a shared secret sent in **plaintext** over the LAN (no TLS), so
  it blocks casual access on a shared network but is not confidential against a
  sniffer. The password itself may not contain a `|` character.

---

## 🔍 Troubleshooting

| Issue | Platform | Solution |
| :--- | :--- | :--- |
| **Missing DLLs** | Windows | Ensure `install.bat` was run to copy vcpkg DLLs to the executable folder. |
| **Mouse not moving** | Linux | Ensure `install.sh` was run and you have restarted your session to apply udev rules. |
| **No Tray Icon** | Linux | If using Wayland, tray icons may be hidden. Try switching to an X11 session. |
| **vcpkg Triplets** | Windows | Ensure you are targeting `x64-windows`. Use `vcpkg install ...:x86-windows` if you need 32-bit. |
| **"Already running" message on launch** | All | A single-instance guard blocks a second copy. Mousedroid minimizes to the tray / can run at startup — check the tray or task manager and close the existing instance before relaunching. |
| **"bind: Only one usage of each socket address..."** | Windows | Port `6969` (TCP+UDP) is held by another process — usually a leftover Mousedroid instance. Close it (`taskkill /F /IM Mousedroid.exe`), or a stale `adb reverse` tunnel is holding the port; kill the `adb` server. |

---