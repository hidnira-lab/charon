import 'dart:convert';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:charon/state/ui_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart' show ProtobufEnum;

import 'support/scenarios.dart';

Status status(Phase phase, {Gate? gate, bool onBackup = false, Probe? probe, SessionEnd? lastEnd}) =>
    Status(phase: phase, gate: gate, onBackup: onBackup, probe: probe, lastEnd: lastEnd);

UiState project(Status s) => projectState(s, hasServers: true);

/// A Status built from the "expect" of a scenario step. Only the fields the UI
/// state depends on are read, and the scenario loader in Go insists that a
/// step naming a UI state pins every one of them down.
Status statusFromExpect(Map<String, dynamic> expect) {
  T pick<T extends ProtobufEnum>(List<T> all, String key, T fallback) {
    final name = expect[key] as String?;
    if (name == null) return fallback;
    return all.firstWhere((e) => e.name == name, orElse: () => throw ArgumentError('unknown $key "$name"'));
  }

  return Status(
    phase: pick(Phase.values, 'phase', Phase.PHASE_UNSPECIFIED),
    gate: pick(Gate.values, 'gate', Gate.GATE_UNSPECIFIED),
    onBackup: expect['on_backup'] as bool? ?? false,
    probe: pick(Probe.values, 'probe', Probe.PROBE_UNSPECIFIED),
    lastEnd: pick(SessionEnd.values, 'last_end', SessionEnd.SESSION_END_UNSPECIFIED),
  );
}

void main() {
  group('each rule of the Home board', () {
    test('no servers wins over everything, it is the one state the core does not know', () {
      expect(projectState(status(Phase.PHASE_UP), hasServers: false), UiState.noServer);
      expect(projectState(status(Phase.PHASE_IDLE), hasServers: false), UiState.noServer);
    });

    test('Idle is disconnected unless the last session ended badly', () {
      expect(project(status(Phase.PHASE_IDLE)), UiState.disconnected);
      expect(project(status(Phase.PHASE_IDLE, lastEnd: SessionEnd.SESSION_END_MANUAL)), UiState.disconnected);
      expect(project(status(Phase.PHASE_IDLE, lastEnd: SessionEnd.SESSION_END_COULD_NOT_REACH)), UiState.couldNotReach);
      expect(project(status(Phase.PHASE_IDLE, lastEnd: SessionEnd.SESSION_END_TUNNEL_LOST)), UiState.tunnelLost);
    });

    test('a first connect shows verifying in both Starting and Verifying', () {
      expect(project(status(Phase.PHASE_STARTING)), UiState.verifying);
      expect(project(status(Phase.PHASE_VERIFYING)), UiState.verifying);
    });

    test('verifying after a wake or a network change is told apart by the probe', () {
      expect(project(status(Phase.PHASE_VERIFYING, probe: Probe.PROBE_WAKE)), UiState.wakingUp);
      expect(project(status(Phase.PHASE_VERIFYING, probe: Probe.PROBE_NETWORK_CHANGE)), UiState.checkingNetwork);
    });

    test('Up is connected, or on backup when onBackup is set', () {
      expect(project(status(Phase.PHASE_UP)), UiState.connected);
      expect(project(status(Phase.PHASE_UP, onBackup: true)), UiState.onBackup);
    });

    test('Retrying is reconnecting held only while the gate holds traffic', () {
      expect(project(status(Phase.PHASE_RETRYING, gate: Gate.GATE_HELD)), UiState.reconnectingHeld);
      expect(project(status(Phase.PHASE_RETRYING, gate: Gate.GATE_DISARMED)), UiState.reconnecting);
    });

    test('the remaining phases', () {
      expect(project(status(Phase.PHASE_SWITCHING)), UiState.switching);
      expect(project(status(Phase.PHASE_BLOCKED, gate: Gate.GATE_HELD)), UiState.blocked);
      expect(project(status(Phase.PHASE_STOPPING)), UiState.disconnecting);
    });

    test('a snapshot with no phase falls back to disconnected, it never throws', () {
      expect(project(Status()), UiState.disconnected);
    });

    test('Android session-end anomalies project when Idle and clear otherwise', () {
      expect(
        projectAndroidAnomaly(status(Phase.PHASE_IDLE, lastEnd: SessionEnd.SESSION_END_VPN_REVOKED)),
        AndroidSessionAnomaly.vpnRevoked,
      );
      expect(
        projectAndroidAnomaly(status(Phase.PHASE_IDLE, lastEnd: SessionEnd.SESSION_END_ANOTHER_VPN)),
        AndroidSessionAnomaly.anotherVpn,
      );
      expect(
        projectAndroidAnomaly(status(Phase.PHASE_IDLE, lastEnd: SessionEnd.SESSION_END_ANDROID_STOPPED)),
        AndroidSessionAnomaly.androidStopped,
      );
      expect(
        projectAndroidAnomaly(status(Phase.PHASE_IDLE, lastEnd: SessionEnd.SESSION_END_MANUAL)),
        AndroidSessionAnomaly.none,
      );
      expect(
        projectAndroidAnomaly(status(Phase.PHASE_UP, lastEnd: SessionEnd.SESSION_END_VPN_REVOKED)),
        AndroidSessionAnomaly.none,
      );
    });
  });

  test('every wire name round trips, and an unknown one throws', () {
    for (final s in UiState.values) {
      expect(UiState.fromWire(s.wireName), s);
    }
    expect(() => UiState.fromWire('happy'), throwsArgumentError);
  });

  // The scenario files are the spec. For every step that says what the app
  // shows, the projection of that step's expected Status must agree.
  group('scenarios', () {
    final files = scenarioFiles();
    final seen = <UiState>{};

    test('there are scenario files to test against', () {
      expect(files, isNotEmpty);
    });

    for (final file in files) {
      test(file.uri.pathSegments.last, () {
        final scenario = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final steps = scenario['steps'] as List<dynamic>;
        for (var i = 0; i < steps.length; i++) {
          final step = steps[i] as Map<String, dynamic>;
          final ui = step['ui'] as String?;
          expect(ui, isNotNull, reason: 'step $i has no ui');
          final want = UiState.fromWire(ui!);
          final got = project(statusFromExpect(step['expect'] as Map<String, dynamic>));
          expect(got, want, reason: 'step $i (${(step['input'] as Map)['type']})');
          seen.add(want);
        }
      });
    }

    test('together they exercise every state a step can lead to', () {
      final missing = UiState.values.where((s) => s != UiState.noServer && !seen.contains(s));
      expect(missing, isEmpty);
    });
  });
}
