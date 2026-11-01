import 'dart:async';
import 'dart:io';

/// Result of probing the VPN server directly (not through the tunnel).
enum ServerReach {
  /// TCP 443 connects: the server and its IP are reachable.
  ok,

  /// TCP 443 fails but ICMP ping still answers. That is the signature of an
  /// IP the network filter has blackholed at the TCP level (what happened to the previous server
  /// IP on 2026-10-29): ping passes, every TCP port times out.
  likelyIpBlocked,

  /// Neither TCP nor ping works: the server is down or the local network is.
  unreachable,
}

Future<bool> _tcpOk(String ip, int port) async {
  try {
    final socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 4));
    socket.destroy();
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> _icmpOk(String ip) async {
  try {
    final args = Platform.isWindows ? ['-n', '2', '-w', '2000', ip] : ['-c', '2', '-W', '2', ip];
    final result = await Process.run('ping', args).timeout(const Duration(seconds: 10));
    if (result.exitCode != 0) return false;
    // Windows `ping` exits 0 even for "TTL expired in transit" replies, so
    // require a real echo reply.
    return !Platform.isWindows || result.stdout.toString().contains('TTL=');
  } catch (_) {
    return false;
  }
}

/// Probes [ip]:[port] directly. Any one of three TCP attempts succeeding is
/// enough to call the server reachable (single SYNs get lost on flaky mobile
/// links, which is not the same as a block).
Future<ServerReach> diagnoseServer(String ip, {int port = 443}) async {
  final attempts = await Future.wait([_tcpOk(ip, port), _tcpOk(ip, port), _tcpOk(ip, port)]);
  if (attempts.any((ok) => ok)) return ServerReach.ok;
  return await _icmpOk(ip) ? ServerReach.likelyIpBlocked : ServerReach.unreachable;
}
