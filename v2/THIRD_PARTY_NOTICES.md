# Third-Party Notices

Charon is licensed under the GNU General Public License v3.0 (`LICENSE`). It ships with or depends on the following open source components.

## 1. Core Tunnel Engine

### Xray-core

* **License**: Mozilla Public License 2.0 (MPL 2.0)
* **Source**: https://github.com/XTLS/Xray-core (pinned release v26.10.31. Its TUN inbound writes the system routes and keeps the connections of Xray itself out of the tunnel)
* **Usage**: Bundled as a separate executable (`xray.exe`) on Windows and embedded in `charon.aar` on Android. Unmodified MPL 2.0 files remain under MPL 2.0; the combined distribution of Charon is conveyed under GPL 3.0 as permitted by MPL 2.0 Section 3.3.

## 2. Windows Network Adapter Driver

### Wintun (`wintun.dll` 0.14.1)

* **Copyright**: Copyright (C) 2018-2021 WireGuard LLC. All Rights Reserved.
* **License**: Prebuilt WHQL-signed binary distributed unmodified under WireGuard LLC's redistribution terms; driver source code is licensed under GPL 2.0.
* **Source**: https://www.wintun.net/

## 3. Go Standard Library and Modules (`core`, `platform/windows`, `platform/android`, `server/charonsync`)

* **Go Standard Library**: BSD 3-Clause License (Copyright (c) 2009 The Go Authors)
* **`google.golang.org/protobuf` (v1.36.11)**: BSD 3-Clause License
* **`golang.org/x/crypto` (v0.45.0)**: BSD 3-Clause License
* **`golang.org/x/sys` (v0.38.0)**: BSD 3-Clause License
* **`github.com/microsoft/go-winio` (v0.6.2)**: MIT License (Copyright (c) Microsoft Corporation)

## 4. Flutter SDK and Dart Packages (`app`)

* **Flutter SDK**: BSD 3-Clause License (Copyright 2014 The Flutter Authors)
* **`cryptography` (2.9.0)**: Apache License 2.0 (compatible with GPL 3.0)
* **`dart_ipc` (2.0.2)**: MIT License
* **`ffi` (2.2.0)**: BSD 3-Clause License
* **`fixnum` (1.1.1)**: BSD 3-Clause License
* **`intl` (0.20.2)**: BSD 3-Clause License
* **`path` (1.9.1)**: BSD 3-Clause License
* **`protobuf` (6.0.0)**: BSD 3-Clause License
* **`win32` (6.0.0)**: BSD 3-Clause License

## 5. Fonts

### Inter

* **Author**: Rasmus Andersson
* **License**: SIL Open Font License 1.1
* **Source**: https://github.com/rsms/inter

### Space Mono

* **Author**: Colophon Foundry
* **License**: SIL Open Font License 1.1
* **Source**: https://github.com/googlefonts/spacemono
