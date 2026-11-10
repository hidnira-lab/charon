import 'dart:io';
import 'dart:typed_data';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/sync/token_store.dart';
import 'package:charon/sync/vault_codec.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const goldenPassphrase = 'correct-horse-battery-staple-charon-vault';

  SyncPayload samplePayload() {
    return SyncPayload(
      schemaVersion: 1,
      revision: Int64(3),
      writtenAtMs: Int64(1762732800000),
      writerDeviceName: 'Desk-Windows',
      config: Config(
        version: Int64(5),
        chosenServerId: 'srv-primary',
        servers: [
          Server(
            id: 'srv-primary',
            displayName: 'Example Primary',
            protocol: Protocol.PROTOCOL_VLESS_REALITY,
            address: '192.0.2.10',
            port: 443,
            uuid: '00000000-0000-0000-0000-000000000001',
            flow: 'xtls-rprx-vision',
            transport: 'tcp',
            countryCode: 'US',
            reality: Reality(
              publicKey: 'FIXTURE_REALITY_PUBLIC_KEY_PRIMARY_01',
              shortId: '01020304',
              serverName: 'example.com',
              fingerprint: 'chrome',
            ),
            quota: QuotaPlan(
              capGb: 1000,
              billingDay: 1,
              counts: CountsMode.COUNTS_OUT_ONLY,
            ),
          ),
        ],
        settings: Settings(
          killSwitch: true,
          autoReconnect: true,
          allowLocalNetwork: true,
        ),
        split: SplitTunnel(
          mode: SplitMode.SPLIT_ALL_EXCEPT_LISTED,
          allExceptListed: [
            Rule(
              kind: RuleKind.RULE_DOMAIN,
              value: 'example.com',
              includeSubdomains: true,
            ),
          ],
        ),
      ),
      ui: UiSync(
        theme: SyncTheme.SYNC_THEME_DARK,
        language: 'en',
      ),
    );
  }

  test('Dart decodes the golden .charonvault written by Go', () async {
    final file = File('../proto/fixtures/vault/vault_v1.charonvault');
    expect(file.existsSync(), isTrue);
    final raw = file.readAsBytesSync();

    final (payload, hdr) = await VaultCodec.open(raw, goldenPassphrase);
    expect(hdr.version, 1);
    expect(hdr.memoryKiB, VaultCodec.floorMemoryKiB);
    expect(hdr.iterations, VaultCodec.floorIterations);
    expect(hdr.parallelism, VaultCodec.floorParallelism);

    expect(payload.schemaVersion, 1);
    expect(payload.revision, Int64(3));
    expect(payload.writerDeviceName, 'Desk-Windows');
    expect(payload.config.servers.length, 1);
    expect(payload.config.servers.first.address, '192.0.2.10');
    expect(payload.config.settings.killSwitch, isTrue);
    expect(payload.ui.theme, SyncTheme.SYNC_THEME_DARK);
    expect(payload.ui.language, 'en');
  });

  test('Dart seal and open round-trip, 4096-byte padding, tamper detection, and floor rules', () async {
    final payload = samplePayload();
    final blob = await VaultCodec.seal(
      payload,
      goldenPassphrase,
      memoryKiB: VaultCodec.floorMemoryKiB,
      iterations: VaultCodec.floorIterations,
      parallelism: VaultCodec.floorParallelism,
    );

    // 45B header + 4096B multiple + 16B GCM tag
    expect(
      (blob.length - VaultCodec.headerSize - VaultCodec.gcmTagSize) %
          VaultCodec.paddingMultiple,
      0,
    );

    final (decoded, _) = await VaultCodec.open(blob, goldenPassphrase);
    expect(decoded, payload);

    // Wrong passphrase fails with wrongPassphraseOrTampered.
    await expectLater(
      () => VaultCodec.open(blob, 'wrong-passphrase'),
      throwsA(isA<VaultException>().having(
        (e) => e.code,
        'code',
        VaultErrorCode.wrongPassphraseOrTampered,
      )),
    );

    // Flipping a bit in header (AAD), ciphertext, or GCM tag fails authentication.
    for (final pos in [10, VaultCodec.headerSize + 8, blob.length - 1]) {
      final tampered = Uint8List.fromList(blob);
      tampered[pos] ^= 0x01;
      await expectLater(
        () => VaultCodec.open(tampered, goldenPassphrase),
        throwsA(isA<VaultException>()),
      );
    }

    // Newer format version is rejected with newerFormatVersion.
    final newer = Uint8List.fromList(blob);
    newer[8] = 2;
    await expectLater(
      () => VaultCodec.open(newer, goldenPassphrase),
      throwsA(isA<VaultException>().having(
        (e) => e.code,
        'code',
        VaultErrorCode.newerFormatVersion,
      )),
    );

    // Parameters below OWASP floor are rejected before running Argon2id.
    final belowFloor = Uint8List.fromList(blob);
    belowFloor[14] = 1; // iterations = 1 < 2
    await expectLater(
      () => VaultCodec.open(belowFloor, goldenPassphrase),
      throwsA(isA<VaultException>().having(
        (e) => e.code,
        'code',
        VaultErrorCode.parametersBelowFloor,
      )),
    );
  });

  test('FileVaultAdapter exports and imports .charonvault atomically', () async {
    final tmpDir = Directory.systemTemp.createTempSync('charon_vault_file_');
    addTearDown(() => tmpDir.deleteSync(recursive: true));

    final adapter = const FileVaultAdapter();
    final target = File('${tmpDir.path}\\backup${FileVaultAdapter.fileExtension}');
    final goldenBytes = File('../proto/fixtures/vault/vault_v1.charonvault').readAsBytesSync();

    await adapter.exportToFile(target, goldenBytes);
    expect(target.existsSync(), isTrue);

    final restoredBytes = await adapter.importFromFile(target);
    expect(restoredBytes, goldenBytes);
  });

  test('WindowsCredentialTokenStore writes, reads, updates, and deletes in Windows Credential Manager', () async {
    if (!Platform.isWindows) return;

    final targetName =
        'CharonSync/TestToken-$pid-${DateTime.now().microsecondsSinceEpoch}';
    final store = WindowsCredentialTokenStore(targetName: targetName);
    addTearDown(store.deleteToken);

    expect(await store.readToken(), isNull);

    await store.writeToken('tok_first_device_secret_01');
    expect(await store.readToken(), 'tok_first_device_secret_01');

    await store.writeToken('tok_rotated_device_secret_02');
    expect(await store.readToken(), 'tok_rotated_device_secret_02');

    await store.deleteToken();
    expect(await store.readToken(), isNull);
  });
}
