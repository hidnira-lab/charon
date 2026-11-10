import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';

/// Stores the sync device bearer token in the operating system's secure storage
/// (Windows Credential Manager on Windows, Android Keystore on Android, SY3).
abstract interface class TokenStore {
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<void> deleteToken();

  factory TokenStore.platform({String targetName = defaultTargetName}) {
    if (Platform.isWindows) {
      return WindowsCredentialTokenStore(targetName: targetName);
    }
    return MethodChannelTokenStore(targetName: targetName);
  }

  static const String defaultTargetName = 'CharonSync/DeviceToken';
}

/// In-memory [TokenStore] for widget and unit tests.
class MemoryTokenStore implements TokenStore {
  String? _token;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> writeToken(String token) async {
    _token = token;
  }

  @override
  Future<void> deleteToken() async {
    _token = null;
  }
}

/// Android Keystore [TokenStore] backed by a platform [MethodChannel].
class MethodChannelTokenStore implements TokenStore {
  MethodChannelTokenStore({
    this.targetName = TokenStore.defaultTargetName,
    MethodChannel? channel,
  }) : _channel = channel ?? const MethodChannel('app.charon/secure_storage');

  final String targetName;
  final MethodChannel _channel;

  @override
  Future<String?> readToken() async {
    return _channel.invokeMethod<String>('readToken', {'key': targetName});
  }

  @override
  Future<void> writeToken(String token) async {
    await _channel.invokeMethod<void>('writeToken', {
      'key': targetName,
      'value': token,
    });
  }

  @override
  Future<void> deleteToken() async {
    await _channel.invokeMethod<void>('deleteToken', {'key': targetName});
  }
}

final class _WinCredential extends Struct {
  @Uint32()
  external int flags;

  @Uint32()
  external int type;

  external Pointer<Utf16> targetName;
  external Pointer<Utf16> comment;

  @Uint64()
  external int lastWritten;

  @Uint32()
  external int credentialBlobSize;

  external Pointer<Uint8> credentialBlob;

  @Uint32()
  external int persist;

  @Uint32()
  external int attributeCount;

  external Pointer<Void> attributes;
  external Pointer<Utf16> targetAlias;
  external Pointer<Utf16> userName;
}

/// Windows Credential Manager (`CredWriteW`, `CredReadW`, `CredDeleteW` in
/// `advapi32.dll`) [TokenStore] implementation using pure Dart FFI.
class WindowsCredentialTokenStore implements TokenStore {
  WindowsCredentialTokenStore({
    this.targetName = TokenStore.defaultTargetName,
  });

  final String targetName;

  static const int _credTypeGeneric = 1;
  static const int _credPersistLocalMachine = 2;

  static final DynamicLibrary _advapi32 = DynamicLibrary.open('advapi32.dll');

  static final _credReadW = _advapi32.lookupFunction<
      Int32 Function(Pointer<Utf16>, Uint32, Uint32, Pointer<Pointer<_WinCredential>>),
      int Function(Pointer<Utf16>, int, int, Pointer<Pointer<_WinCredential>>)>('CredReadW');

  static final _credWriteW = _advapi32.lookupFunction<
      Int32 Function(Pointer<_WinCredential>, Uint32),
      int Function(Pointer<_WinCredential>, int)>('CredWriteW');

  static final _credDeleteW = _advapi32.lookupFunction<
      Int32 Function(Pointer<Utf16>, Uint32, Uint32),
      int Function(Pointer<Utf16>, int, int)>('CredDeleteW');

  static final _credFree = _advapi32.lookupFunction<
      Void Function(Pointer),
      void Function(Pointer)>('CredFree');

  @override
  Future<String?> readToken() async {
    return using((arena) {
      final targetPtr = targetName.toNativeUtf16(allocator: arena);
      final credPtrPtr = arena<Pointer<_WinCredential>>();
      final ok = _credReadW(targetPtr, _credTypeGeneric, 0, credPtrPtr);
      if (ok == 0) {
        return null;
      }
      final credPtr = credPtrPtr.value;
      try {
        final size = credPtr.ref.credentialBlobSize;
        if (size == 0 || credPtr.ref.credentialBlob == nullptr) {
          return '';
        }
        final bytes = credPtr.ref.credentialBlob.asTypedList(size);
        return utf8.decode(Uint8List.fromList(bytes));
      } finally {
        _credFree(credPtr);
      }
    });
  }

  @override
  Future<void> writeToken(String token) async {
    using((arena) {
      final targetPtr = targetName.toNativeUtf16(allocator: arena);
      final userPtr = 'charon'.toNativeUtf16(allocator: arena);
      final rawBytes = utf8.encode(token);
      final blobPtr = arena<Uint8>(rawBytes.length);
      blobPtr.asTypedList(rawBytes.length).setAll(0, rawBytes);

      final cred = arena<_WinCredential>();
      cred.ref
        ..flags = 0
        ..type = _credTypeGeneric
        ..targetName = targetPtr
        ..credentialBlobSize = rawBytes.length
        ..credentialBlob = blobPtr
        ..persist = _credPersistLocalMachine
        ..userName = userPtr;

      final ok = _credWriteW(cred, 0);
      if (ok == 0) {
        throw StateError('CredWriteW failed');
      }
    });
  }

  @override
  Future<void> deleteToken() async {
    using((arena) {
      final targetPtr = targetName.toNativeUtf16(allocator: arena);
      _credDeleteW(targetPtr, _credTypeGeneric, 0);
    });
  }
}
