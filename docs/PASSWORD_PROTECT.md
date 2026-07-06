# Password Protection

By default the Mousedroid server accepts **any** device that connects to it and
executes its input as real mouse/keyboard events. On a shared network that means
anyone can control the host. A shared password closes that gap: the server can
require a password, and only clients that send the matching password are allowed
to connect.

## How it works

The client's first message to the server is a `/`-delimited handshake string.
Password protection appends the password as a fifth field:

```
Manufacturer / Name / Model / ctype / password
```

When a WiFi client connects, the server compares the received password against
its configured one **before** creating the connection. On mismatch the socket is
closed immediately and no input is processed (`[SERVER] Auth failed` in the log).

- **Empty server password = disabled.** If no password is set on the server, the
  check is skipped and every client is accepted (backward compatible).
- **USB is exempt.** USB connections go over a physical cable + adb, so physical
  access is already required — the server skips the password check for them
  (`ctype = 0`).

## Setting the password

### Server

1. Open the Mousedroid window → **Settings** tab.
2. In the **Security** box, type a password in the **Password** field.
   It is saved live to `config.ini` (`PASSWORD=...`). Clear it to disable.

### Client (WiFi)

1. In the app, open the **add-device** dialog.
2. Fill in **Name**, **IP Address**, and the new **Password (optional)** field.
3. Save. The password is stored with the device and sent on every connect.

The client password must exactly match the server password.

## Security caveat

The handshake — including the password — is sent in **plaintext over a raw TCP
socket (no TLS)**. Anyone sniffing the LAN can read it. This feature blocks
casual access on a shared network (the "any device can drive my PC" problem) but
is **not** confidentiality against an active attacker. Do not reuse an important
password here. Adding TLS is out of scope for this feature.

The password may not contain a `|` character (the client stores it alongside the
address as `address|password` in its preferences).

## Files involved

**Server (C++):**
- `server/src/net/server.cpp` — `TCPDoAccept()` auth gate (WiFi enforced, USB exempt).
- `server/src/settingsmanager.{h,cpp}` — `GetPassword()` / `SetPassword()`.
- `server/src/gui/wxmain.cpp` — Settings → Security password field.
- `server/distconfig.ini`, `server/release.bat`, `server/release.sh` — default `PASSWORD=`.

**Client (Kotlin):**
- `client/app/src/main/java/com/darusc/mousedroid/Utils.kt` — appends the password to the handshake.
- `client/app/src/main/res/layout/device_add_fragment.xml` — password input field.
- `client/app/src/main/java/com/darusc/mousedroid/viewmodels/DeviceListViewModel.kt` — stores/reads the password.
- `client/app/src/main/java/com/darusc/mousedroid/fragments/DeviceList.kt` — reads the field from the dialog.
