// This is a generated file - do not edit.
//
// Generated from charon/v1/charon.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'charon.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'charon.pbenum.dart';

enum Envelope_Payload { hello, helloAck, command, response, event, notSet }

class Envelope extends $pb.GeneratedMessage {
  factory Envelope({
    $core.int? protocolVersion,
    $fixnum.Int64? requestId,
    Hello? hello,
    HelloAck? helloAck,
    Command? command,
    Response? response,
    Event? event,
  }) {
    final result = Envelope._();
    if (protocolVersion != null) result.protocolVersion = protocolVersion;
    if (requestId != null) result.requestId = requestId;
    if (hello != null) result.hello = hello;
    if (helloAck != null) result.helloAck = helloAck;
    if (command != null) result.command = command;
    if (response != null) result.response = response;
    if (event != null) result.event = event;
    return result;
  }

  Envelope._();

  factory Envelope.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Envelope()..mergeFromBuffer(data, registry);
  factory Envelope.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Envelope()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Envelope_Payload> _Envelope_PayloadByTag = {
    10: Envelope_Payload.hello,
    11: Envelope_Payload.helloAck,
    12: Envelope_Payload.command,
    13: Envelope_Payload.response,
    14: Envelope_Payload.event,
    0: Envelope_Payload.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Envelope',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: Envelope.$_createMessage)
    ..oo(0, [10, 11, 12, 13, 14])
    ..aI(1, _omitFieldNames ? '' : 'protocolVersion',
        fieldType: $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<Hello>(10, _omitFieldNames ? '' : 'hello',
        subBuilder: Hello.$_createMessage)
    ..aOM<HelloAck>(11, _omitFieldNames ? '' : 'helloAck',
        subBuilder: HelloAck.$_createMessage)
    ..aOM<Command>(12, _omitFieldNames ? '' : 'command',
        subBuilder: Command.$_createMessage)
    ..aOM<Response>(13, _omitFieldNames ? '' : 'response',
        subBuilder: Response.$_createMessage)
    ..aOM<Event>(14, _omitFieldNames ? '' : 'event',
        subBuilder: Event.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Envelope clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Envelope copyWith(void Function(Envelope) updates) =>
      super.copyWith((message) => updates(message as Envelope)) as Envelope;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Envelope() / Envelope.new instead')
  static Envelope create() => Envelope._();
  static $pb.GeneratedMessage $_createMessage() => Envelope._();
  @$core.override
  Envelope createEmptyInstance() => Envelope._();
  @$core.pragma('dart2js:noInline')
  static Envelope getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Envelope>(Envelope.$_createMessage);
  static Envelope? _defaultInstance;

  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  Envelope_Payload whichPayload() => _Envelope_PayloadByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  void clearPayload() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.int get protocolVersion => $_getIZ(0);
  @$pb.TagNumber(1)
  set protocolVersion($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProtocolVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearProtocolVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get requestId => $_getI64(1);
  @$pb.TagNumber(2)
  set requestId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRequestId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequestId() => $_clearField(2);

  @$pb.TagNumber(10)
  Hello get hello => $_getN(2);
  @$pb.TagNumber(10)
  set hello(Hello value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasHello() => $_has(2);
  @$pb.TagNumber(10)
  void clearHello() => $_clearField(10);
  @$pb.TagNumber(10)
  Hello ensureHello() => $_ensure(2);

  @$pb.TagNumber(11)
  HelloAck get helloAck => $_getN(3);
  @$pb.TagNumber(11)
  set helloAck(HelloAck value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasHelloAck() => $_has(3);
  @$pb.TagNumber(11)
  void clearHelloAck() => $_clearField(11);
  @$pb.TagNumber(11)
  HelloAck ensureHelloAck() => $_ensure(3);

  @$pb.TagNumber(12)
  Command get command => $_getN(4);
  @$pb.TagNumber(12)
  set command(Command value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasCommand() => $_has(4);
  @$pb.TagNumber(12)
  void clearCommand() => $_clearField(12);
  @$pb.TagNumber(12)
  Command ensureCommand() => $_ensure(4);

  @$pb.TagNumber(13)
  Response get response => $_getN(5);
  @$pb.TagNumber(13)
  set response(Response value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasResponse() => $_has(5);
  @$pb.TagNumber(13)
  void clearResponse() => $_clearField(13);
  @$pb.TagNumber(13)
  Response ensureResponse() => $_ensure(5);

  @$pb.TagNumber(14)
  Event get event => $_getN(6);
  @$pb.TagNumber(14)
  set event(Event value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasEvent() => $_has(6);
  @$pb.TagNumber(14)
  void clearEvent() => $_clearField(14);
  @$pb.TagNumber(14)
  Event ensureEvent() => $_ensure(6);
}

class Hello extends $pb.GeneratedMessage {
  factory Hello({
    $core.int? minProtocolVersion,
    $core.int? maxProtocolVersion,
    $core.String? appVersion,
    $core.String? clientKind,
  }) {
    final result = Hello._();
    if (minProtocolVersion != null)
      result.minProtocolVersion = minProtocolVersion;
    if (maxProtocolVersion != null)
      result.maxProtocolVersion = maxProtocolVersion;
    if (appVersion != null) result.appVersion = appVersion;
    if (clientKind != null) result.clientKind = clientKind;
    return result;
  }

  Hello._();

  factory Hello.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Hello()..mergeFromBuffer(data, registry);
  factory Hello.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Hello()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Hello',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: Hello.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'minProtocolVersion',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'maxProtocolVersion',
        fieldType: $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'appVersion')
    ..aOS(4, _omitFieldNames ? '' : 'clientKind')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Hello clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Hello copyWith(void Function(Hello) updates) =>
      super.copyWith((message) => updates(message as Hello)) as Hello;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Hello() / Hello.new instead')
  static Hello create() => Hello._();
  static $pb.GeneratedMessage $_createMessage() => Hello._();
  @$core.override
  Hello createEmptyInstance() => Hello._();
  @$core.pragma('dart2js:noInline')
  static Hello getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Hello>(Hello.$_createMessage);
  static Hello? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get minProtocolVersion => $_getIZ(0);
  @$pb.TagNumber(1)
  set minProtocolVersion($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMinProtocolVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearMinProtocolVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get maxProtocolVersion => $_getIZ(1);
  @$pb.TagNumber(2)
  set maxProtocolVersion($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMaxProtocolVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxProtocolVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get appVersion => $_getSZ(2);
  @$pb.TagNumber(3)
  set appVersion($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAppVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearAppVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get clientKind => $_getSZ(3);
  @$pb.TagNumber(4)
  set clientKind($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasClientKind() => $_has(3);
  @$pb.TagNumber(4)
  void clearClientKind() => $_clearField(4);
}

class HelloAck extends $pb.GeneratedMessage {
  factory HelloAck({
    $core.int? protocolVersion,
    $core.String? serviceVersion,
    $core.String? xrayVersion,
    $fixnum.Int64? configVersion,
    Status? status,
    Error? error,
  }) {
    final result = HelloAck._();
    if (protocolVersion != null) result.protocolVersion = protocolVersion;
    if (serviceVersion != null) result.serviceVersion = serviceVersion;
    if (xrayVersion != null) result.xrayVersion = xrayVersion;
    if (configVersion != null) result.configVersion = configVersion;
    if (status != null) result.status = status;
    if (error != null) result.error = error;
    return result;
  }

  HelloAck._();

  factory HelloAck.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HelloAck()..mergeFromBuffer(data, registry);
  factory HelloAck.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HelloAck()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HelloAck',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: HelloAck.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'protocolVersion',
        fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'serviceVersion')
    ..aOS(3, _omitFieldNames ? '' : 'xrayVersion')
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'configVersion', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<Status>(5, _omitFieldNames ? '' : 'status',
        subBuilder: Status.$_createMessage)
    ..aOM<Error>(6, _omitFieldNames ? '' : 'error',
        subBuilder: Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HelloAck clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HelloAck copyWith(void Function(HelloAck) updates) =>
      super.copyWith((message) => updates(message as HelloAck)) as HelloAck;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HelloAck() / HelloAck.new instead')
  static HelloAck create() => HelloAck._();
  static $pb.GeneratedMessage $_createMessage() => HelloAck._();
  @$core.override
  HelloAck createEmptyInstance() => HelloAck._();
  @$core.pragma('dart2js:noInline')
  static HelloAck getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HelloAck>(HelloAck.$_createMessage);
  static HelloAck? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get protocolVersion => $_getIZ(0);
  @$pb.TagNumber(1)
  set protocolVersion($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProtocolVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearProtocolVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get serviceVersion => $_getSZ(1);
  @$pb.TagNumber(2)
  set serviceVersion($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasServiceVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearServiceVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get xrayVersion => $_getSZ(2);
  @$pb.TagNumber(3)
  set xrayVersion($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasXrayVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearXrayVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get configVersion => $_getI64(3);
  @$pb.TagNumber(4)
  set configVersion($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfigVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfigVersion() => $_clearField(4);

  @$pb.TagNumber(5)
  Status get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(Status value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);
  @$pb.TagNumber(5)
  Status ensureStatus() => $_ensure(4);

  @$pb.TagNumber(6)
  Error get error => $_getN(5);
  @$pb.TagNumber(6)
  set error(Error value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasError() => $_has(5);
  @$pb.TagNumber(6)
  void clearError() => $_clearField(6);
  @$pb.TagNumber(6)
  Error ensureError() => $_ensure(5);
}

enum Command_Kind {
  connect,
  disconnect,
  cancel,
  switchNow,
  moveTo,
  tryServer,
  release,
  retryNow,
  setConfig,
  getConfig,
  subscribe,
  unsubscribe,
  checkUpdate,
  applyUpdate,
  rollbackCore,
  exportDiagnostics,
  updateFileChunk,
  notSet
}

class Command extends $pb.GeneratedMessage {
  factory Command({
    Empty? connect,
    Empty? disconnect,
    Empty? cancel,
    Empty? switchNow,
    ServerRef? moveTo,
    ServerRef? tryServer,
    Empty? release,
    Empty? retryNow,
    Config? setConfig,
    Empty? getConfig,
    Subscription? subscribe,
    Subscription? unsubscribe,
    Empty? checkUpdate,
    ApplyUpdate? applyUpdate,
    Empty? rollbackCore,
    ExportDiagnostics? exportDiagnostics,
    UpdateFileChunk? updateFileChunk,
  }) {
    final result = Command._();
    if (connect != null) result.connect = connect;
    if (disconnect != null) result.disconnect = disconnect;
    if (cancel != null) result.cancel = cancel;
    if (switchNow != null) result.switchNow = switchNow;
    if (moveTo != null) result.moveTo = moveTo;
    if (tryServer != null) result.tryServer = tryServer;
    if (release != null) result.release = release;
    if (retryNow != null) result.retryNow = retryNow;
    if (setConfig != null) result.setConfig = setConfig;
    if (getConfig != null) result.getConfig = getConfig;
    if (subscribe != null) result.subscribe = subscribe;
    if (unsubscribe != null) result.unsubscribe = unsubscribe;
    if (checkUpdate != null) result.checkUpdate = checkUpdate;
    if (applyUpdate != null) result.applyUpdate = applyUpdate;
    if (rollbackCore != null) result.rollbackCore = rollbackCore;
    if (exportDiagnostics != null) result.exportDiagnostics = exportDiagnostics;
    if (updateFileChunk != null) result.updateFileChunk = updateFileChunk;
    return result;
  }

  Command._();

  factory Command.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Command()..mergeFromBuffer(data, registry);
  factory Command.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Command()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Command_Kind> _Command_KindByTag = {
    1: Command_Kind.connect,
    2: Command_Kind.disconnect,
    3: Command_Kind.cancel,
    4: Command_Kind.switchNow,
    5: Command_Kind.moveTo,
    6: Command_Kind.tryServer,
    7: Command_Kind.release,
    8: Command_Kind.retryNow,
    9: Command_Kind.setConfig,
    10: Command_Kind.getConfig,
    11: Command_Kind.subscribe,
    12: Command_Kind.unsubscribe,
    13: Command_Kind.checkUpdate,
    14: Command_Kind.applyUpdate,
    15: Command_Kind.rollbackCore,
    16: Command_Kind.exportDiagnostics,
    17: Command_Kind.updateFileChunk,
    0: Command_Kind.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Command',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: Command.$_createMessage)
    ..oo(0, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17])
    ..aOM<Empty>(1, _omitFieldNames ? '' : 'connect',
        subBuilder: Empty.$_createMessage)
    ..aOM<Empty>(2, _omitFieldNames ? '' : 'disconnect',
        subBuilder: Empty.$_createMessage)
    ..aOM<Empty>(3, _omitFieldNames ? '' : 'cancel',
        subBuilder: Empty.$_createMessage)
    ..aOM<Empty>(4, _omitFieldNames ? '' : 'switchNow',
        subBuilder: Empty.$_createMessage)
    ..aOM<ServerRef>(5, _omitFieldNames ? '' : 'moveTo',
        subBuilder: ServerRef.$_createMessage)
    ..aOM<ServerRef>(6, _omitFieldNames ? '' : 'tryServer',
        subBuilder: ServerRef.$_createMessage)
    ..aOM<Empty>(7, _omitFieldNames ? '' : 'release',
        subBuilder: Empty.$_createMessage)
    ..aOM<Empty>(8, _omitFieldNames ? '' : 'retryNow',
        subBuilder: Empty.$_createMessage)
    ..aOM<Config>(9, _omitFieldNames ? '' : 'setConfig',
        subBuilder: Config.$_createMessage)
    ..aOM<Empty>(10, _omitFieldNames ? '' : 'getConfig',
        subBuilder: Empty.$_createMessage)
    ..aOM<Subscription>(11, _omitFieldNames ? '' : 'subscribe',
        subBuilder: Subscription.$_createMessage)
    ..aOM<Subscription>(12, _omitFieldNames ? '' : 'unsubscribe',
        subBuilder: Subscription.$_createMessage)
    ..aOM<Empty>(13, _omitFieldNames ? '' : 'checkUpdate',
        subBuilder: Empty.$_createMessage)
    ..aOM<ApplyUpdate>(14, _omitFieldNames ? '' : 'applyUpdate',
        subBuilder: ApplyUpdate.$_createMessage)
    ..aOM<Empty>(15, _omitFieldNames ? '' : 'rollbackCore',
        subBuilder: Empty.$_createMessage)
    ..aOM<ExportDiagnostics>(16, _omitFieldNames ? '' : 'exportDiagnostics',
        subBuilder: ExportDiagnostics.$_createMessage)
    ..aOM<UpdateFileChunk>(17, _omitFieldNames ? '' : 'updateFileChunk',
        subBuilder: UpdateFileChunk.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Command clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Command copyWith(void Function(Command) updates) =>
      super.copyWith((message) => updates(message as Command)) as Command;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Command() / Command.new instead')
  static Command create() => Command._();
  static $pb.GeneratedMessage $_createMessage() => Command._();
  @$core.override
  Command createEmptyInstance() => Command._();
  @$core.pragma('dart2js:noInline')
  static Command getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Command>(Command.$_createMessage);
  static Command? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  @$pb.TagNumber(15)
  @$pb.TagNumber(16)
  @$pb.TagNumber(17)
  Command_Kind whichKind() => _Command_KindByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  @$pb.TagNumber(15)
  @$pb.TagNumber(16)
  @$pb.TagNumber(17)
  void clearKind() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  Empty get connect => $_getN(0);
  @$pb.TagNumber(1)
  set connect(Empty value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasConnect() => $_has(0);
  @$pb.TagNumber(1)
  void clearConnect() => $_clearField(1);
  @$pb.TagNumber(1)
  Empty ensureConnect() => $_ensure(0);

  @$pb.TagNumber(2)
  Empty get disconnect => $_getN(1);
  @$pb.TagNumber(2)
  set disconnect(Empty value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDisconnect() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisconnect() => $_clearField(2);
  @$pb.TagNumber(2)
  Empty ensureDisconnect() => $_ensure(1);

  @$pb.TagNumber(3)
  Empty get cancel => $_getN(2);
  @$pb.TagNumber(3)
  set cancel(Empty value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCancel() => $_has(2);
  @$pb.TagNumber(3)
  void clearCancel() => $_clearField(3);
  @$pb.TagNumber(3)
  Empty ensureCancel() => $_ensure(2);

  @$pb.TagNumber(4)
  Empty get switchNow => $_getN(3);
  @$pb.TagNumber(4)
  set switchNow(Empty value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSwitchNow() => $_has(3);
  @$pb.TagNumber(4)
  void clearSwitchNow() => $_clearField(4);
  @$pb.TagNumber(4)
  Empty ensureSwitchNow() => $_ensure(3);

  @$pb.TagNumber(5)
  ServerRef get moveTo => $_getN(4);
  @$pb.TagNumber(5)
  set moveTo(ServerRef value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasMoveTo() => $_has(4);
  @$pb.TagNumber(5)
  void clearMoveTo() => $_clearField(5);
  @$pb.TagNumber(5)
  ServerRef ensureMoveTo() => $_ensure(4);

  @$pb.TagNumber(6)
  ServerRef get tryServer => $_getN(5);
  @$pb.TagNumber(6)
  set tryServer(ServerRef value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasTryServer() => $_has(5);
  @$pb.TagNumber(6)
  void clearTryServer() => $_clearField(6);
  @$pb.TagNumber(6)
  ServerRef ensureTryServer() => $_ensure(5);

  @$pb.TagNumber(7)
  Empty get release => $_getN(6);
  @$pb.TagNumber(7)
  set release(Empty value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasRelease() => $_has(6);
  @$pb.TagNumber(7)
  void clearRelease() => $_clearField(7);
  @$pb.TagNumber(7)
  Empty ensureRelease() => $_ensure(6);

  @$pb.TagNumber(8)
  Empty get retryNow => $_getN(7);
  @$pb.TagNumber(8)
  set retryNow(Empty value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasRetryNow() => $_has(7);
  @$pb.TagNumber(8)
  void clearRetryNow() => $_clearField(8);
  @$pb.TagNumber(8)
  Empty ensureRetryNow() => $_ensure(7);

  @$pb.TagNumber(9)
  Config get setConfig => $_getN(8);
  @$pb.TagNumber(9)
  set setConfig(Config value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasSetConfig() => $_has(8);
  @$pb.TagNumber(9)
  void clearSetConfig() => $_clearField(9);
  @$pb.TagNumber(9)
  Config ensureSetConfig() => $_ensure(8);

  @$pb.TagNumber(10)
  Empty get getConfig => $_getN(9);
  @$pb.TagNumber(10)
  set getConfig(Empty value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasGetConfig() => $_has(9);
  @$pb.TagNumber(10)
  void clearGetConfig() => $_clearField(10);
  @$pb.TagNumber(10)
  Empty ensureGetConfig() => $_ensure(9);

  @$pb.TagNumber(11)
  Subscription get subscribe => $_getN(10);
  @$pb.TagNumber(11)
  set subscribe(Subscription value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasSubscribe() => $_has(10);
  @$pb.TagNumber(11)
  void clearSubscribe() => $_clearField(11);
  @$pb.TagNumber(11)
  Subscription ensureSubscribe() => $_ensure(10);

  @$pb.TagNumber(12)
  Subscription get unsubscribe => $_getN(11);
  @$pb.TagNumber(12)
  set unsubscribe(Subscription value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasUnsubscribe() => $_has(11);
  @$pb.TagNumber(12)
  void clearUnsubscribe() => $_clearField(12);
  @$pb.TagNumber(12)
  Subscription ensureUnsubscribe() => $_ensure(11);

  @$pb.TagNumber(13)
  Empty get checkUpdate => $_getN(12);
  @$pb.TagNumber(13)
  set checkUpdate(Empty value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasCheckUpdate() => $_has(12);
  @$pb.TagNumber(13)
  void clearCheckUpdate() => $_clearField(13);
  @$pb.TagNumber(13)
  Empty ensureCheckUpdate() => $_ensure(12);

  @$pb.TagNumber(14)
  ApplyUpdate get applyUpdate => $_getN(13);
  @$pb.TagNumber(14)
  set applyUpdate(ApplyUpdate value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasApplyUpdate() => $_has(13);
  @$pb.TagNumber(14)
  void clearApplyUpdate() => $_clearField(14);
  @$pb.TagNumber(14)
  ApplyUpdate ensureApplyUpdate() => $_ensure(13);

  @$pb.TagNumber(15)
  Empty get rollbackCore => $_getN(14);
  @$pb.TagNumber(15)
  set rollbackCore(Empty value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasRollbackCore() => $_has(14);
  @$pb.TagNumber(15)
  void clearRollbackCore() => $_clearField(15);
  @$pb.TagNumber(15)
  Empty ensureRollbackCore() => $_ensure(14);

  @$pb.TagNumber(16)
  ExportDiagnostics get exportDiagnostics => $_getN(15);
  @$pb.TagNumber(16)
  set exportDiagnostics(ExportDiagnostics value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasExportDiagnostics() => $_has(15);
  @$pb.TagNumber(16)
  void clearExportDiagnostics() => $_clearField(16);
  @$pb.TagNumber(16)
  ExportDiagnostics ensureExportDiagnostics() => $_ensure(15);

  @$pb.TagNumber(17)
  UpdateFileChunk get updateFileChunk => $_getN(16);
  @$pb.TagNumber(17)
  set updateFileChunk(UpdateFileChunk value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasUpdateFileChunk() => $_has(16);
  @$pb.TagNumber(17)
  void clearUpdateFileChunk() => $_clearField(17);
  @$pb.TagNumber(17)
  UpdateFileChunk ensureUpdateFileChunk() => $_ensure(16);
}

class Empty extends $pb.GeneratedMessage {
  factory Empty() => Empty._();

  Empty._();

  factory Empty.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Empty()..mergeFromBuffer(data, registry);
  factory Empty.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Empty()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Empty',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: Empty.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Empty clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Empty copyWith(void Function(Empty) updates) =>
      super.copyWith((message) => updates(message as Empty)) as Empty;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Empty() / Empty.new instead')
  static Empty create() => Empty._();
  static $pb.GeneratedMessage $_createMessage() => Empty._();
  @$core.override
  Empty createEmptyInstance() => Empty._();
  @$core.pragma('dart2js:noInline')
  static Empty getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Empty>(Empty.$_createMessage);
  static Empty? _defaultInstance;
}

class ServerRef extends $pb.GeneratedMessage {
  factory ServerRef({
    $core.String? serverId,
  }) {
    final result = ServerRef._();
    if (serverId != null) result.serverId = serverId;
    return result;
  }

  ServerRef._();

  factory ServerRef.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ServerRef()..mergeFromBuffer(data, registry);
  factory ServerRef.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ServerRef()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServerRef',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: ServerRef.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'serverId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerRef clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerRef copyWith(void Function(ServerRef) updates) =>
      super.copyWith((message) => updates(message as ServerRef)) as ServerRef;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ServerRef() / ServerRef.new instead')
  static ServerRef create() => ServerRef._();
  static $pb.GeneratedMessage $_createMessage() => ServerRef._();
  @$core.override
  ServerRef createEmptyInstance() => ServerRef._();
  @$core.pragma('dart2js:noInline')
  static ServerRef getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ServerRef>(ServerRef.$_createMessage);
  static ServerRef? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get serverId => $_getSZ(0);
  @$pb.TagNumber(1)
  set serverId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasServerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearServerId() => $_clearField(1);
}

class Subscription extends $pb.GeneratedMessage {
  factory Subscription({
    $core.Iterable<Topic>? topics,
    LogSource? logSource,
    LogLevel? minLevel,
  }) {
    final result = Subscription._();
    if (topics != null) result.topics.addAll(topics);
    if (logSource != null) result.logSource = logSource;
    if (minLevel != null) result.minLevel = minLevel;
    return result;
  }

  Subscription._();

  factory Subscription.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Subscription()..mergeFromBuffer(data, registry);
  factory Subscription.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Subscription()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Subscription',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: Subscription.$_createMessage)
    ..pc<Topic>(1, _omitFieldNames ? '' : 'topics', $pb.PbFieldType.KE,
        valueOf: Topic.valueOf,
        enumValues: Topic.values,
        defaultEnumValue: Topic.TOPIC_UNSPECIFIED)
    ..aE<LogSource>(2, _omitFieldNames ? '' : 'logSource',
        enumValues: LogSource.values)
    ..aE<LogLevel>(3, _omitFieldNames ? '' : 'minLevel',
        enumValues: LogLevel.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Subscription clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Subscription copyWith(void Function(Subscription) updates) =>
      super.copyWith((message) => updates(message as Subscription))
          as Subscription;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Subscription() / Subscription.new instead')
  static Subscription create() => Subscription._();
  static $pb.GeneratedMessage $_createMessage() => Subscription._();
  @$core.override
  Subscription createEmptyInstance() => Subscription._();
  @$core.pragma('dart2js:noInline')
  static Subscription getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Subscription>(
          Subscription.$_createMessage);
  static Subscription? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Topic> get topics => $_getList(0);

  @$pb.TagNumber(2)
  LogSource get logSource => $_getN(1);
  @$pb.TagNumber(2)
  set logSource(LogSource value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasLogSource() => $_has(1);
  @$pb.TagNumber(2)
  void clearLogSource() => $_clearField(2);

  @$pb.TagNumber(3)
  LogLevel get minLevel => $_getN(2);
  @$pb.TagNumber(3)
  set minLevel(LogLevel value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasMinLevel() => $_has(2);
  @$pb.TagNumber(3)
  void clearMinLevel() => $_clearField(3);
}

class ApplyUpdate extends $pb.GeneratedMessage {
  factory ApplyUpdate({
    UpdateKind? kind,
    ApplyWhen? when,
  }) {
    final result = ApplyUpdate._();
    if (kind != null) result.kind = kind;
    if (when != null) result.when = when;
    return result;
  }

  ApplyUpdate._();

  factory ApplyUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApplyUpdate()..mergeFromBuffer(data, registry);
  factory ApplyUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApplyUpdate()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApplyUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: ApplyUpdate.$_createMessage)
    ..aE<UpdateKind>(1, _omitFieldNames ? '' : 'kind',
        enumValues: UpdateKind.values)
    ..aE<ApplyWhen>(2, _omitFieldNames ? '' : 'when',
        enumValues: ApplyWhen.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyUpdate copyWith(void Function(ApplyUpdate) updates) =>
      super.copyWith((message) => updates(message as ApplyUpdate))
          as ApplyUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ApplyUpdate() / ApplyUpdate.new instead')
  static ApplyUpdate create() => ApplyUpdate._();
  static $pb.GeneratedMessage $_createMessage() => ApplyUpdate._();
  @$core.override
  ApplyUpdate createEmptyInstance() => ApplyUpdate._();
  @$core.pragma('dart2js:noInline')
  static ApplyUpdate getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ApplyUpdate>(
          ApplyUpdate.$_createMessage);
  static ApplyUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  UpdateKind get kind => $_getN(0);
  @$pb.TagNumber(1)
  set kind(UpdateKind value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => $_clearField(1);

  @$pb.TagNumber(2)
  ApplyWhen get when => $_getN(1);
  @$pb.TagNumber(2)
  set when(ApplyWhen value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasWhen() => $_has(1);
  @$pb.TagNumber(2)
  void clearWhen() => $_clearField(2);
}

class ExportDiagnostics extends $pb.GeneratedMessage {
  factory ExportDiagnostics() => ExportDiagnostics._();

  ExportDiagnostics._();

  factory ExportDiagnostics.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportDiagnostics()..mergeFromBuffer(data, registry);
  factory ExportDiagnostics.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportDiagnostics()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportDiagnostics',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: ExportDiagnostics.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportDiagnostics clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportDiagnostics copyWith(void Function(ExportDiagnostics) updates) =>
      super.copyWith((message) => updates(message as ExportDiagnostics))
          as ExportDiagnostics;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ExportDiagnostics() / ExportDiagnostics.new instead')
  static ExportDiagnostics create() => ExportDiagnostics._();
  static $pb.GeneratedMessage $_createMessage() => ExportDiagnostics._();
  @$core.override
  ExportDiagnostics createEmptyInstance() => ExportDiagnostics._();
  @$core.pragma('dart2js:noInline')
  static ExportDiagnostics getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExportDiagnostics>(
          ExportDiagnostics.$_createMessage);
  static ExportDiagnostics? _defaultInstance;
}

class UpdateFileChunk extends $pb.GeneratedMessage {
  factory UpdateFileChunk({
    UpdateKind? kind,
    $fixnum.Int64? offset,
    $core.List<$core.int>? data,
    $core.bool? last,
  }) {
    final result = UpdateFileChunk._();
    if (kind != null) result.kind = kind;
    if (offset != null) result.offset = offset;
    if (data != null) result.data = data;
    if (last != null) result.last = last;
    return result;
  }

  UpdateFileChunk._();

  factory UpdateFileChunk.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateFileChunk()..mergeFromBuffer(data, registry);
  factory UpdateFileChunk.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateFileChunk()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateFileChunk',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: UpdateFileChunk.$_createMessage)
    ..aE<UpdateKind>(1, _omitFieldNames ? '' : 'kind',
        enumValues: UpdateKind.values)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..aOB(4, _omitFieldNames ? '' : 'last')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateFileChunk clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateFileChunk copyWith(void Function(UpdateFileChunk) updates) =>
      super.copyWith((message) => updates(message as UpdateFileChunk))
          as UpdateFileChunk;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpdateFileChunk() / UpdateFileChunk.new instead')
  static UpdateFileChunk create() => UpdateFileChunk._();
  static $pb.GeneratedMessage $_createMessage() => UpdateFileChunk._();
  @$core.override
  UpdateFileChunk createEmptyInstance() => UpdateFileChunk._();
  @$core.pragma('dart2js:noInline')
  static UpdateFileChunk getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateFileChunk>(
          UpdateFileChunk.$_createMessage);
  static UpdateFileChunk? _defaultInstance;

  @$pb.TagNumber(1)
  UpdateKind get kind => $_getN(0);
  @$pb.TagNumber(1)
  set kind(UpdateKind value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get offset => $_getI64(1);
  @$pb.TagNumber(2)
  set offset($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOffset() => $_has(1);
  @$pb.TagNumber(2)
  void clearOffset() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get data => $_getN(2);
  @$pb.TagNumber(3)
  set data($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get last => $_getBF(3);
  @$pb.TagNumber(4)
  set last($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLast() => $_has(3);
  @$pb.TagNumber(4)
  void clearLast() => $_clearField(4);
}

enum Response_Kind { ack, error, config, updateState, diagnostics, notSet }

class Response extends $pb.GeneratedMessage {
  factory Response({
    Empty? ack,
    Error? error,
    Config? config,
    UpdateState? updateState,
    $core.List<$core.int>? diagnostics,
  }) {
    final result = Response._();
    if (ack != null) result.ack = ack;
    if (error != null) result.error = error;
    if (config != null) result.config = config;
    if (updateState != null) result.updateState = updateState;
    if (diagnostics != null) result.diagnostics = diagnostics;
    return result;
  }

  Response._();

  factory Response.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Response()..mergeFromBuffer(data, registry);
  factory Response.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Response()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Response_Kind> _Response_KindByTag = {
    1: Response_Kind.ack,
    2: Response_Kind.error,
    3: Response_Kind.config,
    4: Response_Kind.updateState,
    5: Response_Kind.diagnostics,
    0: Response_Kind.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Response',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: Response.$_createMessage)
    ..oo(0, [1, 2, 3, 4, 5])
    ..aOM<Empty>(1, _omitFieldNames ? '' : 'ack',
        subBuilder: Empty.$_createMessage)
    ..aOM<Error>(2, _omitFieldNames ? '' : 'error',
        subBuilder: Error.$_createMessage)
    ..aOM<Config>(3, _omitFieldNames ? '' : 'config',
        subBuilder: Config.$_createMessage)
    ..aOM<UpdateState>(4, _omitFieldNames ? '' : 'updateState',
        subBuilder: UpdateState.$_createMessage)
    ..a<$core.List<$core.int>>(
        5, _omitFieldNames ? '' : 'diagnostics', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Response clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Response copyWith(void Function(Response) updates) =>
      super.copyWith((message) => updates(message as Response)) as Response;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Response() / Response.new instead')
  static Response create() => Response._();
  static $pb.GeneratedMessage $_createMessage() => Response._();
  @$core.override
  Response createEmptyInstance() => Response._();
  @$core.pragma('dart2js:noInline')
  static Response getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Response>(Response.$_createMessage);
  static Response? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  Response_Kind whichKind() => _Response_KindByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  void clearKind() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  Empty get ack => $_getN(0);
  @$pb.TagNumber(1)
  set ack(Empty value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAck() => $_has(0);
  @$pb.TagNumber(1)
  void clearAck() => $_clearField(1);
  @$pb.TagNumber(1)
  Empty ensureAck() => $_ensure(0);

  @$pb.TagNumber(2)
  Error get error => $_getN(1);
  @$pb.TagNumber(2)
  set error(Error value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  Error ensureError() => $_ensure(1);

  @$pb.TagNumber(3)
  Config get config => $_getN(2);
  @$pb.TagNumber(3)
  set config(Config value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasConfig() => $_has(2);
  @$pb.TagNumber(3)
  void clearConfig() => $_clearField(3);
  @$pb.TagNumber(3)
  Config ensureConfig() => $_ensure(2);

  @$pb.TagNumber(4)
  UpdateState get updateState => $_getN(3);
  @$pb.TagNumber(4)
  set updateState(UpdateState value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasUpdateState() => $_has(3);
  @$pb.TagNumber(4)
  void clearUpdateState() => $_clearField(4);
  @$pb.TagNumber(4)
  UpdateState ensureUpdateState() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.List<$core.int> get diagnostics => $_getN(4);
  @$pb.TagNumber(5)
  set diagnostics($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDiagnostics() => $_has(4);
  @$pb.TagNumber(5)
  void clearDiagnostics() => $_clearField(5);
}

class Error extends $pb.GeneratedMessage {
  factory Error({
    ErrorCode? code,
    $core.String? messageKey,
    $core.String? detail,
    $core.Iterable<FieldError>? fields,
  }) {
    final result = Error._();
    if (code != null) result.code = code;
    if (messageKey != null) result.messageKey = messageKey;
    if (detail != null) result.detail = detail;
    if (fields != null) result.fields.addAll(fields);
    return result;
  }

  Error._();

  factory Error.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Error()..mergeFromBuffer(data, registry);
  factory Error.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Error()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Error',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: Error.$_createMessage)
    ..aE<ErrorCode>(1, _omitFieldNames ? '' : 'code',
        enumValues: ErrorCode.values)
    ..aOS(2, _omitFieldNames ? '' : 'messageKey')
    ..aOS(3, _omitFieldNames ? '' : 'detail')
    ..pPM<FieldError>(4, _omitFieldNames ? '' : 'fields',
        subBuilder: FieldError.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Error clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Error copyWith(void Function(Error) updates) =>
      super.copyWith((message) => updates(message as Error)) as Error;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Error() / Error.new instead')
  static Error create() => Error._();
  static $pb.GeneratedMessage $_createMessage() => Error._();
  @$core.override
  Error createEmptyInstance() => Error._();
  @$core.pragma('dart2js:noInline')
  static Error getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Error>(Error.$_createMessage);
  static Error? _defaultInstance;

  @$pb.TagNumber(1)
  ErrorCode get code => $_getN(0);
  @$pb.TagNumber(1)
  set code(ErrorCode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get messageKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set messageKey($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessageKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessageKey() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get detail => $_getSZ(2);
  @$pb.TagNumber(3)
  set detail($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDetail() => $_has(2);
  @$pb.TagNumber(3)
  void clearDetail() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<FieldError> get fields => $_getList(3);
}

class FieldError extends $pb.GeneratedMessage {
  factory FieldError({
    $core.String? path,
    $core.String? messageKey,
  }) {
    final result = FieldError._();
    if (path != null) result.path = path;
    if (messageKey != null) result.messageKey = messageKey;
    return result;
  }

  FieldError._();

  factory FieldError.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FieldError()..mergeFromBuffer(data, registry);
  factory FieldError.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FieldError()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldError',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: FieldError.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'path')
    ..aOS(2, _omitFieldNames ? '' : 'messageKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldError clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldError copyWith(void Function(FieldError) updates) =>
      super.copyWith((message) => updates(message as FieldError)) as FieldError;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FieldError() / FieldError.new instead')
  static FieldError create() => FieldError._();
  static $pb.GeneratedMessage $_createMessage() => FieldError._();
  @$core.override
  FieldError createEmptyInstance() => FieldError._();
  @$core.pragma('dart2js:noInline')
  static FieldError getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldError>(FieldError.$_createMessage);
  static FieldError? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get messageKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set messageKey($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessageKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessageKey() => $_clearField(2);
}

enum Event_Kind {
  statusChanged,
  quotaChanged,
  notice,
  logs,
  throughput,
  updateState,
  configResult,
  ping,
  notSet
}

class Event extends $pb.GeneratedMessage {
  factory Event({
    Status? statusChanged,
    Quota? quotaChanged,
    Notice? notice,
    LogBatch? logs,
    Throughput? throughput,
    UpdateState? updateState,
    ConfigResult? configResult,
    Empty? ping,
  }) {
    final result = Event._();
    if (statusChanged != null) result.statusChanged = statusChanged;
    if (quotaChanged != null) result.quotaChanged = quotaChanged;
    if (notice != null) result.notice = notice;
    if (logs != null) result.logs = logs;
    if (throughput != null) result.throughput = throughput;
    if (updateState != null) result.updateState = updateState;
    if (configResult != null) result.configResult = configResult;
    if (ping != null) result.ping = ping;
    return result;
  }

  Event._();

  factory Event.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Event()..mergeFromBuffer(data, registry);
  factory Event.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Event()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Event_Kind> _Event_KindByTag = {
    1: Event_Kind.statusChanged,
    2: Event_Kind.quotaChanged,
    3: Event_Kind.notice,
    4: Event_Kind.logs,
    5: Event_Kind.throughput,
    6: Event_Kind.updateState,
    7: Event_Kind.configResult,
    8: Event_Kind.ping,
    0: Event_Kind.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: Event.$_createMessage)
    ..oo(0, [1, 2, 3, 4, 5, 6, 7, 8])
    ..aOM<Status>(1, _omitFieldNames ? '' : 'statusChanged',
        subBuilder: Status.$_createMessage)
    ..aOM<Quota>(2, _omitFieldNames ? '' : 'quotaChanged',
        subBuilder: Quota.$_createMessage)
    ..aOM<Notice>(3, _omitFieldNames ? '' : 'notice',
        subBuilder: Notice.$_createMessage)
    ..aOM<LogBatch>(4, _omitFieldNames ? '' : 'logs',
        subBuilder: LogBatch.$_createMessage)
    ..aOM<Throughput>(5, _omitFieldNames ? '' : 'throughput',
        subBuilder: Throughput.$_createMessage)
    ..aOM<UpdateState>(6, _omitFieldNames ? '' : 'updateState',
        subBuilder: UpdateState.$_createMessage)
    ..aOM<ConfigResult>(7, _omitFieldNames ? '' : 'configResult',
        subBuilder: ConfigResult.$_createMessage)
    ..aOM<Empty>(8, _omitFieldNames ? '' : 'ping',
        subBuilder: Empty.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event copyWith(void Function(Event) updates) =>
      super.copyWith((message) => updates(message as Event)) as Event;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Event() / Event.new instead')
  static Event create() => Event._();
  static $pb.GeneratedMessage $_createMessage() => Event._();
  @$core.override
  Event createEmptyInstance() => Event._();
  @$core.pragma('dart2js:noInline')
  static Event getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event>(Event.$_createMessage);
  static Event? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  Event_Kind whichKind() => _Event_KindByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  void clearKind() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  Status get statusChanged => $_getN(0);
  @$pb.TagNumber(1)
  set statusChanged(Status value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatusChanged() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatusChanged() => $_clearField(1);
  @$pb.TagNumber(1)
  Status ensureStatusChanged() => $_ensure(0);

  @$pb.TagNumber(2)
  Quota get quotaChanged => $_getN(1);
  @$pb.TagNumber(2)
  set quotaChanged(Quota value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasQuotaChanged() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuotaChanged() => $_clearField(2);
  @$pb.TagNumber(2)
  Quota ensureQuotaChanged() => $_ensure(1);

  @$pb.TagNumber(3)
  Notice get notice => $_getN(2);
  @$pb.TagNumber(3)
  set notice(Notice value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasNotice() => $_has(2);
  @$pb.TagNumber(3)
  void clearNotice() => $_clearField(3);
  @$pb.TagNumber(3)
  Notice ensureNotice() => $_ensure(2);

  @$pb.TagNumber(4)
  LogBatch get logs => $_getN(3);
  @$pb.TagNumber(4)
  set logs(LogBatch value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasLogs() => $_has(3);
  @$pb.TagNumber(4)
  void clearLogs() => $_clearField(4);
  @$pb.TagNumber(4)
  LogBatch ensureLogs() => $_ensure(3);

  @$pb.TagNumber(5)
  Throughput get throughput => $_getN(4);
  @$pb.TagNumber(5)
  set throughput(Throughput value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasThroughput() => $_has(4);
  @$pb.TagNumber(5)
  void clearThroughput() => $_clearField(5);
  @$pb.TagNumber(5)
  Throughput ensureThroughput() => $_ensure(4);

  @$pb.TagNumber(6)
  UpdateState get updateState => $_getN(5);
  @$pb.TagNumber(6)
  set updateState(UpdateState value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasUpdateState() => $_has(5);
  @$pb.TagNumber(6)
  void clearUpdateState() => $_clearField(6);
  @$pb.TagNumber(6)
  UpdateState ensureUpdateState() => $_ensure(5);

  @$pb.TagNumber(7)
  ConfigResult get configResult => $_getN(6);
  @$pb.TagNumber(7)
  set configResult(ConfigResult value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasConfigResult() => $_has(6);
  @$pb.TagNumber(7)
  void clearConfigResult() => $_clearField(7);
  @$pb.TagNumber(7)
  ConfigResult ensureConfigResult() => $_ensure(6);

  @$pb.TagNumber(8)
  Empty get ping => $_getN(7);
  @$pb.TagNumber(8)
  set ping(Empty value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasPing() => $_has(7);
  @$pb.TagNumber(8)
  void clearPing() => $_clearField(8);
  @$pb.TagNumber(8)
  Empty ensurePing() => $_ensure(7);
}

class Status extends $pb.GeneratedMessage {
  factory Status({
    Phase? phase,
    Gate? gate,
    $core.String? activeServerId,
    $core.String? chosenServerId,
    $core.bool? onBackup,
    $core.int? attempt,
    $core.int? maxAttempts,
    $fixnum.Int64? nextTryAtMs,
    $fixnum.Int64? serviceNowMs,
    QuotaLevel? quotaLevel,
    FailureReason? lastFailure,
    $fixnum.Int64? phaseSinceMs,
    $core.bool? killSwitchOn,
    $core.String? egressAddress,
    $core.int? latencyMs,
    $fixnum.Int64? configVersion,
    Probe? probe,
    SessionEnd? lastEnd,
  }) {
    final result = Status._();
    if (phase != null) result.phase = phase;
    if (gate != null) result.gate = gate;
    if (activeServerId != null) result.activeServerId = activeServerId;
    if (chosenServerId != null) result.chosenServerId = chosenServerId;
    if (onBackup != null) result.onBackup = onBackup;
    if (attempt != null) result.attempt = attempt;
    if (maxAttempts != null) result.maxAttempts = maxAttempts;
    if (nextTryAtMs != null) result.nextTryAtMs = nextTryAtMs;
    if (serviceNowMs != null) result.serviceNowMs = serviceNowMs;
    if (quotaLevel != null) result.quotaLevel = quotaLevel;
    if (lastFailure != null) result.lastFailure = lastFailure;
    if (phaseSinceMs != null) result.phaseSinceMs = phaseSinceMs;
    if (killSwitchOn != null) result.killSwitchOn = killSwitchOn;
    if (egressAddress != null) result.egressAddress = egressAddress;
    if (latencyMs != null) result.latencyMs = latencyMs;
    if (configVersion != null) result.configVersion = configVersion;
    if (probe != null) result.probe = probe;
    if (lastEnd != null) result.lastEnd = lastEnd;
    return result;
  }

  Status._();

  factory Status.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Status()..mergeFromBuffer(data, registry);
  factory Status.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Status()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Status',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: Status.$_createMessage)
    ..aE<Phase>(1, _omitFieldNames ? '' : 'phase', enumValues: Phase.values)
    ..aE<Gate>(2, _omitFieldNames ? '' : 'gate', enumValues: Gate.values)
    ..aOS(3, _omitFieldNames ? '' : 'activeServerId')
    ..aOS(4, _omitFieldNames ? '' : 'chosenServerId')
    ..aOB(5, _omitFieldNames ? '' : 'onBackup')
    ..aI(6, _omitFieldNames ? '' : 'attempt', fieldType: $pb.PbFieldType.OU3)
    ..aI(7, _omitFieldNames ? '' : 'maxAttempts',
        fieldType: $pb.PbFieldType.OU3)
    ..aInt64(8, _omitFieldNames ? '' : 'nextTryAtMs')
    ..aInt64(9, _omitFieldNames ? '' : 'serviceNowMs')
    ..aE<QuotaLevel>(10, _omitFieldNames ? '' : 'quotaLevel',
        enumValues: QuotaLevel.values)
    ..aE<FailureReason>(11, _omitFieldNames ? '' : 'lastFailure',
        enumValues: FailureReason.values)
    ..aInt64(12, _omitFieldNames ? '' : 'phaseSinceMs')
    ..aOB(13, _omitFieldNames ? '' : 'killSwitchOn')
    ..aOS(14, _omitFieldNames ? '' : 'egressAddress')
    ..aI(15, _omitFieldNames ? '' : 'latencyMs', fieldType: $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(
        16, _omitFieldNames ? '' : 'configVersion', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aE<Probe>(17, _omitFieldNames ? '' : 'probe', enumValues: Probe.values)
    ..aE<SessionEnd>(18, _omitFieldNames ? '' : 'lastEnd',
        enumValues: SessionEnd.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Status clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Status copyWith(void Function(Status) updates) =>
      super.copyWith((message) => updates(message as Status)) as Status;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Status() / Status.new instead')
  static Status create() => Status._();
  static $pb.GeneratedMessage $_createMessage() => Status._();
  @$core.override
  Status createEmptyInstance() => Status._();
  @$core.pragma('dart2js:noInline')
  static Status getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Status>(Status.$_createMessage);
  static Status? _defaultInstance;

  @$pb.TagNumber(1)
  Phase get phase => $_getN(0);
  @$pb.TagNumber(1)
  set phase(Phase value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPhase() => $_has(0);
  @$pb.TagNumber(1)
  void clearPhase() => $_clearField(1);

  @$pb.TagNumber(2)
  Gate get gate => $_getN(1);
  @$pb.TagNumber(2)
  set gate(Gate value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasGate() => $_has(1);
  @$pb.TagNumber(2)
  void clearGate() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get activeServerId => $_getSZ(2);
  @$pb.TagNumber(3)
  set activeServerId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasActiveServerId() => $_has(2);
  @$pb.TagNumber(3)
  void clearActiveServerId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get chosenServerId => $_getSZ(3);
  @$pb.TagNumber(4)
  set chosenServerId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasChosenServerId() => $_has(3);
  @$pb.TagNumber(4)
  void clearChosenServerId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get onBackup => $_getBF(4);
  @$pb.TagNumber(5)
  set onBackup($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOnBackup() => $_has(4);
  @$pb.TagNumber(5)
  void clearOnBackup() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get attempt => $_getIZ(5);
  @$pb.TagNumber(6)
  set attempt($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAttempt() => $_has(5);
  @$pb.TagNumber(6)
  void clearAttempt() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get maxAttempts => $_getIZ(6);
  @$pb.TagNumber(7)
  set maxAttempts($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMaxAttempts() => $_has(6);
  @$pb.TagNumber(7)
  void clearMaxAttempts() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get nextTryAtMs => $_getI64(7);
  @$pb.TagNumber(8)
  set nextTryAtMs($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasNextTryAtMs() => $_has(7);
  @$pb.TagNumber(8)
  void clearNextTryAtMs() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get serviceNowMs => $_getI64(8);
  @$pb.TagNumber(9)
  set serviceNowMs($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasServiceNowMs() => $_has(8);
  @$pb.TagNumber(9)
  void clearServiceNowMs() => $_clearField(9);

  @$pb.TagNumber(10)
  QuotaLevel get quotaLevel => $_getN(9);
  @$pb.TagNumber(10)
  set quotaLevel(QuotaLevel value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasQuotaLevel() => $_has(9);
  @$pb.TagNumber(10)
  void clearQuotaLevel() => $_clearField(10);

  @$pb.TagNumber(11)
  FailureReason get lastFailure => $_getN(10);
  @$pb.TagNumber(11)
  set lastFailure(FailureReason value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasLastFailure() => $_has(10);
  @$pb.TagNumber(11)
  void clearLastFailure() => $_clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get phaseSinceMs => $_getI64(11);
  @$pb.TagNumber(12)
  set phaseSinceMs($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasPhaseSinceMs() => $_has(11);
  @$pb.TagNumber(12)
  void clearPhaseSinceMs() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get killSwitchOn => $_getBF(12);
  @$pb.TagNumber(13)
  set killSwitchOn($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasKillSwitchOn() => $_has(12);
  @$pb.TagNumber(13)
  void clearKillSwitchOn() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get egressAddress => $_getSZ(13);
  @$pb.TagNumber(14)
  set egressAddress($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasEgressAddress() => $_has(13);
  @$pb.TagNumber(14)
  void clearEgressAddress() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.int get latencyMs => $_getIZ(14);
  @$pb.TagNumber(15)
  set latencyMs($core.int value) => $_setUnsignedInt32(14, value);
  @$pb.TagNumber(15)
  $core.bool hasLatencyMs() => $_has(14);
  @$pb.TagNumber(15)
  void clearLatencyMs() => $_clearField(15);

  @$pb.TagNumber(16)
  $fixnum.Int64 get configVersion => $_getI64(15);
  @$pb.TagNumber(16)
  set configVersion($fixnum.Int64 value) => $_setInt64(15, value);
  @$pb.TagNumber(16)
  $core.bool hasConfigVersion() => $_has(15);
  @$pb.TagNumber(16)
  void clearConfigVersion() => $_clearField(16);

  /// Added after the Design artifact showed Home states that phase and gate alone
  /// cannot tell apart (additive, field numbers are not frozen yet).
  /// probe: why a session that was Up is being verified again. Set only while
  /// the phase is Verifying after Up, PROBE_UNSPECIFIED otherwise. It tells
  /// "waking up" and "checking network" from a first connect.
  @$pb.TagNumber(17)
  Probe get probe => $_getN(16);
  @$pb.TagNumber(17)
  set probe(Probe value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasProbe() => $_has(16);
  @$pb.TagNumber(17)
  void clearProbe() => $_clearField(17);

  /// last_end: how the most recent session ended. Set when the phase becomes
  /// Idle, cleared by the next Connect. It tells "could not reach" and "tunnel
  /// lost" from a plain disconnect.
  @$pb.TagNumber(18)
  SessionEnd get lastEnd => $_getN(17);
  @$pb.TagNumber(18)
  set lastEnd(SessionEnd value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasLastEnd() => $_has(17);
  @$pb.TagNumber(18)
  void clearLastEnd() => $_clearField(18);
}

class Quota extends $pb.GeneratedMessage {
  factory Quota({
    $core.String? serverId,
    $fixnum.Int64? bytesOut,
    $fixnum.Int64? bytesIn,
    $fixnum.Int64? countedBytes,
    QuotaLevel? level,
    $fixnum.Int64? periodStartMs,
    $fixnum.Int64? resetsAtMs,
  }) {
    final result = Quota._();
    if (serverId != null) result.serverId = serverId;
    if (bytesOut != null) result.bytesOut = bytesOut;
    if (bytesIn != null) result.bytesIn = bytesIn;
    if (countedBytes != null) result.countedBytes = countedBytes;
    if (level != null) result.level = level;
    if (periodStartMs != null) result.periodStartMs = periodStartMs;
    if (resetsAtMs != null) result.resetsAtMs = resetsAtMs;
    return result;
  }

  Quota._();

  factory Quota.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Quota()..mergeFromBuffer(data, registry);
  factory Quota.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Quota()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Quota',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: Quota.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'serverId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'bytesOut', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'bytesIn', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'countedBytes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aE<QuotaLevel>(5, _omitFieldNames ? '' : 'level',
        enumValues: QuotaLevel.values)
    ..aInt64(6, _omitFieldNames ? '' : 'periodStartMs')
    ..aInt64(7, _omitFieldNames ? '' : 'resetsAtMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Quota clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Quota copyWith(void Function(Quota) updates) =>
      super.copyWith((message) => updates(message as Quota)) as Quota;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Quota() / Quota.new instead')
  static Quota create() => Quota._();
  static $pb.GeneratedMessage $_createMessage() => Quota._();
  @$core.override
  Quota createEmptyInstance() => Quota._();
  @$core.pragma('dart2js:noInline')
  static Quota getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Quota>(Quota.$_createMessage);
  static Quota? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get serverId => $_getSZ(0);
  @$pb.TagNumber(1)
  set serverId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasServerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearServerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get bytesOut => $_getI64(1);
  @$pb.TagNumber(2)
  set bytesOut($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBytesOut() => $_has(1);
  @$pb.TagNumber(2)
  void clearBytesOut() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get bytesIn => $_getI64(2);
  @$pb.TagNumber(3)
  set bytesIn($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBytesIn() => $_has(2);
  @$pb.TagNumber(3)
  void clearBytesIn() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get countedBytes => $_getI64(3);
  @$pb.TagNumber(4)
  set countedBytes($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCountedBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearCountedBytes() => $_clearField(4);

  @$pb.TagNumber(5)
  QuotaLevel get level => $_getN(4);
  @$pb.TagNumber(5)
  set level(QuotaLevel value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasLevel() => $_has(4);
  @$pb.TagNumber(5)
  void clearLevel() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get periodStartMs => $_getI64(5);
  @$pb.TagNumber(6)
  set periodStartMs($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPeriodStartMs() => $_has(5);
  @$pb.TagNumber(6)
  void clearPeriodStartMs() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get resetsAtMs => $_getI64(6);
  @$pb.TagNumber(7)
  set resetsAtMs($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasResetsAtMs() => $_has(6);
  @$pb.TagNumber(7)
  void clearResetsAtMs() => $_clearField(7);
}

class Notice extends $pb.GeneratedMessage {
  factory Notice({
    NoticeKind? kind,
    $core.String? serverId,
    $fixnum.Int64? atMs,
  }) {
    final result = Notice._();
    if (kind != null) result.kind = kind;
    if (serverId != null) result.serverId = serverId;
    if (atMs != null) result.atMs = atMs;
    return result;
  }

  Notice._();

  factory Notice.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Notice()..mergeFromBuffer(data, registry);
  factory Notice.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Notice()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Notice',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: Notice.$_createMessage)
    ..aE<NoticeKind>(1, _omitFieldNames ? '' : 'kind',
        enumValues: NoticeKind.values)
    ..aOS(2, _omitFieldNames ? '' : 'serverId')
    ..aInt64(3, _omitFieldNames ? '' : 'atMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notice clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notice copyWith(void Function(Notice) updates) =>
      super.copyWith((message) => updates(message as Notice)) as Notice;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Notice() / Notice.new instead')
  static Notice create() => Notice._();
  static $pb.GeneratedMessage $_createMessage() => Notice._();
  @$core.override
  Notice createEmptyInstance() => Notice._();
  @$core.pragma('dart2js:noInline')
  static Notice getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Notice>(Notice.$_createMessage);
  static Notice? _defaultInstance;

  @$pb.TagNumber(1)
  NoticeKind get kind => $_getN(0);
  @$pb.TagNumber(1)
  set kind(NoticeKind value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get serverId => $_getSZ(1);
  @$pb.TagNumber(2)
  set serverId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasServerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearServerId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get atMs => $_getI64(2);
  @$pb.TagNumber(3)
  set atMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAtMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearAtMs() => $_clearField(3);
}

class Throughput extends $pb.GeneratedMessage {
  factory Throughput({
    $fixnum.Int64? downBps,
    $fixnum.Int64? upBps,
    $fixnum.Int64? atMs,
  }) {
    final result = Throughput._();
    if (downBps != null) result.downBps = downBps;
    if (upBps != null) result.upBps = upBps;
    if (atMs != null) result.atMs = atMs;
    return result;
  }

  Throughput._();

  factory Throughput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Throughput()..mergeFromBuffer(data, registry);
  factory Throughput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Throughput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Throughput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: Throughput.$_createMessage)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'downBps', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'upBps', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(3, _omitFieldNames ? '' : 'atMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Throughput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Throughput copyWith(void Function(Throughput) updates) =>
      super.copyWith((message) => updates(message as Throughput)) as Throughput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Throughput() / Throughput.new instead')
  static Throughput create() => Throughput._();
  static $pb.GeneratedMessage $_createMessage() => Throughput._();
  @$core.override
  Throughput createEmptyInstance() => Throughput._();
  @$core.pragma('dart2js:noInline')
  static Throughput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Throughput>(Throughput.$_createMessage);
  static Throughput? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get downBps => $_getI64(0);
  @$pb.TagNumber(1)
  set downBps($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDownBps() => $_has(0);
  @$pb.TagNumber(1)
  void clearDownBps() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get upBps => $_getI64(1);
  @$pb.TagNumber(2)
  set upBps($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUpBps() => $_has(1);
  @$pb.TagNumber(2)
  void clearUpBps() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get atMs => $_getI64(2);
  @$pb.TagNumber(3)
  set atMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAtMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearAtMs() => $_clearField(3);
}

class LogLine extends $pb.GeneratedMessage {
  factory LogLine({
    $fixnum.Int64? seq,
    $fixnum.Int64? atMs,
    LogLevel? level,
    $core.String? text,
  }) {
    final result = LogLine._();
    if (seq != null) result.seq = seq;
    if (atMs != null) result.atMs = atMs;
    if (level != null) result.level = level;
    if (text != null) result.text = text;
    return result;
  }

  LogLine._();

  factory LogLine.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LogLine()..mergeFromBuffer(data, registry);
  factory LogLine.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LogLine()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogLine',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: LogLine.$_createMessage)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'seq', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(2, _omitFieldNames ? '' : 'atMs')
    ..aE<LogLevel>(3, _omitFieldNames ? '' : 'level',
        enumValues: LogLevel.values)
    ..aOS(4, _omitFieldNames ? '' : 'text')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogLine clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogLine copyWith(void Function(LogLine) updates) =>
      super.copyWith((message) => updates(message as LogLine)) as LogLine;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LogLine() / LogLine.new instead')
  static LogLine create() => LogLine._();
  static $pb.GeneratedMessage $_createMessage() => LogLine._();
  @$core.override
  LogLine createEmptyInstance() => LogLine._();
  @$core.pragma('dart2js:noInline')
  static LogLine getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogLine>(LogLine.$_createMessage);
  static LogLine? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get seq => $_getI64(0);
  @$pb.TagNumber(1)
  set seq($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSeq() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeq() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get atMs => $_getI64(1);
  @$pb.TagNumber(2)
  set atMs($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAtMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearAtMs() => $_clearField(2);

  @$pb.TagNumber(3)
  LogLevel get level => $_getN(2);
  @$pb.TagNumber(3)
  set level(LogLevel value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasLevel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLevel() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get text => $_getSZ(3);
  @$pb.TagNumber(4)
  set text($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasText() => $_has(3);
  @$pb.TagNumber(4)
  void clearText() => $_clearField(4);
}

class LogBatch extends $pb.GeneratedMessage {
  factory LogBatch({
    LogSource? source,
    $core.Iterable<LogLine>? lines,
    $core.int? dropped,
  }) {
    final result = LogBatch._();
    if (source != null) result.source = source;
    if (lines != null) result.lines.addAll(lines);
    if (dropped != null) result.dropped = dropped;
    return result;
  }

  LogBatch._();

  factory LogBatch.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LogBatch()..mergeFromBuffer(data, registry);
  factory LogBatch.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LogBatch()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogBatch',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: LogBatch.$_createMessage)
    ..aE<LogSource>(1, _omitFieldNames ? '' : 'source',
        enumValues: LogSource.values)
    ..pPM<LogLine>(2, _omitFieldNames ? '' : 'lines',
        subBuilder: LogLine.$_createMessage)
    ..aI(3, _omitFieldNames ? '' : 'dropped', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogBatch clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogBatch copyWith(void Function(LogBatch) updates) =>
      super.copyWith((message) => updates(message as LogBatch)) as LogBatch;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LogBatch() / LogBatch.new instead')
  static LogBatch create() => LogBatch._();
  static $pb.GeneratedMessage $_createMessage() => LogBatch._();
  @$core.override
  LogBatch createEmptyInstance() => LogBatch._();
  @$core.pragma('dart2js:noInline')
  static LogBatch getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogBatch>(LogBatch.$_createMessage);
  static LogBatch? _defaultInstance;

  @$pb.TagNumber(1)
  LogSource get source => $_getN(0);
  @$pb.TagNumber(1)
  set source(LogSource value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSource() => $_has(0);
  @$pb.TagNumber(1)
  void clearSource() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<LogLine> get lines => $_getList(1);

  @$pb.TagNumber(3)
  $core.int get dropped => $_getIZ(2);
  @$pb.TagNumber(3)
  set dropped($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDropped() => $_has(2);
  @$pb.TagNumber(3)
  void clearDropped() => $_clearField(3);
}

class ConfigResult extends $pb.GeneratedMessage {
  factory ConfigResult({
    $fixnum.Int64? version,
    $core.bool? accepted,
    $core.Iterable<$core.String>? appliesNow,
    $core.Iterable<$core.String>? appliesNextConnect,
    Error? error,
  }) {
    final result = ConfigResult._();
    if (version != null) result.version = version;
    if (accepted != null) result.accepted = accepted;
    if (appliesNow != null) result.appliesNow.addAll(appliesNow);
    if (appliesNextConnect != null)
      result.appliesNextConnect.addAll(appliesNextConnect);
    if (error != null) result.error = error;
    return result;
  }

  ConfigResult._();

  factory ConfigResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConfigResult()..mergeFromBuffer(data, registry);
  factory ConfigResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConfigResult()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConfigResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: ConfigResult.$_createMessage)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'version', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(2, _omitFieldNames ? '' : 'accepted')
    ..pPS(3, _omitFieldNames ? '' : 'appliesNow')
    ..pPS(4, _omitFieldNames ? '' : 'appliesNextConnect')
    ..aOM<Error>(5, _omitFieldNames ? '' : 'error',
        subBuilder: Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfigResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfigResult copyWith(void Function(ConfigResult) updates) =>
      super.copyWith((message) => updates(message as ConfigResult))
          as ConfigResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConfigResult() / ConfigResult.new instead')
  static ConfigResult create() => ConfigResult._();
  static $pb.GeneratedMessage $_createMessage() => ConfigResult._();
  @$core.override
  ConfigResult createEmptyInstance() => ConfigResult._();
  @$core.pragma('dart2js:noInline')
  static ConfigResult getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConfigResult>(
          ConfigResult.$_createMessage);
  static ConfigResult? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get version => $_getI64(0);
  @$pb.TagNumber(1)
  set version($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get accepted => $_getBF(1);
  @$pb.TagNumber(2)
  set accepted($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAccepted() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccepted() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get appliesNow => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get appliesNextConnect => $_getList(3);

  @$pb.TagNumber(5)
  Error get error => $_getN(4);
  @$pb.TagNumber(5)
  set error(Error value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasError() => $_has(4);
  @$pb.TagNumber(5)
  void clearError() => $_clearField(5);
  @$pb.TagNumber(5)
  Error ensureError() => $_ensure(4);
}

class UpdateState extends $pb.GeneratedMessage {
  factory UpdateState({
    UpdateKind? kind,
    UpdateStage? stage,
    $core.String? currentVersion,
    $core.String? newVersion,
    $fixnum.Int64? sizeBytes,
    $core.int? progressPercent,
    $core.String? stagedInstaller,
    $core.String? failureKey,
  }) {
    final result = UpdateState._();
    if (kind != null) result.kind = kind;
    if (stage != null) result.stage = stage;
    if (currentVersion != null) result.currentVersion = currentVersion;
    if (newVersion != null) result.newVersion = newVersion;
    if (sizeBytes != null) result.sizeBytes = sizeBytes;
    if (progressPercent != null) result.progressPercent = progressPercent;
    if (stagedInstaller != null) result.stagedInstaller = stagedInstaller;
    if (failureKey != null) result.failureKey = failureKey;
    return result;
  }

  UpdateState._();

  factory UpdateState.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateState()..mergeFromBuffer(data, registry);
  factory UpdateState.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateState()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateState',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: UpdateState.$_createMessage)
    ..aE<UpdateKind>(1, _omitFieldNames ? '' : 'kind',
        enumValues: UpdateKind.values)
    ..aE<UpdateStage>(2, _omitFieldNames ? '' : 'stage',
        enumValues: UpdateStage.values)
    ..aOS(3, _omitFieldNames ? '' : 'currentVersion')
    ..aOS(4, _omitFieldNames ? '' : 'newVersion')
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'sizeBytes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(6, _omitFieldNames ? '' : 'progressPercent',
        fieldType: $pb.PbFieldType.OU3)
    ..aOS(7, _omitFieldNames ? '' : 'stagedInstaller')
    ..aOS(8, _omitFieldNames ? '' : 'failureKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateState clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateState copyWith(void Function(UpdateState) updates) =>
      super.copyWith((message) => updates(message as UpdateState))
          as UpdateState;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpdateState() / UpdateState.new instead')
  static UpdateState create() => UpdateState._();
  static $pb.GeneratedMessage $_createMessage() => UpdateState._();
  @$core.override
  UpdateState createEmptyInstance() => UpdateState._();
  @$core.pragma('dart2js:noInline')
  static UpdateState getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateState>(
          UpdateState.$_createMessage);
  static UpdateState? _defaultInstance;

  @$pb.TagNumber(1)
  UpdateKind get kind => $_getN(0);
  @$pb.TagNumber(1)
  set kind(UpdateKind value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => $_clearField(1);

  @$pb.TagNumber(2)
  UpdateStage get stage => $_getN(1);
  @$pb.TagNumber(2)
  set stage(UpdateStage value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStage() => $_has(1);
  @$pb.TagNumber(2)
  void clearStage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get currentVersion => $_getSZ(2);
  @$pb.TagNumber(3)
  set currentVersion($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCurrentVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrentVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get newVersion => $_getSZ(3);
  @$pb.TagNumber(4)
  set newVersion($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNewVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearNewVersion() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get sizeBytes => $_getI64(4);
  @$pb.TagNumber(5)
  set sizeBytes($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSizeBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearSizeBytes() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get progressPercent => $_getIZ(5);
  @$pb.TagNumber(6)
  set progressPercent($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProgressPercent() => $_has(5);
  @$pb.TagNumber(6)
  void clearProgressPercent() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get stagedInstaller => $_getSZ(6);
  @$pb.TagNumber(7)
  set stagedInstaller($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStagedInstaller() => $_has(6);
  @$pb.TagNumber(7)
  void clearStagedInstaller() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get failureKey => $_getSZ(7);
  @$pb.TagNumber(8)
  set failureKey($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFailureKey() => $_has(7);
  @$pb.TagNumber(8)
  void clearFailureKey() => $_clearField(8);
}

class Config extends $pb.GeneratedMessage {
  factory Config({
    $fixnum.Int64? version,
    $core.Iterable<Server>? servers,
    $core.String? chosenServerId,
    Settings? settings,
    SplitTunnel? split,
  }) {
    final result = Config._();
    if (version != null) result.version = version;
    if (servers != null) result.servers.addAll(servers);
    if (chosenServerId != null) result.chosenServerId = chosenServerId;
    if (settings != null) result.settings = settings;
    if (split != null) result.split = split;
    return result;
  }

  Config._();

  factory Config.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Config()..mergeFromBuffer(data, registry);
  factory Config.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Config()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Config',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: Config.$_createMessage)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'version', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..pPM<Server>(2, _omitFieldNames ? '' : 'servers',
        subBuilder: Server.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'chosenServerId')
    ..aOM<Settings>(4, _omitFieldNames ? '' : 'settings',
        subBuilder: Settings.$_createMessage)
    ..aOM<SplitTunnel>(5, _omitFieldNames ? '' : 'split',
        subBuilder: SplitTunnel.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Config clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Config copyWith(void Function(Config) updates) =>
      super.copyWith((message) => updates(message as Config)) as Config;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Config() / Config.new instead')
  static Config create() => Config._();
  static $pb.GeneratedMessage $_createMessage() => Config._();
  @$core.override
  Config createEmptyInstance() => Config._();
  @$core.pragma('dart2js:noInline')
  static Config getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Config>(Config.$_createMessage);
  static Config? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get version => $_getI64(0);
  @$pb.TagNumber(1)
  set version($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<Server> get servers => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get chosenServerId => $_getSZ(2);
  @$pb.TagNumber(3)
  set chosenServerId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChosenServerId() => $_has(2);
  @$pb.TagNumber(3)
  void clearChosenServerId() => $_clearField(3);

  @$pb.TagNumber(4)
  Settings get settings => $_getN(3);
  @$pb.TagNumber(4)
  set settings(Settings value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSettings() => $_has(3);
  @$pb.TagNumber(4)
  void clearSettings() => $_clearField(4);
  @$pb.TagNumber(4)
  Settings ensureSettings() => $_ensure(3);

  @$pb.TagNumber(5)
  SplitTunnel get split => $_getN(4);
  @$pb.TagNumber(5)
  set split(SplitTunnel value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSplit() => $_has(4);
  @$pb.TagNumber(5)
  void clearSplit() => $_clearField(5);
  @$pb.TagNumber(5)
  SplitTunnel ensureSplit() => $_ensure(4);
}

class Server extends $pb.GeneratedMessage {
  factory Server({
    $core.String? id,
    $core.String? displayName,
    Protocol? protocol,
    $core.String? address,
    $core.int? port,
    $core.String? uuid,
    $core.String? flow,
    Reality? reality,
    $core.String? transport,
    $core.String? countryCode,
    QuotaPlan? quota,
  }) {
    final result = Server._();
    if (id != null) result.id = id;
    if (displayName != null) result.displayName = displayName;
    if (protocol != null) result.protocol = protocol;
    if (address != null) result.address = address;
    if (port != null) result.port = port;
    if (uuid != null) result.uuid = uuid;
    if (flow != null) result.flow = flow;
    if (reality != null) result.reality = reality;
    if (transport != null) result.transport = transport;
    if (countryCode != null) result.countryCode = countryCode;
    if (quota != null) result.quota = quota;
    return result;
  }

  Server._();

  factory Server.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Server()..mergeFromBuffer(data, registry);
  factory Server.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Server()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Server',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: Server.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aE<Protocol>(3, _omitFieldNames ? '' : 'protocol',
        enumValues: Protocol.values)
    ..aOS(4, _omitFieldNames ? '' : 'address')
    ..aI(5, _omitFieldNames ? '' : 'port', fieldType: $pb.PbFieldType.OU3)
    ..aOS(6, _omitFieldNames ? '' : 'uuid')
    ..aOS(7, _omitFieldNames ? '' : 'flow')
    ..aOM<Reality>(8, _omitFieldNames ? '' : 'reality',
        subBuilder: Reality.$_createMessage)
    ..aOS(9, _omitFieldNames ? '' : 'transport')
    ..aOS(10, _omitFieldNames ? '' : 'countryCode')
    ..aOM<QuotaPlan>(11, _omitFieldNames ? '' : 'quota',
        subBuilder: QuotaPlan.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Server clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Server copyWith(void Function(Server) updates) =>
      super.copyWith((message) => updates(message as Server)) as Server;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Server() / Server.new instead')
  static Server create() => Server._();
  static $pb.GeneratedMessage $_createMessage() => Server._();
  @$core.override
  Server createEmptyInstance() => Server._();
  @$core.pragma('dart2js:noInline')
  static Server getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Server>(Server.$_createMessage);
  static Server? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

  @$pb.TagNumber(3)
  Protocol get protocol => $_getN(2);
  @$pb.TagNumber(3)
  set protocol(Protocol value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasProtocol() => $_has(2);
  @$pb.TagNumber(3)
  void clearProtocol() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get address => $_getSZ(3);
  @$pb.TagNumber(4)
  set address($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAddress() => $_has(3);
  @$pb.TagNumber(4)
  void clearAddress() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get port => $_getIZ(4);
  @$pb.TagNumber(5)
  set port($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPort() => $_has(4);
  @$pb.TagNumber(5)
  void clearPort() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get uuid => $_getSZ(5);
  @$pb.TagNumber(6)
  set uuid($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUuid() => $_has(5);
  @$pb.TagNumber(6)
  void clearUuid() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get flow => $_getSZ(6);
  @$pb.TagNumber(7)
  set flow($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFlow() => $_has(6);
  @$pb.TagNumber(7)
  void clearFlow() => $_clearField(7);

  @$pb.TagNumber(8)
  Reality get reality => $_getN(7);
  @$pb.TagNumber(8)
  set reality(Reality value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasReality() => $_has(7);
  @$pb.TagNumber(8)
  void clearReality() => $_clearField(8);
  @$pb.TagNumber(8)
  Reality ensureReality() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.String get transport => $_getSZ(8);
  @$pb.TagNumber(9)
  set transport($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTransport() => $_has(8);
  @$pb.TagNumber(9)
  void clearTransport() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get countryCode => $_getSZ(9);
  @$pb.TagNumber(10)
  set countryCode($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCountryCode() => $_has(9);
  @$pb.TagNumber(10)
  void clearCountryCode() => $_clearField(10);

  @$pb.TagNumber(11)
  QuotaPlan get quota => $_getN(10);
  @$pb.TagNumber(11)
  set quota(QuotaPlan value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasQuota() => $_has(10);
  @$pb.TagNumber(11)
  void clearQuota() => $_clearField(11);
  @$pb.TagNumber(11)
  QuotaPlan ensureQuota() => $_ensure(10);
}

class Reality extends $pb.GeneratedMessage {
  factory Reality({
    $core.String? publicKey,
    $core.String? shortId,
    $core.String? serverName,
    $core.String? fingerprint,
  }) {
    final result = Reality._();
    if (publicKey != null) result.publicKey = publicKey;
    if (shortId != null) result.shortId = shortId;
    if (serverName != null) result.serverName = serverName;
    if (fingerprint != null) result.fingerprint = fingerprint;
    return result;
  }

  Reality._();

  factory Reality.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Reality()..mergeFromBuffer(data, registry);
  factory Reality.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Reality()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Reality',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: Reality.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'publicKey')
    ..aOS(2, _omitFieldNames ? '' : 'shortId')
    ..aOS(3, _omitFieldNames ? '' : 'serverName')
    ..aOS(4, _omitFieldNames ? '' : 'fingerprint')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Reality clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Reality copyWith(void Function(Reality) updates) =>
      super.copyWith((message) => updates(message as Reality)) as Reality;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Reality() / Reality.new instead')
  static Reality create() => Reality._();
  static $pb.GeneratedMessage $_createMessage() => Reality._();
  @$core.override
  Reality createEmptyInstance() => Reality._();
  @$core.pragma('dart2js:noInline')
  static Reality getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Reality>(Reality.$_createMessage);
  static Reality? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get publicKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set publicKey($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPublicKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearPublicKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get shortId => $_getSZ(1);
  @$pb.TagNumber(2)
  set shortId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasShortId() => $_has(1);
  @$pb.TagNumber(2)
  void clearShortId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get serverName => $_getSZ(2);
  @$pb.TagNumber(3)
  set serverName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasServerName() => $_has(2);
  @$pb.TagNumber(3)
  void clearServerName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get fingerprint => $_getSZ(3);
  @$pb.TagNumber(4)
  set fingerprint($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFingerprint() => $_has(3);
  @$pb.TagNumber(4)
  void clearFingerprint() => $_clearField(4);
}

class QuotaPlan extends $pb.GeneratedMessage {
  factory QuotaPlan({
    $core.int? capGb,
    $core.int? billingDay,
    CountsMode? counts,
  }) {
    final result = QuotaPlan._();
    if (capGb != null) result.capGb = capGb;
    if (billingDay != null) result.billingDay = billingDay;
    if (counts != null) result.counts = counts;
    return result;
  }

  QuotaPlan._();

  factory QuotaPlan.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      QuotaPlan()..mergeFromBuffer(data, registry);
  factory QuotaPlan.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      QuotaPlan()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QuotaPlan',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: QuotaPlan.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'capGb', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'billingDay', fieldType: $pb.PbFieldType.OU3)
    ..aE<CountsMode>(3, _omitFieldNames ? '' : 'counts',
        enumValues: CountsMode.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuotaPlan clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuotaPlan copyWith(void Function(QuotaPlan) updates) =>
      super.copyWith((message) => updates(message as QuotaPlan)) as QuotaPlan;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use QuotaPlan() / QuotaPlan.new instead')
  static QuotaPlan create() => QuotaPlan._();
  static $pb.GeneratedMessage $_createMessage() => QuotaPlan._();
  @$core.override
  QuotaPlan createEmptyInstance() => QuotaPlan._();
  @$core.pragma('dart2js:noInline')
  static QuotaPlan getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<QuotaPlan>(QuotaPlan.$_createMessage);
  static QuotaPlan? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get capGb => $_getIZ(0);
  @$pb.TagNumber(1)
  set capGb($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCapGb() => $_has(0);
  @$pb.TagNumber(1)
  void clearCapGb() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get billingDay => $_getIZ(1);
  @$pb.TagNumber(2)
  set billingDay($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBillingDay() => $_has(1);
  @$pb.TagNumber(2)
  void clearBillingDay() => $_clearField(2);

  @$pb.TagNumber(3)
  CountsMode get counts => $_getN(2);
  @$pb.TagNumber(3)
  set counts(CountsMode value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCounts() => $_has(2);
  @$pb.TagNumber(3)
  void clearCounts() => $_clearField(3);
}

class Settings extends $pb.GeneratedMessage {
  factory Settings({
    $core.bool? killSwitch,
    $core.bool? autoReconnect,
    $core.bool? allowLocalNetwork,
    $core.bool? updateCheckOff,
    $core.bool? backgroundDownloadOff,
    $core.bool? previousCoreOff,
    $core.String? customDns,
  }) {
    final result = Settings._();
    if (killSwitch != null) result.killSwitch = killSwitch;
    if (autoReconnect != null) result.autoReconnect = autoReconnect;
    if (allowLocalNetwork != null) result.allowLocalNetwork = allowLocalNetwork;
    if (updateCheckOff != null) result.updateCheckOff = updateCheckOff;
    if (backgroundDownloadOff != null)
      result.backgroundDownloadOff = backgroundDownloadOff;
    if (previousCoreOff != null) result.previousCoreOff = previousCoreOff;
    if (customDns != null) result.customDns = customDns;
    return result;
  }

  Settings._();

  factory Settings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Settings()..mergeFromBuffer(data, registry);
  factory Settings.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Settings()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Settings',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: Settings.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'killSwitch')
    ..aOB(2, _omitFieldNames ? '' : 'autoReconnect')
    ..aOB(3, _omitFieldNames ? '' : 'allowLocalNetwork')
    ..aOB(4, _omitFieldNames ? '' : 'updateCheckOff')
    ..aOB(5, _omitFieldNames ? '' : 'backgroundDownloadOff')
    ..aOB(6, _omitFieldNames ? '' : 'previousCoreOff')
    ..aOS(7, _omitFieldNames ? '' : 'customDns')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Settings clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Settings copyWith(void Function(Settings) updates) =>
      super.copyWith((message) => updates(message as Settings)) as Settings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Settings() / Settings.new instead')
  static Settings create() => Settings._();
  static $pb.GeneratedMessage $_createMessage() => Settings._();
  @$core.override
  Settings createEmptyInstance() => Settings._();
  @$core.pragma('dart2js:noInline')
  static Settings getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Settings>(Settings.$_createMessage);
  static Settings? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get killSwitch => $_getBF(0);
  @$pb.TagNumber(1)
  set killSwitch($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKillSwitch() => $_has(0);
  @$pb.TagNumber(1)
  void clearKillSwitch() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get autoReconnect => $_getBF(1);
  @$pb.TagNumber(2)
  set autoReconnect($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAutoReconnect() => $_has(1);
  @$pb.TagNumber(2)
  void clearAutoReconnect() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get allowLocalNetwork => $_getBF(2);
  @$pb.TagNumber(3)
  set allowLocalNetwork($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAllowLocalNetwork() => $_has(2);
  @$pb.TagNumber(3)
  void clearAllowLocalNetwork() => $_clearField(3);

  /// Update rules (Updates screen). All three rules are ON by default, so the
  /// fields are named for the OFF state: a Config saved before they existed
  /// (every field absent, so false) keeps the default without a migration.
  @$pb.TagNumber(4)
  $core.bool get updateCheckOff => $_getBF(3);
  @$pb.TagNumber(4)
  set updateCheckOff($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUpdateCheckOff() => $_has(3);
  @$pb.TagNumber(4)
  void clearUpdateCheckOff() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get backgroundDownloadOff => $_getBF(4);
  @$pb.TagNumber(5)
  set backgroundDownloadOff($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBackgroundDownloadOff() => $_has(4);
  @$pb.TagNumber(5)
  void clearBackgroundDownloadOff() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get previousCoreOff => $_getBF(5);
  @$pb.TagNumber(6)
  set previousCoreOff($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPreviousCoreOff() => $_has(5);
  @$pb.TagNumber(6)
  void clearPreviousCoreOff() => $_clearField(6);

  /// The DNS resolver the tunnel uses, one IPv4 or IPv6 address. Empty means the
  /// default public resolver. A value that is not a usable address is refused.
  @$pb.TagNumber(7)
  $core.String get customDns => $_getSZ(6);
  @$pb.TagNumber(7)
  set customDns($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCustomDns() => $_has(6);
  @$pb.TagNumber(7)
  void clearCustomDns() => $_clearField(7);
}

class SplitTunnel extends $pb.GeneratedMessage {
  factory SplitTunnel({
    SplitMode? mode,
    $core.Iterable<Rule>? allExceptListed,
    $core.Iterable<Rule>? onlyListed,
  }) {
    final result = SplitTunnel._();
    if (mode != null) result.mode = mode;
    if (allExceptListed != null) result.allExceptListed.addAll(allExceptListed);
    if (onlyListed != null) result.onlyListed.addAll(onlyListed);
    return result;
  }

  SplitTunnel._();

  factory SplitTunnel.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SplitTunnel()..mergeFromBuffer(data, registry);
  factory SplitTunnel.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SplitTunnel()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SplitTunnel',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: SplitTunnel.$_createMessage)
    ..aE<SplitMode>(1, _omitFieldNames ? '' : 'mode',
        enumValues: SplitMode.values)
    ..pPM<Rule>(2, _omitFieldNames ? '' : 'allExceptListed',
        subBuilder: Rule.$_createMessage)
    ..pPM<Rule>(3, _omitFieldNames ? '' : 'onlyListed',
        subBuilder: Rule.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SplitTunnel clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SplitTunnel copyWith(void Function(SplitTunnel) updates) =>
      super.copyWith((message) => updates(message as SplitTunnel))
          as SplitTunnel;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SplitTunnel() / SplitTunnel.new instead')
  static SplitTunnel create() => SplitTunnel._();
  static $pb.GeneratedMessage $_createMessage() => SplitTunnel._();
  @$core.override
  SplitTunnel createEmptyInstance() => SplitTunnel._();
  @$core.pragma('dart2js:noInline')
  static SplitTunnel getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SplitTunnel>(
          SplitTunnel.$_createMessage);
  static SplitTunnel? _defaultInstance;

  @$pb.TagNumber(1)
  SplitMode get mode => $_getN(0);
  @$pb.TagNumber(1)
  set mode(SplitMode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearMode() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<Rule> get allExceptListed => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<Rule> get onlyListed => $_getList(2);
}

class Rule extends $pb.GeneratedMessage {
  factory Rule({
    RuleKind? kind,
    $core.String? value,
    $core.bool? includeSubdomains,
  }) {
    final result = Rule._();
    if (kind != null) result.kind = kind;
    if (value != null) result.value = value;
    if (includeSubdomains != null) result.includeSubdomains = includeSubdomains;
    return result;
  }

  Rule._();

  factory Rule.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Rule()..mergeFromBuffer(data, registry);
  factory Rule.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Rule()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Rule',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: Rule.$_createMessage)
    ..aE<RuleKind>(1, _omitFieldNames ? '' : 'kind',
        enumValues: RuleKind.values)
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..aOB(3, _omitFieldNames ? '' : 'includeSubdomains')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Rule clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Rule copyWith(void Function(Rule) updates) =>
      super.copyWith((message) => updates(message as Rule)) as Rule;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Rule() / Rule.new instead')
  static Rule create() => Rule._();
  static $pb.GeneratedMessage $_createMessage() => Rule._();
  @$core.override
  Rule createEmptyInstance() => Rule._();
  @$core.pragma('dart2js:noInline')
  static Rule getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Rule>(Rule.$_createMessage);
  static Rule? _defaultInstance;

  @$pb.TagNumber(1)
  RuleKind get kind => $_getN(0);
  @$pb.TagNumber(1)
  set kind(RuleKind value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get includeSubdomains => $_getBF(2);
  @$pb.TagNumber(3)
  set includeSubdomains($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIncludeSubdomains() => $_has(2);
  @$pb.TagNumber(3)
  void clearIncludeSubdomains() => $_clearField(3);
}

/// Encrypted sync vault plaintext payload (docs/charon_sync_design.md section 3).
class SyncPayload extends $pb.GeneratedMessage {
  factory SyncPayload({
    $core.int? schemaVersion,
    $fixnum.Int64? revision,
    $fixnum.Int64? writtenAtMs,
    $core.String? writerDeviceName,
    Config? config,
    UiSync? ui,
  }) {
    final result = SyncPayload._();
    if (schemaVersion != null) result.schemaVersion = schemaVersion;
    if (revision != null) result.revision = revision;
    if (writtenAtMs != null) result.writtenAtMs = writtenAtMs;
    if (writerDeviceName != null) result.writerDeviceName = writerDeviceName;
    if (config != null) result.config = config;
    if (ui != null) result.ui = ui;
    return result;
  }

  SyncPayload._();

  factory SyncPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncPayload()..mergeFromBuffer(data, registry);
  factory SyncPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncPayload()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: SyncPayload.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'schemaVersion',
        fieldType: $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'revision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(3, _omitFieldNames ? '' : 'writtenAtMs')
    ..aOS(4, _omitFieldNames ? '' : 'writerDeviceName')
    ..aOM<Config>(5, _omitFieldNames ? '' : 'config',
        subBuilder: Config.$_createMessage)
    ..aOM<UiSync>(6, _omitFieldNames ? '' : 'ui',
        subBuilder: UiSync.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncPayload copyWith(void Function(SyncPayload) updates) =>
      super.copyWith((message) => updates(message as SyncPayload))
          as SyncPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SyncPayload() / SyncPayload.new instead')
  static SyncPayload create() => SyncPayload._();
  static $pb.GeneratedMessage $_createMessage() => SyncPayload._();
  @$core.override
  SyncPayload createEmptyInstance() => SyncPayload._();
  @$core.pragma('dart2js:noInline')
  static SyncPayload getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncPayload>(
          SyncPayload.$_createMessage);
  static SyncPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get schemaVersion => $_getIZ(0);
  @$pb.TagNumber(1)
  set schemaVersion($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSchemaVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearSchemaVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get revision => $_getI64(1);
  @$pb.TagNumber(2)
  set revision($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRevision() => $_has(1);
  @$pb.TagNumber(2)
  void clearRevision() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get writtenAtMs => $_getI64(2);
  @$pb.TagNumber(3)
  set writtenAtMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWrittenAtMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearWrittenAtMs() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get writerDeviceName => $_getSZ(3);
  @$pb.TagNumber(4)
  set writerDeviceName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWriterDeviceName() => $_has(3);
  @$pb.TagNumber(4)
  void clearWriterDeviceName() => $_clearField(4);

  @$pb.TagNumber(5)
  Config get config => $_getN(4);
  @$pb.TagNumber(5)
  set config(Config value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasConfig() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfig() => $_clearField(5);
  @$pb.TagNumber(5)
  Config ensureConfig() => $_ensure(4);

  @$pb.TagNumber(6)
  UiSync get ui => $_getN(5);
  @$pb.TagNumber(6)
  set ui(UiSync value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasUi() => $_has(5);
  @$pb.TagNumber(6)
  void clearUi() => $_clearField(6);
  @$pb.TagNumber(6)
  UiSync ensureUi() => $_ensure(5);
}

class UiSync extends $pb.GeneratedMessage {
  factory UiSync({
    SyncTheme? theme,
    $core.String? language,
  }) {
    final result = UiSync._();
    if (theme != null) result.theme = theme;
    if (language != null) result.language = language;
    return result;
  }

  UiSync._();

  factory UiSync.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UiSync()..mergeFromBuffer(data, registry);
  factory UiSync.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UiSync()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UiSync',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'charon.v1'),
      createEmptyInstance: UiSync.$_createMessage)
    ..aE<SyncTheme>(1, _omitFieldNames ? '' : 'theme',
        enumValues: SyncTheme.values)
    ..aOS(2, _omitFieldNames ? '' : 'language')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UiSync clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UiSync copyWith(void Function(UiSync) updates) =>
      super.copyWith((message) => updates(message as UiSync)) as UiSync;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UiSync() / UiSync.new instead')
  static UiSync create() => UiSync._();
  static $pb.GeneratedMessage $_createMessage() => UiSync._();
  @$core.override
  UiSync createEmptyInstance() => UiSync._();
  @$core.pragma('dart2js:noInline')
  static UiSync getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UiSync>(UiSync.$_createMessage);
  static UiSync? _defaultInstance;

  @$pb.TagNumber(1)
  SyncTheme get theme => $_getN(0);
  @$pb.TagNumber(1)
  set theme(SyncTheme value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTheme() => $_has(0);
  @$pb.TagNumber(1)
  void clearTheme() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get language => $_getSZ(1);
  @$pb.TagNumber(2)
  set language($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLanguage() => $_has(1);
  @$pb.TagNumber(2)
  void clearLanguage() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
