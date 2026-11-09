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

## Fonts

All three families are licensed under the SIL Open Font License 1.1. The licence texts are next to the font files in `charon_vpn/assets/fonts/`.

| Font | Copyright | Licence text |
|---|---|---|
| Inter | 2016 The Inter Project Authors (https://github.com/rsms/inter) | `OFL-Inter.txt` |
| JetBrains Mono | 2020 The JetBrains Mono Project Authors (https://github.com/JetBrains/JetBrainsMono) | `OFL-JetBrainsMono.txt` |
| Rajdhani | 2014 Indian Type Foundry | `OFL-Rajdhani.txt` |

## Other dependencies

Rust crates are listed in `Cargo.lock` and Dart packages in `charon_vpn/pubspec.lock`. Each keeps its own licence. The Lucide icon set (ISC licence) is used through the `lucide_icons_flutter` package.

## Not stored here

`wintun.dll` is not part of this repository. Its redistribution terms are still to be checked before any Windows release that bundles it.
