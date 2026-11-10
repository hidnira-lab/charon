import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/state/home_controller.dart';
import 'package:charon/sync/sync_client.dart';
import 'package:charon/sync/token_store.dart';
import 'package:charon/sync/vault_codec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('End-to-End Sync Client + Real charonsync Server (M5)', () {
    late Directory tempDir;
    late String serverExePath;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('charon_sync_e2e_');
      serverExePath = '${tempDir.path}\\charonsync_test.exe';

      final buildRes = await Process.run(
        'go',
        ['build', '-o', serverExePath, './cmd/charonsync'],
        workingDirectory: '..\\server\\charonsync',
      );
      if (buildRes.exitCode != 0) {
        fail('Failed to build charonsync:\n${buildRes.stdout}\n${buildRes.stderr}');
      }
    });

    tearDownAll(() async {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    });

    test('refuses plain http:// URLs for non-loopback hosts (SY7)', () {
      expect(
        () => SyncServerClient(baseUrl: 'http://sync.example.com:8443'),
        throwsA(
          isA<SyncServerException>().having(
            (e) => e.reason,
            'reason',
            SyncErrorReason.certificateInvalid,
          ),
        ),
      );
    });

    test(
      'full two-device enroll, pair, push, pull, 412 conflict resolution, rollback detection, file backup/restore, and unpair',
      () async {
        final dataDir = await Directory('${tempDir.path}\\server_data').create();

        // 1. Run `charonsync init` to obtain the one-time bootstrap secret.
        final initRes = await Process.run(
          serverExePath,
          ['init', '-data-dir', dataDir.path],
        );
        expect(initRes.exitCode, 0, reason: '${initRes.stderr}');
        final bootstrapSecret = (initRes.stdout as String)
            .trim()
            .replaceFirst('CHARONSYNC_BOOTSTRAP_SECRET=', '');
        expect(bootstrapSecret, startsWith('charon-boot-'));

        // Pick an ephemeral loopback port.
        final probeSocket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        final port = probeSocket.port;
        await probeSocket.close();
        final serverUrl = 'http://127.0.0.1:$port';

        // 2. Start `charonsync serve` in loopback reverse-proxy test mode.
        final proc = await Process.start(
          serverExePath,
          [
            'serve',
            '-data-dir',
            dataDir.path,
            '-listen',
            '127.0.0.1:$port',
            '-behind-tls-proxy',
          ],
        );
        final readyCompleter = Completer<void>();
        proc.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
          if (line.contains('listening on') && !readyCompleter.isCompleted) {
            readyCompleter.complete();
          }
        });

        try {
          await readyCompleter.future.timeout(const Duration(seconds: 5));

          const passphrase = 'correct-horse-battery-staple';

          // Create Device A controller using fast OWASP floor params for test speed.
          final devA = HomeController(
            themeMode: ThemeMode.light,
            locale: const Locale('id'),
            initialConfig: Config(
              chosenServerId: 'srv-doc-1',
              servers: [
                Server(
                  id: 'srv-doc-1',
                  displayName: 'Doc Relay 1',
                  countryCode: 'SG',
                  address: '192.0.2.10',
                  port: 443,
                  uuid: '00000000-0000-4000-8000-000000000001',
                  reality: Reality(
                    publicKey: 'doc-public-key-1',
                    shortId: '01020304',
                    serverName: 'example.com',
                  ),
                  quota: QuotaPlan(
                    capGb: 500,
                    billingDay: 15,
                    counts: CountsMode.COUNTS_OUT_ONLY,
                  ),
                ),
              ],
              split: SplitTunnel(
                mode: SplitMode.SPLIT_ALL_EXCEPT_LISTED,
                allExceptListed: [
                  Rule(kind: RuleKind.RULE_DOMAIN, value: 'example.com'),
                ],
              ),
              settings: Settings(
                killSwitch: true,
                autoReconnect: true,
                allowLocalNetwork: false,
              ),
            ),
            syncController: SyncController(
              tokenStore: MemoryTokenStore(),
              kdfMemoryKiB: VaultCodec.floorMemoryKiB,
              kdfIterations: VaultCodec.floorIterations,
              kdfParallelism: VaultCodec.floorParallelism,
              useIsolateForCrypto: false,
            ),
          );
          devA.setGreetingName('LocalOnlyNameA');
          devA.setCity('LocalOnlyCityA');
          devA.setLaunchAtStartup(true);

          // Wrong bootstrap key fails with invalidBootstrapKey.
          final badEnroll = await devA.enrollSyncServer(
            serverUrl: serverUrl,
            bootstrapSecret: 'charon-boot-wrong',
            deviceName: 'Desktop-A',
            allowLoopbackHttpForTests: true,
          );
          expect(badEnroll, isFalse);
          expect(devA.sync.state, SyncState.error);
          expect(devA.sync.errorReason, SyncErrorReason.invalidBootstrapKey);

          // Valid bootstrap key enrolls Device A.
          final enrolled = await devA.enrollSyncServer(
            serverUrl: serverUrl,
            bootstrapSecret: bootstrapSecret,
            deviceName: 'Desktop-A',
            allowLoopbackHttpForTests: true,
          );
          expect(enrolled, isTrue);
          expect(devA.sync.state, SyncState.paired);
          expect(devA.sync.lastSeenRevision, 0);

          // Device A pushes revision 1.
          final pushed1 = await devA.pushSyncVault(passphrase);
          expect(pushed1, isTrue);
          expect(devA.sync.lastSeenRevision, 1);

          // Device A issues an 8-character pairing code.
          final ticket = await devA.issueSyncPairingCode();
          expect(ticket, isNotNull);
          expect(ticket!.rawCode, hasLength(8));
          expect(
            ticket.qrUri('sync.example.com:8443'),
            'charon://pair?h=sync.example.com:8443&t=${ticket.rawCode}',
          );

          // Device B starts empty with default local preferences.
          final devB = HomeController(
            hasServers: false,
            syncController: SyncController(
              tokenStore: MemoryTokenStore(),
              kdfMemoryKiB: VaultCodec.floorMemoryKiB,
              kdfIterations: VaultCodec.floorIterations,
              kdfParallelism: VaultCodec.floorParallelism,
              useIsolateForCrypto: false,
            ),
          );

          // Device B pairs using the formatted code.
          final pairedB = await devB.pairSyncWithCode(
            serverUrl: serverUrl,
            code: ticket.formattedCode.toLowerCase(),
            deviceName: 'Laptop-B',
            allowLoopbackHttpForTests: true,
          );
          expect(pairedB, isTrue);
          expect(devB.sync.state, SyncState.paired);

          // Pulling with wrong passphrase fails AEAD check and changes nothing.
          final badPull = await devB.pullSyncVault('wrong-passphrase-123');
          expect(badPull, isFalse);
          expect(devB.sync.state, SyncState.error);
          expect(devB.sync.errorReason, SyncErrorReason.wrongPassphrase);
          expect(
            devB.sync.errorMessage,
            "Couldn't decrypt with that passphrase. Nothing was changed.",
          );
          expect(devB.hasServers, isFalse);

          // Pulling with the right passphrase decrypts and applies revision 1.
          final goodPull = await devB.pullSyncVault(passphrase);
          expect(goodPull, isTrue);
          expect(devB.sync.state, SyncState.paired);
          expect(devB.sync.lastSeenRevision, 1);
          expect(devB.hasServers, isTrue);
          expect(devB.config!.servers, hasLength(1));
          expect(devB.config!.servers.first.id, 'srv-doc-1');
          expect(devB.config!.servers.first.quota.capGb, 500);
          expect(devB.activeSplitRules.single.value, 'example.com');
          expect(devB.killSwitch, isTrue);
          expect(devB.allowLocalNetwork, isFalse);
          expect(devB.themeMode, ThemeMode.light);
          expect(devB.locale?.languageCode, 'id');

          // SY6: Non-synced local fields on Device B were NOT overwritten by Device A.
          expect(devB.greetingName, 'Day');
          expect(devB.city, 'Yogyakarta');
          expect(devB.launchAtStartup, isFalse);

          // 3. Optimistic concurrency conflict (412):
          // Device A adds srv-doc-2 and pushes revision 2.
          await devA.addServer(
            Server(
              id: 'srv-doc-2',
              displayName: 'Doc Relay 2',
              address: '198.51.100.20',
              port: 443,
            ),
          );
          expect(await devA.pushSyncVault(passphrase), isTrue);
          expect(devA.sync.lastSeenRevision, 2);

          // Device B (still at base revision 1) tries to push -> hits 412 conflict!
          final conflictPush = await devB.pushSyncVault(passphrase);
          expect(conflictPush, isFalse);
          expect(devB.sync.state, SyncState.conflict);
          expect(devB.sync.conflictInfo, isNotNull);
          expect(devB.sync.conflictInfo!.currentRevision, 2);
          expect(devB.sync.conflictInfo!.writerDeviceName, 'Desktop-A');

          // Device B resolves conflict with Pull First -> gets srv-doc-2 and advances to rev 2.
          final resolvedPull = await devB.resolveSyncConflict(
            SyncConflictChoice.pullFirst,
            passphrase: passphrase,
          );
          expect(resolvedPull, isTrue);
          expect(devB.sync.state, SyncState.paired);
          expect(devB.sync.lastSeenRevision, 2);
          expect(devB.config!.servers, hasLength(2));

          // Device A pushes revision 3; Device B hits conflict again and chooses Overwrite Server.
          await devA.setKillSwitch(false);
          expect(await devA.pushSyncVault(passphrase), isTrue);
          expect(devA.sync.lastSeenRevision, 3);

          expect(await devB.pushSyncVault(passphrase), isFalse);
          expect(devB.sync.state, SyncState.conflict);

          final resolvedOverwrite = await devB.resolveSyncConflict(
            SyncConflictChoice.overwriteServer,
            passphrase: passphrase,
          );
          expect(resolvedOverwrite, isTrue);
          expect(devB.sync.state, SyncState.paired);
          expect(devB.sync.lastSeenRevision, 4);

          // 4. Rollback detection: if Device A has already observed revision 99,
          // pulling revision 4 from the server must be rejected.
          devA.sync.setLastSeenRevision(99);
          final rollbackPull = await devA.pullSyncVault(passphrase);
          expect(rollbackPull, isFalse);
          expect(devA.sync.state, SyncState.error);
          expect(devA.sync.errorReason, SyncErrorReason.rollbackDetected);

          // 5. File backup & restore (.charonvault):
          final vaultFile = File('${tempDir.path}\\offline_backup.charonvault');
          expect(await devB.backupVaultToFile(vaultFile, passphrase), isTrue);

          final devC = HomeController(
            hasServers: false,
            syncController: SyncController(
              tokenStore: MemoryTokenStore(),
              kdfMemoryKiB: VaultCodec.floorMemoryKiB,
              kdfIterations: VaultCodec.floorIterations,
              kdfParallelism: VaultCodec.floorParallelism,
              useIsolateForCrypto: false,
            ),
          );
          expect(await devC.restoreVaultFromFile(vaultFile, passphrase), isTrue);
          expect(devC.config!.servers, hasLength(2));
          expect(devC.themeMode, ThemeMode.light);

          // 6. Self-unpair revokes Device B's token on the server and clears local state.
          await devB.unpairSyncDevice();
          expect(devB.sync.state, SyncState.unpaired);
          expect(devB.sync.lastSeenRevision, 0);

          devA.dispose();
          devB.dispose();
          devC.dispose();
        } finally {
          proc.kill();
          await proc.exitCode.timeout(
            const Duration(seconds: 3),
            onTimeout: () => -1,
          );
        }
      },
    );
  });
}
