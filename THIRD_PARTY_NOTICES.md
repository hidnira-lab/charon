# Third party notices

Charon is licensed under GPL 3.0 (see `LICENSE`). It includes or ships the following third party software and assets, each under its own licence.

## Xray core

* Licence: Mozilla Public License 2.0
* Source: https://github.com/XTLS/Xray-core (release v26.3.27)
* Use: runs as a separate `xray` binary on Windows (placed by hand in a git ignored folder, not stored in this repository). On Android a prebuilt `libxray.so` from the official release is stored at `charon_vpn/android/app/src/main/jniLibs/arm64-v8a/`. It is unmodified.

## tproxy-config

* Licence: MIT
* Source: https://github.com/ssrlive/tproxy-config (version 7.0.7, authors listed in its `Cargo.toml`)
* Use: vendored in `vendor/tproxy-config-7.0.7/` with one local patch that starts its helper commands without opening a console window on Windows. The patch is marked in `src/lib.rs`.

## Protocol Buffers for Go

* Licence: BSD 3 Clause
* Source: https://github.com/protocolbuffers/protobuf-go (`google.golang.org/protobuf`, version v1.36.12)
* Use: runtime library of the Go module in `v2/core/`. The generated file `v2/core/gen/charonv1/charon.pb.go` is produced from `v2/proto/` with `protoc` and `protoc-gen-go`. Both are build tools and are not shipped.

## go-winio

* Licence: MIT
* Source: https://github.com/microsoft/go-winio (version v0.6.4)
* Use: named pipe listener on Windows in `v2/core/cmd/fakecore/`. It will also serve the real service pipe in M2. It pulls in `golang.org/x/sys` (BSD 3 Clause).

## Dart packages of the v2 app

Used by `v2/app/`. Versions are pinned in `v2/app/pubspec.lock`.

| Package | Licence | Use |
|---|---|---|
| dart_ipc 2.0.2 (https://github.com/monkeyWie/dart_ipc) | MIT | Talks to the Charon service over a Windows named pipe, or a Unix socket |
| win32 6.4.0 | BSD 3 Clause | Windows API calls under dart_ipc |
| ffi | BSD 3 Clause | Native memory helpers under dart_ipc |
| protobuf 6.1.0 | BSD 3 Clause | Runtime for the generated message classes in `v2/app/lib/gen/` |
| fixnum 1.1.1 | BSD 3 Clause | 64 bit integers, which protobuf uses for uint64 fields |
| intl | BSD 3 Clause | Message formatting for the three languages |

`protoc_plugin` (BSD 3 Clause) generates the Dart message classes and is a build tool that is not shipped. The Flutter SDK and its libraries are BSD 3 Clause.

## Fonts

All three families are licensed under the SIL Open Font License 1.1. The licence texts are next to the font files in `charon_vpn/assets/fonts/`.

| Font | Copyright | Licence text |
|---|---|---|
| Inter | 2016 The Inter Project Authors (https://github.com/rsms/inter) | `OFL-Inter.txt` |
| JetBrains Mono | 2020 The JetBrains Mono Project Authors (https://github.com/JetBrains/JetBrainsMono) | `OFL-JetBrainsMono.txt` |
| Rajdhani | 2014 Indian Type Foundry | `OFL-Rajdhani.txt` |

## Other dependencies

Rust crates are listed in `Cargo.lock`, Dart packages in `charon_vpn/pubspec.lock` and Go modules in `v2/core/go.sum`. Each keeps its own licence. The Lucide icon set (ISC licence) is used through the `lucide_icons_flutter` package.

## Not stored here

`wintun.dll` is not part of this repository. Its redistribution terms are still to be checked before any Windows release that bundles it.
