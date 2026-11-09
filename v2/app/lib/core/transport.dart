/// How bytes get to charon core. UI code never sees which one is in use.
library;

import 'dart:async';
import 'dart:io' show Socket;
import 'dart:typed_data';

import 'package:dart_ipc/dart_ipc.dart' as ipc;

/// The core went away, or a write was attempted after it did.
class CoreClosedException implements Exception {
  CoreClosedException([this.reason]);
  final Object? reason;
  @override
  String toString() => 'CoreClosedException${reason == null ? '' : ': $reason'}';
}

/// A byte pipe to the core. [incoming] ends when the peer goes away.
abstract interface class CoreTransport {
  Stream<Uint8List> get incoming;

  /// Throws [CoreClosedException] when the connection is already gone.
  void send(Uint8List bytes);

  Future<void> close();
}

/// A Windows named pipe, or a Unix domain socket on macOS and Linux.
///
/// Verified in V7 (docs, master section 7): a closed pipe is noticed within
/// about 12 ms, but [connect] keeps retrying for 5 seconds when the pipe does
/// not exist, so a missing service takes 5 s to report. Do not check that a
/// pipe exists before connecting, a file check opens a connection to the server.
class IpcTransport implements CoreTransport {
  IpcTransport._(this._socket);

  final Socket _socket;
  bool _closed = false;

  static Future<IpcTransport> connect(String path) async {
    final socket = await ipc.connect(path);
    return IpcTransport._(socket);
  }

  @override
  Stream<Uint8List> get incoming => _socket;

  @override
  void send(Uint8List bytes) {
    if (_closed) throw CoreClosedException();
    try {
      _socket.add(bytes);
    } catch (e) {
      _closed = true;
      throw CoreClosedException(e);
    }
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    try {
      await _socket.close();
    } catch (_) {
      // The peer may already be gone. Closing twice is not an error.
    }
  }
}

/// Two ends of an in memory connection, for tests and widget tests.
class MemoryTransport implements CoreTransport {
  MemoryTransport._(this._in, this._peerIn);

  final StreamController<Uint8List> _in;
  final StreamController<Uint8List> _peerIn;
  bool _closed = false;

  /// Returns the two ends. What one sends, the other receives.
  static (MemoryTransport, MemoryTransport) pair() {
    final a = StreamController<Uint8List>();
    final b = StreamController<Uint8List>();
    return (MemoryTransport._(a, b), MemoryTransport._(b, a));
  }

  @override
  Stream<Uint8List> get incoming => _in.stream;

  @override
  void send(Uint8List bytes) {
    if (_closed || _peerIn.isClosed) throw CoreClosedException();
    _peerIn.add(bytes);
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    // Ending our own incoming stream is how our reader notices, and ending the
    // peer's is how the peer notices.
    await _in.close();
    await _peerIn.close();
  }
}
