import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../gen/charon/v1/charon.pb.dart';

enum VaultErrorCode {
  invalidMarker,
  newerFormatVersion,
  unsupportedVersion,
  unsupportedAlgorithm,
  parametersBelowFloor,
  parametersExcessive,
  vaultTooLarge,
  vaultTruncated,
  wrongPassphraseOrTampered,
  corruptPlaintext,
}

class VaultException implements Exception {
  const VaultException(this.code, this.message);

  final VaultErrorCode code;
  final String message;

  @override
  String toString() => 'VaultException($code): $message';
}

class VaultHeader {
  const VaultHeader({
    required this.version,
    required this.kdfId,
    required this.memoryKiB,
    required this.iterations,
    required this.parallelism,
    required this.salt,
    required this.aeadId,
    required this.nonce,
  });

  final int version;
  final int kdfId;
  final int memoryKiB;
  final int iterations;
  final int parallelism;
  final Uint8List salt;
  final int aeadId;
  final Uint8List nonce;

  Uint8List encode() {
    final out = Uint8List(VaultCodec.headerSize);
    out.setRange(0, 8, VaultCodec.markerBytes);
    out[8] = version;
    out[9] = kdfId;
    final bd = ByteData.sublistView(out);
    bd.setUint32(10, memoryKiB, Endian.big);
    out[14] = iterations;
    out[15] = parallelism;
    out.setRange(16, 32, salt);
    out[32] = aeadId;
    out.setRange(33, 45, nonce);
    return out;
  }
}

class VaultCodec {
  const VaultCodec._();

  static const int headerSize = 45;
  static const int formatVersion = 1;
  static const int kdfArgon2id = 1;
  static const int aeadAes256Gcm = 1;

  static const int defaultMemoryKiB = 64 * 1024;
  static const int defaultIterations = 3;
  static const int defaultParallelism = 1;

  static const int floorMemoryKiB = 19 * 1024;
  static const int floorIterations = 2;
  static const int floorParallelism = 1;

  static const int maxMemoryKiB = 256 * 1024;
  static const int maxIterations = 16;
  static const int maxParallelism = 4;

  static const int paddingMultiple = 4096;
  static const int maxVaultSize = 1 << 20; // 1 MiB
  static const int gcmTagSize = 16;

  static final Uint8List markerBytes =
      Uint8List.fromList(ascii.encode('CHARONV1'));

  static VaultHeader parseHeader(Uint8List raw) {
    if (raw.length < headerSize) {
      throw const VaultException(
        VaultErrorCode.vaultTruncated,
        'Vault file is truncated.',
      );
    }
    for (var i = 0; i < 8; i++) {
      if (raw[i] != markerBytes[i]) {
        throw const VaultException(
          VaultErrorCode.invalidMarker,
          'Not a valid Charon vault file.',
        );
      }
    }
    final ver = raw[8];
    if (ver > formatVersion) {
      throw const VaultException(
        VaultErrorCode.newerFormatVersion,
        'This vault comes from a newer version of Charon. Update the app first.',
      );
    }
    if (ver == 0) {
      throw const VaultException(
        VaultErrorCode.unsupportedVersion,
        'Unsupported vault format version.',
      );
    }

    final bd = ByteData.sublistView(raw);
    final kdfId = raw[9];
    final memoryKiB = bd.getUint32(10, Endian.big);
    final iterations = raw[14];
    final parallelism = raw[15];
    final salt = Uint8List.fromList(raw.sublist(16, 32));
    final aeadId = raw[32];
    final nonce = Uint8List.fromList(raw.sublist(33, 45));

    if (kdfId != kdfArgon2id || aeadId != aeadAes256Gcm) {
      throw const VaultException(
        VaultErrorCode.unsupportedAlgorithm,
        'Vault uses an unsupported encryption algorithm.',
      );
    }
    if (memoryKiB < floorMemoryKiB ||
        iterations < floorIterations ||
        parallelism < floorParallelism) {
      throw const VaultException(
        VaultErrorCode.parametersBelowFloor,
        'Vault key derivation parameters are below the safety floor.',
      );
    }
    if (memoryKiB > maxMemoryKiB ||
        iterations > maxIterations ||
        parallelism > maxParallelism) {
      throw const VaultException(
        VaultErrorCode.parametersExcessive,
        'Vault key derivation parameters exceed the safety ceiling.',
      );
    }

    return VaultHeader(
      version: ver,
      kdfId: kdfId,
      memoryKiB: memoryKiB,
      iterations: iterations,
      parallelism: parallelism,
      salt: salt,
      aeadId: aeadId,
      nonce: nonce,
    );
  }

  static Future<Uint8List> seal(
    SyncPayload payload,
    String passphrase, {
    int memoryKiB = defaultMemoryKiB,
    int iterations = defaultIterations,
    int parallelism = defaultParallelism,
    Uint8List? salt,
    Uint8List? nonce,
    bool useIsolate = true,
  }) async {
    if (memoryKiB < floorMemoryKiB ||
        iterations < floorIterations ||
        parallelism < floorParallelism) {
      throw const VaultException(
        VaultErrorCode.parametersBelowFloor,
        'Vault key derivation parameters are below the safety floor.',
      );
    }
    if (memoryKiB > maxMemoryKiB ||
        iterations > maxIterations ||
        parallelism > maxParallelism) {
      throw const VaultException(
        VaultErrorCode.parametersExcessive,
        'Vault key derivation parameters exceed the safety ceiling.',
      );
    }

    final rng = Random.secure();
    final actualSalt = salt ??
        Uint8List.fromList(List<int>.generate(16, (_) => rng.nextInt(256)));
    final actualNonce = nonce ??
        Uint8List.fromList(List<int>.generate(12, (_) => rng.nextInt(256)));

    final hdr = VaultHeader(
      version: formatVersion,
      kdfId: kdfArgon2id,
      memoryKiB: memoryKiB,
      iterations: iterations,
      parallelism: parallelism,
      salt: actualSalt,
      aeadId: aeadAes256Gcm,
      nonce: actualNonce,
    );
    final hdrBytes = hdr.encode();
    final protoBytes = payload.writeToBuffer();

    Future<Uint8List> work() => _sealBytes(
          protoBytes: protoBytes,
          passphrase: passphrase,
          hdrBytes: hdrBytes,
          memoryKiB: memoryKiB,
          iterations: iterations,
          parallelism: parallelism,
          salt: actualSalt,
          nonce: actualNonce,
        );

    return useIsolate ? Isolate.run(work) : work();
  }

  static Future<(SyncPayload, VaultHeader)> open(
    Uint8List blob,
    String passphrase, {
    bool useIsolate = true,
  }) async {
    if (blob.length > maxVaultSize) {
      throw const VaultException(
        VaultErrorCode.vaultTooLarge,
        'Vault exceeds the 1 MiB maximum size.',
      );
    }
    if (blob.length < headerSize + paddingMultiple + gcmTagSize) {
      throw const VaultException(
        VaultErrorCode.vaultTruncated,
        'Vault file is truncated.',
      );
    }

    final hdr = parseHeader(blob);
    final bodyLen = blob.length - headerSize;
    final plainLen = bodyLen - gcmTagSize;
    if (plainLen <= 0 || plainLen % paddingMultiple != 0) {
      throw const VaultException(
        VaultErrorCode.corruptPlaintext,
        'Vault ciphertext length is not aligned.',
      );
    }

    Future<Uint8List> work() => _openBytes(
          blob: blob,
          passphrase: passphrase,
          memoryKiB: hdr.memoryKiB,
          iterations: hdr.iterations,
          parallelism: hdr.parallelism,
          salt: hdr.salt,
          nonce: hdr.nonce,
        );

    final protoBytes = await (useIsolate ? Isolate.run(work) : work());
    try {
      final payload = SyncPayload.fromBuffer(protoBytes);
      return (payload, hdr);
    } catch (_) {
      throw const VaultException(
        VaultErrorCode.corruptPlaintext,
        'Vault payload could not be decoded.',
      );
    }
  }

  static Future<Uint8List> _sealBytes({
    required Uint8List protoBytes,
    required String passphrase,
    required Uint8List hdrBytes,
    required int memoryKiB,
    required int iterations,
    required int parallelism,
    required Uint8List salt,
    required Uint8List nonce,
  }) async {
    final compressed = Uint8List.fromList(gzip.encode(protoBytes));
    final unpaddedLen = 4 + compressed.length;
    var paddedLen =
        ((unpaddedLen + paddingMultiple - 1) ~/ paddingMultiple) * paddingMultiple;
    if (paddedLen == 0) {
      paddedLen = paddingMultiple;
    }
    if (headerSize + paddedLen + gcmTagSize > maxVaultSize) {
      throw const VaultException(
        VaultErrorCode.vaultTooLarge,
        'Vault exceeds the 1 MiB maximum size.',
      );
    }

    final plaintext = Uint8List(paddedLen);
    ByteData.sublistView(plaintext).setUint32(0, compressed.length, Endian.big);
    plaintext.setRange(4, 4 + compressed.length, compressed);

    final kdf = Argon2id(
      memory: memoryKiB,
      parallelism: parallelism,
      iterations: iterations,
      hashLength: 32,
    );
    final passBytes = Uint8List.fromList(utf8.encode(passphrase));
    try {
      final secretKey = await kdf.deriveKey(
        secretKey: SecretKey(passBytes),
        nonce: salt,
      );
      final aes = AesGcm.with256bits();
      final box = await aes.encrypt(
        plaintext,
        secretKey: secretKey,
        nonce: nonce,
        aad: hdrBytes,
      );

      final out = Uint8List(headerSize + box.cipherText.length + box.mac.bytes.length);
      out.setRange(0, headerSize, hdrBytes);
      out.setRange(headerSize, headerSize + box.cipherText.length, box.cipherText);
      out.setRange(
        headerSize + box.cipherText.length,
        out.length,
        box.mac.bytes,
      );
      return out;
    } finally {
      passBytes.fillRange(0, passBytes.length, 0);
    }
  }

  static Future<Uint8List> _openBytes({
    required Uint8List blob,
    required String passphrase,
    required int memoryKiB,
    required int iterations,
    required int parallelism,
    required Uint8List salt,
    required Uint8List nonce,
  }) async {
    final hdrBytes = Uint8List.sublistView(blob, 0, headerSize);
    final cipherEnd = blob.length - gcmTagSize;
    final cipherText = Uint8List.sublistView(blob, headerSize, cipherEnd);
    final tagBytes = Uint8List.sublistView(blob, cipherEnd, blob.length);

    final kdf = Argon2id(
      memory: memoryKiB,
      parallelism: parallelism,
      iterations: iterations,
      hashLength: 32,
    );
    final passBytes = Uint8List.fromList(utf8.encode(passphrase));
    late List<int> plaintext;
    try {
      final secretKey = await kdf.deriveKey(
        secretKey: SecretKey(passBytes),
        nonce: salt,
      );
      final aes = AesGcm.with256bits();
      final box = SecretBox(
        cipherText,
        nonce: nonce,
        mac: Mac(tagBytes),
      );
      plaintext = await aes.decrypt(
        box,
        secretKey: secretKey,
        aad: hdrBytes,
      );
    } on SecretBoxAuthenticationError {
      throw const VaultException(
        VaultErrorCode.wrongPassphraseOrTampered,
        "Couldn't decrypt with that passphrase. Nothing was changed.",
      );
    } finally {
      passBytes.fillRange(0, passBytes.length, 0);
    }

    final plainBytes = Uint8List.fromList(plaintext);
    if (plainBytes.length < 4) {
      throw const VaultException(
        VaultErrorCode.corruptPlaintext,
        'Vault plaintext is too short.',
      );
    }
    final gzLen = ByteData.sublistView(plainBytes).getUint32(0, Endian.big);
    if (gzLen <= 0 || 4 + gzLen > plainBytes.length) {
      throw const VaultException(
        VaultErrorCode.corruptPlaintext,
        'Vault inner compressed length is out of bounds.',
      );
    }
    for (var i = 4 + gzLen; i < plainBytes.length; i++) {
      if (plainBytes[i] != 0) {
        throw const VaultException(
          VaultErrorCode.corruptPlaintext,
          'Vault padding contains non-zero bytes.',
        );
      }
    }

    try {
      final decompressed = gzip.decode(plainBytes.sublist(4, 4 + gzLen));
      if (decompressed.length > maxVaultSize) {
        throw const VaultException(
          VaultErrorCode.vaultTooLarge,
          'Decompressed vault payload exceeds 1 MiB.',
        );
      }
      return Uint8List.fromList(decompressed);
    } on VaultException {
      rethrow;
    } catch (_) {
      throw const VaultException(
        VaultErrorCode.corruptPlaintext,
        'Vault inner gzip stream is corrupt.',
      );
    }
  }
}

/// File export and import adapter over the .charonvault format (SY1, section 7).
class FileVaultAdapter {
  const FileVaultAdapter();

  static const String fileExtension = '.charonvault';

  Future<void> exportToFile(File target, Uint8List vaultBytes) async {
    if (vaultBytes.length > VaultCodec.maxVaultSize) {
      throw const VaultException(
        VaultErrorCode.vaultTooLarge,
        'Vault exceeds the 1 MiB maximum size.',
      );
    }
    VaultCodec.parseHeader(vaultBytes);
    final tmp = File('${target.path}.tmp');
    await tmp.writeAsBytes(vaultBytes, flush: true);
    await tmp.rename(target.path);
  }

  Future<Uint8List> importFromFile(File source) async {
    final len = await source.length();
    if (len > VaultCodec.maxVaultSize) {
      throw const VaultException(
        VaultErrorCode.vaultTooLarge,
        'Vault exceeds the 1 MiB maximum size.',
      );
    }
    final bytes = await source.readAsBytes();
    VaultCodec.parseHeader(bytes);
    return bytes;
  }
}
