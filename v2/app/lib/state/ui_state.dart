/// What the Home screen shows, derived from the Status snapshot the core sends.
///
/// The set of states is the one in the Home board of the Design artifact (the
/// `state` dropdown), plus `disconnecting` from the tray flyout. The rules live
/// in this one pure function, and the scenario files in `v2/scenarios` say what
/// every step must project to, so a change here shows up as a failing test.
library;

import '../gen/charon/v1/charon.pb.dart';

enum UiState {
  /// Decided by the app alone: the server list is empty.
  noServer('no_server'),
  disconnected('disconnected'),
  couldNotReach('could_not_reach'),
  tunnelLost('tunnel_lost'),

  /// A first connect is starting or verifying.
  verifying('verifying'),

  /// A session that was Up is being checked again after the device slept.
  wakingUp('waking_up'),

  /// A session that was Up is being checked again after a network change.
  checkingNetwork('checking_network'),
  connected('connected'),
  onBackup('on_backup'),

  /// Retrying with the kill switch off, so traffic goes direct meanwhile.
  reconnecting('reconnecting'),

  /// Retrying with traffic held by the kill switch.
  reconnectingHeld('reconnecting_held'),
  switching('switching'),

  /// All servers failed and traffic is held, waiting for the user.
  blocked('blocked'),
  disconnecting('disconnecting');

  const UiState(this.wireName);

  /// The spelling used in scenario files.
  final String wireName;

  /// Looks a state up by its scenario spelling. Throws on an unknown name, so
  /// a typo in a scenario file fails loudly.
  static UiState fromWire(String name) => values.firstWhere(
        (s) => s.wireName == name,
        orElse: () => throw ArgumentError('unknown ui state "$name"'),
      );

  /// The color family of the state, the `tone` of the Home board's STATES:
  /// checking the network is still connected, a failed first connect and a
  /// lost tunnel are idle (the board builds them on disconnected).
  StateTone get tone => switch (this) {
        connected || onBackup || checkingNetwork => StateTone.connected,
        verifying || wakingUp || reconnecting || switching => StateTone.transition,
        blocked || reconnectingHeld => StateTone.critical,
        noServer || disconnected || couldNotReach || tunnelLost || disconnecting => StateTone.idle,
      };

  /// The amber glow pulse runs for transition states only (board 03:
  /// "connected and critical never pulse").
  bool get pulses => tone == StateTone.transition;
}

/// The four color families of connection state (board 01 Color).
enum StateTone { connected, transition, critical, idle }

/// Projects a snapshot to the state the UI shows. [hasServers] is false when the
/// saved server list is empty, which is the only state the core does not know.
UiState projectState(Status status, {required bool hasServers}) {
  if (!hasServers) return UiState.noServer;
  switch (status.phase) {
    case Phase.PHASE_IDLE:
      return switch (status.lastEnd) {
        SessionEnd.SESSION_END_COULD_NOT_REACH => UiState.couldNotReach,
        SessionEnd.SESSION_END_TUNNEL_LOST => UiState.tunnelLost,
        _ => UiState.disconnected,
      };
    case Phase.PHASE_STARTING:
      return UiState.verifying;
    case Phase.PHASE_VERIFYING:
      return switch (status.probe) {
        Probe.PROBE_WAKE => UiState.wakingUp,
        Probe.PROBE_NETWORK_CHANGE => UiState.checkingNetwork,
        _ => UiState.verifying,
      };
    case Phase.PHASE_UP:
      return status.onBackup ? UiState.onBackup : UiState.connected;
    case Phase.PHASE_RETRYING:
      return status.gate == Gate.GATE_HELD ? UiState.reconnectingHeld : UiState.reconnecting;
    case Phase.PHASE_SWITCHING:
      return UiState.switching;
    case Phase.PHASE_STOPPING:
      return UiState.disconnecting;
    case Phase.PHASE_BLOCKED:
      return UiState.blocked;
    default:
      // PHASE_UNSPECIFIED. The real core never sends it. A newer core that adds
      // a phase this build does not know is stopped earlier, by the protocol
      // version check, which shows the "service needs an update" screen.
      return UiState.disconnected;
  }
}

/// Android-specific session-end anomalies (N09, HomeMobile.dc.html) projected
/// when the session is idle after an Android OS intervention.
enum AndroidSessionAnomaly {
  none('none'),
  vpnRevoked('vpn_revoked'),
  anotherVpn('another_vpn'),
  androidStopped('android_stopped');

  const AndroidSessionAnomaly(this.wireName);

  final String wireName;
}

/// Projects the Android session-end anomaly from [status]. Returns
/// [AndroidSessionAnomaly.none] when the session is not idle or ended normally.
AndroidSessionAnomaly projectAndroidAnomaly(Status status) {
  if (status.phase != Phase.PHASE_IDLE) {
    return AndroidSessionAnomaly.none;
  }
  return switch (status.lastEnd) {
    SessionEnd.SESSION_END_VPN_REVOKED => AndroidSessionAnomaly.vpnRevoked,
    SessionEnd.SESSION_END_ANOTHER_VPN => AndroidSessionAnomaly.anotherVpn,
    SessionEnd.SESSION_END_ANDROID_STOPPED => AndroidSessionAnomaly.androidStopped,
    _ => AndroidSessionAnomaly.none,
  };
}
