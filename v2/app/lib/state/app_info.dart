/// The version of this build. One place, so the licences page, the diagnostics
/// text, the About card and the Hello to the service do not each carry their own copy.
/// A release build gets it from `package-release.ps1 -Version` (`--dart-define`), the
/// default is for a developer's run and the tests, and a test keeps it equal to the
/// pubspec and to the default of the service.
const appVersion = String.fromEnvironment('CHARON_VERSION', defaultValue: '0.1.0');

/// The xray-core release this build pins. A test checks it against the service.
const xrayPinnedVersion = '26.10.31';

/// SHA-256 of the 32 byte primary Ed25519 release key embedded in
/// `core/update/manifest.go`. A test recomputes it from that file, so the two
/// cannot drift apart. It is the key that signs Charon releases, shown on the
/// Updates screen so it can be compared with the one in SECURITY.md.
const updateSigningFingerprint =
    'SHA256: eb8ccdaedf05f04707c7bb4be99aadafc0f93ca801b89abd32b48700b2c97034';
