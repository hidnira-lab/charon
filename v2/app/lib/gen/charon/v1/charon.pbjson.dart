// This is a generated file - do not edit.
//
// Generated from charon/v1/charon.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use phaseDescriptor instead')
const Phase$json = {
  '1': 'Phase',
  '2': [
    {'1': 'PHASE_UNSPECIFIED', '2': 0},
    {'1': 'PHASE_IDLE', '2': 1},
    {'1': 'PHASE_STARTING', '2': 2},
    {'1': 'PHASE_VERIFYING', '2': 3},
    {'1': 'PHASE_UP', '2': 4},
    {'1': 'PHASE_RETRYING', '2': 5},
    {'1': 'PHASE_SWITCHING', '2': 6},
    {'1': 'PHASE_STOPPING', '2': 7},
    {'1': 'PHASE_BLOCKED', '2': 8},
  ],
};

/// Descriptor for `Phase`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List phaseDescriptor = $convert.base64Decode(
    'CgVQaGFzZRIVChFQSEFTRV9VTlNQRUNJRklFRBAAEg4KClBIQVNFX0lETEUQARISCg5QSEFTRV'
    '9TVEFSVElORxACEhMKD1BIQVNFX1ZFUklGWUlORxADEgwKCFBIQVNFX1VQEAQSEgoOUEhBU0Vf'
    'UkVUUllJTkcQBRITCg9QSEFTRV9TV0lUQ0hJTkcQBhISCg5QSEFTRV9TVE9QUElORxAHEhEKDV'
    'BIQVNFX0JMT0NLRUQQCA==');

@$core.Deprecated('Use gateDescriptor instead')
const Gate$json = {
  '1': 'Gate',
  '2': [
    {'1': 'GATE_UNSPECIFIED', '2': 0},
    {'1': 'GATE_DISARMED', '2': 1},
    {'1': 'GATE_ARMED', '2': 2},
    {'1': 'GATE_HELD', '2': 3},
  ],
};

/// Descriptor for `Gate`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List gateDescriptor = $convert.base64Decode(
    'CgRHYXRlEhQKEEdBVEVfVU5TUEVDSUZJRUQQABIRCg1HQVRFX0RJU0FSTUVEEAESDgoKR0FURV'
    '9BUk1FRBACEg0KCUdBVEVfSEVMRBAD');

@$core.Deprecated('Use quotaLevelDescriptor instead')
const QuotaLevel$json = {
  '1': 'QuotaLevel',
  '2': [
    {'1': 'QUOTA_UNSPECIFIED', '2': 0},
    {'1': 'QUOTA_NORMAL', '2': 1},
    {'1': 'QUOTA_AMBER', '2': 2},
    {'1': 'QUOTA_RED', '2': 3},
  ],
};

/// Descriptor for `QuotaLevel`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List quotaLevelDescriptor = $convert.base64Decode(
    'CgpRdW90YUxldmVsEhUKEVFVT1RBX1VOU1BFQ0lGSUVEEAASEAoMUVVPVEFfTk9STUFMEAESDw'
    'oLUVVPVEFfQU1CRVIQAhINCglRVU9UQV9SRUQQAw==');

@$core.Deprecated('Use protocolDescriptor instead')
const Protocol$json = {
  '1': 'Protocol',
  '2': [
    {'1': 'PROTOCOL_UNSPECIFIED', '2': 0},
    {'1': 'PROTOCOL_VLESS_REALITY', '2': 1},
  ],
};

/// Descriptor for `Protocol`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List protocolDescriptor = $convert.base64Decode(
    'CghQcm90b2NvbBIYChRQUk9UT0NPTF9VTlNQRUNJRklFRBAAEhoKFlBST1RPQ09MX1ZMRVNTX1'
    'JFQUxJVFkQAQ==');

@$core.Deprecated('Use countsModeDescriptor instead')
const CountsMode$json = {
  '1': 'CountsMode',
  '2': [
    {'1': 'COUNTS_UNSPECIFIED', '2': 0},
    {'1': 'COUNTS_OUT_ONLY', '2': 1},
    {'1': 'COUNTS_IN_AND_OUT', '2': 2},
  ],
};

/// Descriptor for `CountsMode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List countsModeDescriptor = $convert.base64Decode(
    'CgpDb3VudHNNb2RlEhYKEkNPVU5UU19VTlNQRUNJRklFRBAAEhMKD0NPVU5UU19PVVRfT05MWR'
    'ABEhUKEUNPVU5UU19JTl9BTkRfT1VUEAI=');

@$core.Deprecated('Use splitModeDescriptor instead')
const SplitMode$json = {
  '1': 'SplitMode',
  '2': [
    {'1': 'SPLIT_UNSPECIFIED', '2': 0},
    {'1': 'SPLIT_ALL_EXCEPT_LISTED', '2': 1},
    {'1': 'SPLIT_ONLY_LISTED', '2': 2},
  ],
};

/// Descriptor for `SplitMode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List splitModeDescriptor = $convert.base64Decode(
    'CglTcGxpdE1vZGUSFQoRU1BMSVRfVU5TUEVDSUZJRUQQABIbChdTUExJVF9BTExfRVhDRVBUX0'
    'xJU1RFRBABEhUKEVNQTElUX09OTFlfTElTVEVEEAI=');

@$core.Deprecated('Use ruleKindDescriptor instead')
const RuleKind$json = {
  '1': 'RuleKind',
  '2': [
    {'1': 'RULE_UNSPECIFIED', '2': 0},
    {'1': 'RULE_DOMAIN', '2': 1},
    {'1': 'RULE_CIDR', '2': 2},
    {'1': 'RULE_APP', '2': 3},
  ],
};

/// Descriptor for `RuleKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List ruleKindDescriptor = $convert.base64Decode(
    'CghSdWxlS2luZBIUChBSVUxFX1VOU1BFQ0lGSUVEEAASDwoLUlVMRV9ET01BSU4QARINCglSVU'
    'xFX0NJRFIQAhIMCghSVUxFX0FQUBAD');

@$core.Deprecated('Use topicDescriptor instead')
const Topic$json = {
  '1': 'Topic',
  '2': [
    {'1': 'TOPIC_UNSPECIFIED', '2': 0},
    {'1': 'TOPIC_THROUGHPUT', '2': 1},
    {'1': 'TOPIC_LOGS', '2': 2},
  ],
};

/// Descriptor for `Topic`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List topicDescriptor = $convert.base64Decode(
    'CgVUb3BpYxIVChFUT1BJQ19VTlNQRUNJRklFRBAAEhQKEFRPUElDX1RIUk9VR0hQVVQQARIOCg'
    'pUT1BJQ19MT0dTEAI=');

@$core.Deprecated('Use logSourceDescriptor instead')
const LogSource$json = {
  '1': 'LogSource',
  '2': [
    {'1': 'LOG_SOURCE_UNSPECIFIED', '2': 0},
    {'1': 'LOG_SOURCE_XRAY_ACCESS', '2': 1},
    {'1': 'LOG_SOURCE_CHARON_CORE', '2': 2},
  ],
};

/// Descriptor for `LogSource`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List logSourceDescriptor = $convert.base64Decode(
    'CglMb2dTb3VyY2USGgoWTE9HX1NPVVJDRV9VTlNQRUNJRklFRBAAEhoKFkxPR19TT1VSQ0VfWF'
    'JBWV9BQ0NFU1MQARIaChZMT0dfU09VUkNFX0NIQVJPTl9DT1JFEAI=');

@$core.Deprecated('Use logLevelDescriptor instead')
const LogLevel$json = {
  '1': 'LogLevel',
  '2': [
    {'1': 'LOG_LEVEL_UNSPECIFIED', '2': 0},
    {'1': 'LOG_LEVEL_INFO', '2': 1},
    {'1': 'LOG_LEVEL_WARN', '2': 2},
    {'1': 'LOG_LEVEL_ERROR', '2': 3},
  ],
};

/// Descriptor for `LogLevel`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List logLevelDescriptor = $convert.base64Decode(
    'CghMb2dMZXZlbBIZChVMT0dfTEVWRUxfVU5TUEVDSUZJRUQQABISCg5MT0dfTEVWRUxfSU5GTx'
    'ABEhIKDkxPR19MRVZFTF9XQVJOEAISEwoPTE9HX0xFVkVMX0VSUk9SEAM=');

@$core.Deprecated('Use updateKindDescriptor instead')
const UpdateKind$json = {
  '1': 'UpdateKind',
  '2': [
    {'1': 'UPDATE_KIND_UNSPECIFIED', '2': 0},
    {'1': 'UPDATE_KIND_CORE', '2': 1},
    {'1': 'UPDATE_KIND_APP', '2': 2},
  ],
};

/// Descriptor for `UpdateKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List updateKindDescriptor = $convert.base64Decode(
    'CgpVcGRhdGVLaW5kEhsKF1VQREFURV9LSU5EX1VOU1BFQ0lGSUVEEAASFAoQVVBEQVRFX0tJTk'
    'RfQ09SRRABEhMKD1VQREFURV9LSU5EX0FQUBAC');

@$core.Deprecated('Use applyWhenDescriptor instead')
const ApplyWhen$json = {
  '1': 'ApplyWhen',
  '2': [
    {'1': 'APPLY_UNSPECIFIED', '2': 0},
    {'1': 'APPLY_NOW', '2': 1},
    {'1': 'APPLY_WHEN_DISCONNECTED', '2': 2},
  ],
};

/// Descriptor for `ApplyWhen`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List applyWhenDescriptor = $convert.base64Decode(
    'CglBcHBseVdoZW4SFQoRQVBQTFlfVU5TUEVDSUZJRUQQABINCglBUFBMWV9OT1cQARIbChdBUF'
    'BMWV9XSEVOX0RJU0NPTk5FQ1RFRBAC');

@$core.Deprecated('Use updateStageDescriptor instead')
const UpdateStage$json = {
  '1': 'UpdateStage',
  '2': [
    {'1': 'UPDATE_STAGE_UNSPECIFIED', '2': 0},
    {'1': 'UPDATE_UP_TO_DATE', '2': 1},
    {'1': 'UPDATE_AVAILABLE', '2': 2},
    {'1': 'UPDATE_DOWNLOADING', '2': 3},
    {'1': 'UPDATE_READY', '2': 4},
    {'1': 'UPDATE_QUEUED', '2': 5},
    {'1': 'UPDATE_APPLYING', '2': 6},
    {'1': 'UPDATE_UPDATED', '2': 7},
    {'1': 'UPDATE_ROLLED_BACK', '2': 8},
    {'1': 'UPDATE_CANNOT_CHECK', '2': 9},
  ],
};

/// Descriptor for `UpdateStage`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List updateStageDescriptor = $convert.base64Decode(
    'CgtVcGRhdGVTdGFnZRIcChhVUERBVEVfU1RBR0VfVU5TUEVDSUZJRUQQABIVChFVUERBVEVfVV'
    'BfVE9fREFURRABEhQKEFVQREFURV9BVkFJTEFCTEUQAhIWChJVUERBVEVfRE9XTkxPQURJTkcQ'
    'AxIQCgxVUERBVEVfUkVBRFkQBBIRCg1VUERBVEVfUVVFVUVEEAUSEwoPVVBEQVRFX0FQUExZSU'
    '5HEAYSEgoOVVBEQVRFX1VQREFURUQQBxIWChJVUERBVEVfUk9MTEVEX0JBQ0sQCBIXChNVUERB'
    'VEVfQ0FOTk9UX0NIRUNLEAk=');

@$core.Deprecated('Use noticeKindDescriptor instead')
const NoticeKind$json = {
  '1': 'NoticeKind',
  '2': [
    {'1': 'NOTICE_UNSPECIFIED', '2': 0},
    {'1': 'NOTICE_RECONNECTED', '2': 1},
    {'1': 'NOTICE_MOVED_TO_BACKUP', '2': 2},
    {'1': 'NOTICE_TRAFFIC_HELD', '2': 3},
    {'1': 'NOTICE_QUOTA_AMBER', '2': 4},
    {'1': 'NOTICE_QUOTA_CAP', '2': 5},
    {'1': 'NOTICE_TUNNEL_LOST', '2': 6},
  ],
};

/// Descriptor for `NoticeKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List noticeKindDescriptor = $convert.base64Decode(
    'CgpOb3RpY2VLaW5kEhYKEk5PVElDRV9VTlNQRUNJRklFRBAAEhYKEk5PVElDRV9SRUNPTk5FQ1'
    'RFRBABEhoKFk5PVElDRV9NT1ZFRF9UT19CQUNLVVAQAhIXChNOT1RJQ0VfVFJBRkZJQ19IRUxE'
    'EAMSFgoSTk9USUNFX1FVT1RBX0FNQkVSEAQSFAoQTk9USUNFX1FVT1RBX0NBUBAFEhYKEk5PVE'
    'lDRV9UVU5ORUxfTE9TVBAG');

@$core.Deprecated('Use failureReasonDescriptor instead')
const FailureReason$json = {
  '1': 'FailureReason',
  '2': [
    {'1': 'FAILURE_UNSPECIFIED', '2': 0},
    {'1': 'FAILURE_TCP_TIMEOUT', '2': 1},
    {'1': 'FAILURE_REALITY_HANDSHAKE', '2': 2},
    {'1': 'FAILURE_EGRESS_MISMATCH', '2': 3},
    {'1': 'FAILURE_CONFIG_REJECTED', '2': 4},
    {'1': 'FAILURE_ADAPTER_FAILED', '2': 5},
    {'1': 'FAILURE_PORT_IN_USE', '2': 6},
    {'1': 'FAILURE_XRAY_EXITED', '2': 7},
    {'1': 'FAILURE_ADAPTER_LOST', '2': 8},
    {'1': 'FAILURE_NETWORK_CHANGED', '2': 9},
    {'1': 'FAILURE_DNS_NOT_TUNNELLED', '2': 10},
    {'1': 'FAILURE_GATE_FAILED', '2': 11},
  ],
};

/// Descriptor for `FailureReason`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List failureReasonDescriptor = $convert.base64Decode(
    'Cg1GYWlsdXJlUmVhc29uEhcKE0ZBSUxVUkVfVU5TUEVDSUZJRUQQABIXChNGQUlMVVJFX1RDUF'
    '9USU1FT1VUEAESHQoZRkFJTFVSRV9SRUFMSVRZX0hBTkRTSEFLRRACEhsKF0ZBSUxVUkVfRUdS'
    'RVNTX01JU01BVENIEAMSGwoXRkFJTFVSRV9DT05GSUdfUkVKRUNURUQQBBIaChZGQUlMVVJFX0'
    'FEQVBURVJfRkFJTEVEEAUSFwoTRkFJTFVSRV9QT1JUX0lOX1VTRRAGEhcKE0ZBSUxVUkVfWFJB'
    'WV9FWElURUQQBxIYChRGQUlMVVJFX0FEQVBURVJfTE9TVBAIEhsKF0ZBSUxVUkVfTkVUV09SS1'
    '9DSEFOR0VEEAkSHQoZRkFJTFVSRV9ETlNfTk9UX1RVTk5FTExFRBAKEhcKE0ZBSUxVUkVfR0FU'
    'RV9GQUlMRUQQCw==');

@$core.Deprecated('Use probeDescriptor instead')
const Probe$json = {
  '1': 'Probe',
  '2': [
    {'1': 'PROBE_UNSPECIFIED', '2': 0},
    {'1': 'PROBE_NETWORK_CHANGE', '2': 1},
    {'1': 'PROBE_WAKE', '2': 2},
  ],
};

/// Descriptor for `Probe`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List probeDescriptor = $convert.base64Decode(
    'CgVQcm9iZRIVChFQUk9CRV9VTlNQRUNJRklFRBAAEhgKFFBST0JFX05FVFdPUktfQ0hBTkdFEA'
    'ESDgoKUFJPQkVfV0FLRRAC');

@$core.Deprecated('Use sessionEndDescriptor instead')
const SessionEnd$json = {
  '1': 'SessionEnd',
  '2': [
    {'1': 'SESSION_END_UNSPECIFIED', '2': 0},
    {'1': 'SESSION_END_MANUAL', '2': 1},
    {'1': 'SESSION_END_COULD_NOT_REACH', '2': 2},
    {'1': 'SESSION_END_TUNNEL_LOST', '2': 3},
    {'1': 'SESSION_END_VPN_REVOKED', '2': 4},
    {'1': 'SESSION_END_ANOTHER_VPN', '2': 5},
    {'1': 'SESSION_END_ANDROID_STOPPED', '2': 6},
  ],
};

/// Descriptor for `SessionEnd`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sessionEndDescriptor = $convert.base64Decode(
    'CgpTZXNzaW9uRW5kEhsKF1NFU1NJT05fRU5EX1VOU1BFQ0lGSUVEEAASFgoSU0VTU0lPTl9FTk'
    'RfTUFOVUFMEAESHwobU0VTU0lPTl9FTkRfQ09VTERfTk9UX1JFQUNIEAISGwoXU0VTU0lPTl9F'
    'TkRfVFVOTkVMX0xPU1QQAxIbChdTRVNTSU9OX0VORF9WUE5fUkVWT0tFRBAEEhsKF1NFU1NJT0'
    '5fRU5EX0FOT1RIRVJfVlBOEAUSHwobU0VTU0lPTl9FTkRfQU5EUk9JRF9TVE9QUEVEEAY=');

@$core.Deprecated('Use errorCodeDescriptor instead')
const ErrorCode$json = {
  '1': 'ErrorCode',
  '2': [
    {'1': 'ERROR_UNSPECIFIED', '2': 0},
    {'1': 'ERROR_INVALID_ARGUMENT', '2': 1},
    {'1': 'ERROR_UNKNOWN_SERVER', '2': 2},
    {'1': 'ERROR_NOT_ALLOWED_IN_STATE', '2': 3},
    {'1': 'ERROR_CONFIG_VERSION_MISMATCH', '2': 4},
    {'1': 'ERROR_CONFIG_REJECTED', '2': 5},
    {'1': 'ERROR_UNSUPPORTED', '2': 6},
    {'1': 'ERROR_BUSY', '2': 7},
    {'1': 'ERROR_UPDATE_SIGNATURE_INVALID', '2': 8},
    {'1': 'ERROR_UPDATE_FAILED', '2': 9},
    {'1': 'ERROR_INTERNAL', '2': 10},
  ],
};

/// Descriptor for `ErrorCode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List errorCodeDescriptor = $convert.base64Decode(
    'CglFcnJvckNvZGUSFQoRRVJST1JfVU5TUEVDSUZJRUQQABIaChZFUlJPUl9JTlZBTElEX0FSR1'
    'VNRU5UEAESGAoURVJST1JfVU5LTk9XTl9TRVJWRVIQAhIeChpFUlJPUl9OT1RfQUxMT1dFRF9J'
    'Tl9TVEFURRADEiEKHUVSUk9SX0NPTkZJR19WRVJTSU9OX01JU01BVENIEAQSGQoVRVJST1JfQ0'
    '9ORklHX1JFSkVDVEVEEAUSFQoRRVJST1JfVU5TVVBQT1JURUQQBhIOCgpFUlJPUl9CVVNZEAcS'
    'IgoeRVJST1JfVVBEQVRFX1NJR05BVFVSRV9JTlZBTElEEAgSFwoTRVJST1JfVVBEQVRFX0ZBSU'
    'xFRBAJEhIKDkVSUk9SX0lOVEVSTkFMEAo=');

@$core.Deprecated('Use syncThemeDescriptor instead')
const SyncTheme$json = {
  '1': 'SyncTheme',
  '2': [
    {'1': 'SYNC_THEME_UNSPECIFIED', '2': 0},
    {'1': 'SYNC_THEME_SYSTEM', '2': 1},
    {'1': 'SYNC_THEME_DARK', '2': 2},
    {'1': 'SYNC_THEME_LIGHT', '2': 3},
  ],
};

/// Descriptor for `SyncTheme`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List syncThemeDescriptor = $convert.base64Decode(
    'CglTeW5jVGhlbWUSGgoWU1lOQ19USEVNRV9VTlNQRUNJRklFRBAAEhUKEVNZTkNfVEhFTUVfU1'
    'lTVEVNEAESEwoPU1lOQ19USEVNRV9EQVJLEAISFAoQU1lOQ19USEVNRV9MSUdIVBAD');

@$core.Deprecated('Use envelopeDescriptor instead')
const Envelope$json = {
  '1': 'Envelope',
  '2': [
    {'1': 'protocol_version', '3': 1, '4': 1, '5': 13, '10': 'protocolVersion'},
    {'1': 'request_id', '3': 2, '4': 1, '5': 4, '10': 'requestId'},
    {
      '1': 'hello',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Hello',
      '9': 0,
      '10': 'hello'
    },
    {
      '1': 'hello_ack',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.HelloAck',
      '9': 0,
      '10': 'helloAck'
    },
    {
      '1': 'command',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Command',
      '9': 0,
      '10': 'command'
    },
    {
      '1': 'response',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Response',
      '9': 0,
      '10': 'response'
    },
    {
      '1': 'event',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Event',
      '9': 0,
      '10': 'event'
    },
  ],
  '8': [
    {'1': 'payload'},
  ],
};

/// Descriptor for `Envelope`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List envelopeDescriptor = $convert.base64Decode(
    'CghFbnZlbG9wZRIpChBwcm90b2NvbF92ZXJzaW9uGAEgASgNUg9wcm90b2NvbFZlcnNpb24SHQ'
    'oKcmVxdWVzdF9pZBgCIAEoBFIJcmVxdWVzdElkEigKBWhlbGxvGAogASgLMhAuY2hhcm9uLnYx'
    'LkhlbGxvSABSBWhlbGxvEjIKCWhlbGxvX2FjaxgLIAEoCzITLmNoYXJvbi52MS5IZWxsb0Fja0'
    'gAUghoZWxsb0FjaxIuCgdjb21tYW5kGAwgASgLMhIuY2hhcm9uLnYxLkNvbW1hbmRIAFIHY29t'
    'bWFuZBIxCghyZXNwb25zZRgNIAEoCzITLmNoYXJvbi52MS5SZXNwb25zZUgAUghyZXNwb25zZR'
    'IoCgVldmVudBgOIAEoCzIQLmNoYXJvbi52MS5FdmVudEgAUgVldmVudEIJCgdwYXlsb2Fk');

@$core.Deprecated('Use helloDescriptor instead')
const Hello$json = {
  '1': 'Hello',
  '2': [
    {
      '1': 'min_protocol_version',
      '3': 1,
      '4': 1,
      '5': 13,
      '10': 'minProtocolVersion'
    },
    {
      '1': 'max_protocol_version',
      '3': 2,
      '4': 1,
      '5': 13,
      '10': 'maxProtocolVersion'
    },
    {'1': 'app_version', '3': 3, '4': 1, '5': 9, '10': 'appVersion'},
    {'1': 'client_kind', '3': 4, '4': 1, '5': 9, '10': 'clientKind'},
  ],
};

/// Descriptor for `Hello`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List helloDescriptor = $convert.base64Decode(
    'CgVIZWxsbxIwChRtaW5fcHJvdG9jb2xfdmVyc2lvbhgBIAEoDVISbWluUHJvdG9jb2xWZXJzaW'
    '9uEjAKFG1heF9wcm90b2NvbF92ZXJzaW9uGAIgASgNUhJtYXhQcm90b2NvbFZlcnNpb24SHwoL'
    'YXBwX3ZlcnNpb24YAyABKAlSCmFwcFZlcnNpb24SHwoLY2xpZW50X2tpbmQYBCABKAlSCmNsaW'
    'VudEtpbmQ=');

@$core.Deprecated('Use helloAckDescriptor instead')
const HelloAck$json = {
  '1': 'HelloAck',
  '2': [
    {'1': 'protocol_version', '3': 1, '4': 1, '5': 13, '10': 'protocolVersion'},
    {'1': 'service_version', '3': 2, '4': 1, '5': 9, '10': 'serviceVersion'},
    {'1': 'xray_version', '3': 3, '4': 1, '5': 9, '10': 'xrayVersion'},
    {'1': 'config_version', '3': 4, '4': 1, '5': 4, '10': 'configVersion'},
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Status',
      '10': 'status'
    },
    {
      '1': 'error',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Error',
      '10': 'error'
    },
  ],
};

/// Descriptor for `HelloAck`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List helloAckDescriptor = $convert.base64Decode(
    'CghIZWxsb0FjaxIpChBwcm90b2NvbF92ZXJzaW9uGAEgASgNUg9wcm90b2NvbFZlcnNpb24SJw'
    'oPc2VydmljZV92ZXJzaW9uGAIgASgJUg5zZXJ2aWNlVmVyc2lvbhIhCgx4cmF5X3ZlcnNpb24Y'
    'AyABKAlSC3hyYXlWZXJzaW9uEiUKDmNvbmZpZ192ZXJzaW9uGAQgASgEUg1jb25maWdWZXJzaW'
    '9uEikKBnN0YXR1cxgFIAEoCzIRLmNoYXJvbi52MS5TdGF0dXNSBnN0YXR1cxImCgVlcnJvchgG'
    'IAEoCzIQLmNoYXJvbi52MS5FcnJvclIFZXJyb3I=');

@$core.Deprecated('Use commandDescriptor instead')
const Command$json = {
  '1': 'Command',
  '2': [
    {
      '1': 'connect',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Empty',
      '9': 0,
      '10': 'connect'
    },
    {
      '1': 'disconnect',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Empty',
      '9': 0,
      '10': 'disconnect'
    },
    {
      '1': 'cancel',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Empty',
      '9': 0,
      '10': 'cancel'
    },
    {
      '1': 'switch_now',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Empty',
      '9': 0,
      '10': 'switchNow'
    },
    {
      '1': 'move_to',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.ServerRef',
      '9': 0,
      '10': 'moveTo'
    },
    {
      '1': 'try_server',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.ServerRef',
      '9': 0,
      '10': 'tryServer'
    },
    {
      '1': 'release',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Empty',
      '9': 0,
      '10': 'release'
    },
    {
      '1': 'retry_now',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Empty',
      '9': 0,
      '10': 'retryNow'
    },
    {
      '1': 'set_config',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Config',
      '9': 0,
      '10': 'setConfig'
    },
    {
      '1': 'get_config',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Empty',
      '9': 0,
      '10': 'getConfig'
    },
    {
      '1': 'subscribe',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Subscription',
      '9': 0,
      '10': 'subscribe'
    },
    {
      '1': 'unsubscribe',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Subscription',
      '9': 0,
      '10': 'unsubscribe'
    },
    {
      '1': 'check_update',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Empty',
      '9': 0,
      '10': 'checkUpdate'
    },
    {
      '1': 'apply_update',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.ApplyUpdate',
      '9': 0,
      '10': 'applyUpdate'
    },
    {
      '1': 'rollback_core',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Empty',
      '9': 0,
      '10': 'rollbackCore'
    },
    {
      '1': 'export_diagnostics',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.ExportDiagnostics',
      '9': 0,
      '10': 'exportDiagnostics'
    },
    {
      '1': 'update_file_chunk',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.UpdateFileChunk',
      '9': 0,
      '10': 'updateFileChunk'
    },
  ],
  '8': [
    {'1': 'kind'},
  ],
};

/// Descriptor for `Command`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandDescriptor = $convert.base64Decode(
    'CgdDb21tYW5kEiwKB2Nvbm5lY3QYASABKAsyEC5jaGFyb24udjEuRW1wdHlIAFIHY29ubmVjdB'
    'IyCgpkaXNjb25uZWN0GAIgASgLMhAuY2hhcm9uLnYxLkVtcHR5SABSCmRpc2Nvbm5lY3QSKgoG'
    'Y2FuY2VsGAMgASgLMhAuY2hhcm9uLnYxLkVtcHR5SABSBmNhbmNlbBIxCgpzd2l0Y2hfbm93GA'
    'QgASgLMhAuY2hhcm9uLnYxLkVtcHR5SABSCXN3aXRjaE5vdxIvCgdtb3ZlX3RvGAUgASgLMhQu'
    'Y2hhcm9uLnYxLlNlcnZlclJlZkgAUgZtb3ZlVG8SNQoKdHJ5X3NlcnZlchgGIAEoCzIULmNoYX'
    'Jvbi52MS5TZXJ2ZXJSZWZIAFIJdHJ5U2VydmVyEiwKB3JlbGVhc2UYByABKAsyEC5jaGFyb24u'
    'djEuRW1wdHlIAFIHcmVsZWFzZRIvCglyZXRyeV9ub3cYCCABKAsyEC5jaGFyb24udjEuRW1wdH'
    'lIAFIIcmV0cnlOb3cSMgoKc2V0X2NvbmZpZxgJIAEoCzIRLmNoYXJvbi52MS5Db25maWdIAFIJ'
    'c2V0Q29uZmlnEjEKCmdldF9jb25maWcYCiABKAsyEC5jaGFyb24udjEuRW1wdHlIAFIJZ2V0Q2'
    '9uZmlnEjcKCXN1YnNjcmliZRgLIAEoCzIXLmNoYXJvbi52MS5TdWJzY3JpcHRpb25IAFIJc3Vi'
    'c2NyaWJlEjsKC3Vuc3Vic2NyaWJlGAwgASgLMhcuY2hhcm9uLnYxLlN1YnNjcmlwdGlvbkgAUg'
    't1bnN1YnNjcmliZRI1CgxjaGVja191cGRhdGUYDSABKAsyEC5jaGFyb24udjEuRW1wdHlIAFIL'
    'Y2hlY2tVcGRhdGUSOwoMYXBwbHlfdXBkYXRlGA4gASgLMhYuY2hhcm9uLnYxLkFwcGx5VXBkYX'
    'RlSABSC2FwcGx5VXBkYXRlEjcKDXJvbGxiYWNrX2NvcmUYDyABKAsyEC5jaGFyb24udjEuRW1w'
    'dHlIAFIMcm9sbGJhY2tDb3JlEk0KEmV4cG9ydF9kaWFnbm9zdGljcxgQIAEoCzIcLmNoYXJvbi'
    '52MS5FeHBvcnREaWFnbm9zdGljc0gAUhFleHBvcnREaWFnbm9zdGljcxJIChF1cGRhdGVfZmls'
    'ZV9jaHVuaxgRIAEoCzIaLmNoYXJvbi52MS5VcGRhdGVGaWxlQ2h1bmtIAFIPdXBkYXRlRmlsZU'
    'NodW5rQgYKBGtpbmQ=');

@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = {
  '1': 'Empty',
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor =
    $convert.base64Decode('CgVFbXB0eQ==');

@$core.Deprecated('Use serverRefDescriptor instead')
const ServerRef$json = {
  '1': 'ServerRef',
  '2': [
    {'1': 'server_id', '3': 1, '4': 1, '5': 9, '10': 'serverId'},
  ],
};

/// Descriptor for `ServerRef`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverRefDescriptor = $convert
    .base64Decode('CglTZXJ2ZXJSZWYSGwoJc2VydmVyX2lkGAEgASgJUghzZXJ2ZXJJZA==');

@$core.Deprecated('Use subscriptionDescriptor instead')
const Subscription$json = {
  '1': 'Subscription',
  '2': [
    {
      '1': 'topics',
      '3': 1,
      '4': 3,
      '5': 14,
      '6': '.charon.v1.Topic',
      '10': 'topics'
    },
    {
      '1': 'log_source',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.LogSource',
      '10': 'logSource'
    },
    {
      '1': 'min_level',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.LogLevel',
      '10': 'minLevel'
    },
  ],
};

/// Descriptor for `Subscription`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscriptionDescriptor = $convert.base64Decode(
    'CgxTdWJzY3JpcHRpb24SKAoGdG9waWNzGAEgAygOMhAuY2hhcm9uLnYxLlRvcGljUgZ0b3BpY3'
    'MSMwoKbG9nX3NvdXJjZRgCIAEoDjIULmNoYXJvbi52MS5Mb2dTb3VyY2VSCWxvZ1NvdXJjZRIw'
    'CgltaW5fbGV2ZWwYAyABKA4yEy5jaGFyb24udjEuTG9nTGV2ZWxSCG1pbkxldmVs');

@$core.Deprecated('Use applyUpdateDescriptor instead')
const ApplyUpdate$json = {
  '1': 'ApplyUpdate',
  '2': [
    {
      '1': 'kind',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.UpdateKind',
      '10': 'kind'
    },
    {
      '1': 'when',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.ApplyWhen',
      '10': 'when'
    },
  ],
};

/// Descriptor for `ApplyUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List applyUpdateDescriptor = $convert.base64Decode(
    'CgtBcHBseVVwZGF0ZRIpCgRraW5kGAEgASgOMhUuY2hhcm9uLnYxLlVwZGF0ZUtpbmRSBGtpbm'
    'QSKAoEd2hlbhgCIAEoDjIULmNoYXJvbi52MS5BcHBseVdoZW5SBHdoZW4=');

@$core.Deprecated('Use exportDiagnosticsDescriptor instead')
const ExportDiagnostics$json = {
  '1': 'ExportDiagnostics',
};

/// Descriptor for `ExportDiagnostics`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportDiagnosticsDescriptor =
    $convert.base64Decode('ChFFeHBvcnREaWFnbm9zdGljcw==');

@$core.Deprecated('Use updateFileChunkDescriptor instead')
const UpdateFileChunk$json = {
  '1': 'UpdateFileChunk',
  '2': [
    {
      '1': 'kind',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.UpdateKind',
      '10': 'kind'
    },
    {'1': 'offset', '3': 2, '4': 1, '5': 4, '10': 'offset'},
    {'1': 'data', '3': 3, '4': 1, '5': 12, '10': 'data'},
    {'1': 'last', '3': 4, '4': 1, '5': 8, '10': 'last'},
  ],
};

/// Descriptor for `UpdateFileChunk`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateFileChunkDescriptor = $convert.base64Decode(
    'Cg9VcGRhdGVGaWxlQ2h1bmsSKQoEa2luZBgBIAEoDjIVLmNoYXJvbi52MS5VcGRhdGVLaW5kUg'
    'RraW5kEhYKBm9mZnNldBgCIAEoBFIGb2Zmc2V0EhIKBGRhdGEYAyABKAxSBGRhdGESEgoEbGFz'
    'dBgEIAEoCFIEbGFzdA==');

@$core.Deprecated('Use responseDescriptor instead')
const Response$json = {
  '1': 'Response',
  '2': [
    {
      '1': 'ack',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Empty',
      '9': 0,
      '10': 'ack'
    },
    {
      '1': 'error',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Error',
      '9': 0,
      '10': 'error'
    },
    {
      '1': 'config',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Config',
      '9': 0,
      '10': 'config'
    },
    {
      '1': 'update_state',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.UpdateState',
      '9': 0,
      '10': 'updateState'
    },
    {'1': 'diagnostics', '3': 5, '4': 1, '5': 12, '9': 0, '10': 'diagnostics'},
  ],
  '8': [
    {'1': 'kind'},
  ],
};

/// Descriptor for `Response`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseDescriptor = $convert.base64Decode(
    'CghSZXNwb25zZRIkCgNhY2sYASABKAsyEC5jaGFyb24udjEuRW1wdHlIAFIDYWNrEigKBWVycm'
    '9yGAIgASgLMhAuY2hhcm9uLnYxLkVycm9ySABSBWVycm9yEisKBmNvbmZpZxgDIAEoCzIRLmNo'
    'YXJvbi52MS5Db25maWdIAFIGY29uZmlnEjsKDHVwZGF0ZV9zdGF0ZRgEIAEoCzIWLmNoYXJvbi'
    '52MS5VcGRhdGVTdGF0ZUgAUgt1cGRhdGVTdGF0ZRIiCgtkaWFnbm9zdGljcxgFIAEoDEgAUgtk'
    'aWFnbm9zdGljc0IGCgRraW5k');

@$core.Deprecated('Use errorDescriptor instead')
const Error$json = {
  '1': 'Error',
  '2': [
    {
      '1': 'code',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.ErrorCode',
      '10': 'code'
    },
    {'1': 'message_key', '3': 2, '4': 1, '5': 9, '10': 'messageKey'},
    {'1': 'detail', '3': 3, '4': 1, '5': 9, '10': 'detail'},
    {
      '1': 'fields',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.charon.v1.FieldError',
      '10': 'fields'
    },
  ],
};

/// Descriptor for `Error`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List errorDescriptor = $convert.base64Decode(
    'CgVFcnJvchIoCgRjb2RlGAEgASgOMhQuY2hhcm9uLnYxLkVycm9yQ29kZVIEY29kZRIfCgttZX'
    'NzYWdlX2tleRgCIAEoCVIKbWVzc2FnZUtleRIWCgZkZXRhaWwYAyABKAlSBmRldGFpbBItCgZm'
    'aWVsZHMYBCADKAsyFS5jaGFyb24udjEuRmllbGRFcnJvclIGZmllbGRz');

@$core.Deprecated('Use fieldErrorDescriptor instead')
const FieldError$json = {
  '1': 'FieldError',
  '2': [
    {'1': 'path', '3': 1, '4': 1, '5': 9, '10': 'path'},
    {'1': 'message_key', '3': 2, '4': 1, '5': 9, '10': 'messageKey'},
  ],
};

/// Descriptor for `FieldError`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldErrorDescriptor = $convert.base64Decode(
    'CgpGaWVsZEVycm9yEhIKBHBhdGgYASABKAlSBHBhdGgSHwoLbWVzc2FnZV9rZXkYAiABKAlSCm'
    '1lc3NhZ2VLZXk=');

@$core.Deprecated('Use eventDescriptor instead')
const Event$json = {
  '1': 'Event',
  '2': [
    {
      '1': 'status_changed',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Status',
      '9': 0,
      '10': 'statusChanged'
    },
    {
      '1': 'quota_changed',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Quota',
      '9': 0,
      '10': 'quotaChanged'
    },
    {
      '1': 'notice',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Notice',
      '9': 0,
      '10': 'notice'
    },
    {
      '1': 'logs',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.LogBatch',
      '9': 0,
      '10': 'logs'
    },
    {
      '1': 'throughput',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Throughput',
      '9': 0,
      '10': 'throughput'
    },
    {
      '1': 'update_state',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.UpdateState',
      '9': 0,
      '10': 'updateState'
    },
    {
      '1': 'config_result',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.ConfigResult',
      '9': 0,
      '10': 'configResult'
    },
    {
      '1': 'ping',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Empty',
      '9': 0,
      '10': 'ping'
    },
  ],
  '8': [
    {'1': 'kind'},
  ],
};

/// Descriptor for `Event`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List eventDescriptor = $convert.base64Decode(
    'CgVFdmVudBI6Cg5zdGF0dXNfY2hhbmdlZBgBIAEoCzIRLmNoYXJvbi52MS5TdGF0dXNIAFINc3'
    'RhdHVzQ2hhbmdlZBI3Cg1xdW90YV9jaGFuZ2VkGAIgASgLMhAuY2hhcm9uLnYxLlF1b3RhSABS'
    'DHF1b3RhQ2hhbmdlZBIrCgZub3RpY2UYAyABKAsyES5jaGFyb24udjEuTm90aWNlSABSBm5vdG'
    'ljZRIpCgRsb2dzGAQgASgLMhMuY2hhcm9uLnYxLkxvZ0JhdGNoSABSBGxvZ3MSNwoKdGhyb3Vn'
    'aHB1dBgFIAEoCzIVLmNoYXJvbi52MS5UaHJvdWdocHV0SABSCnRocm91Z2hwdXQSOwoMdXBkYX'
    'RlX3N0YXRlGAYgASgLMhYuY2hhcm9uLnYxLlVwZGF0ZVN0YXRlSABSC3VwZGF0ZVN0YXRlEj4K'
    'DWNvbmZpZ19yZXN1bHQYByABKAsyFy5jaGFyb24udjEuQ29uZmlnUmVzdWx0SABSDGNvbmZpZ1'
    'Jlc3VsdBImCgRwaW5nGAggASgLMhAuY2hhcm9uLnYxLkVtcHR5SABSBHBpbmdCBgoEa2luZA==');

@$core.Deprecated('Use statusDescriptor instead')
const Status$json = {
  '1': 'Status',
  '2': [
    {
      '1': 'phase',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.Phase',
      '10': 'phase'
    },
    {
      '1': 'gate',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.Gate',
      '10': 'gate'
    },
    {'1': 'active_server_id', '3': 3, '4': 1, '5': 9, '10': 'activeServerId'},
    {'1': 'chosen_server_id', '3': 4, '4': 1, '5': 9, '10': 'chosenServerId'},
    {'1': 'on_backup', '3': 5, '4': 1, '5': 8, '10': 'onBackup'},
    {'1': 'attempt', '3': 6, '4': 1, '5': 13, '10': 'attempt'},
    {'1': 'max_attempts', '3': 7, '4': 1, '5': 13, '10': 'maxAttempts'},
    {'1': 'next_try_at_ms', '3': 8, '4': 1, '5': 3, '10': 'nextTryAtMs'},
    {'1': 'service_now_ms', '3': 9, '4': 1, '5': 3, '10': 'serviceNowMs'},
    {
      '1': 'quota_level',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.QuotaLevel',
      '10': 'quotaLevel'
    },
    {
      '1': 'last_failure',
      '3': 11,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.FailureReason',
      '10': 'lastFailure'
    },
    {'1': 'phase_since_ms', '3': 12, '4': 1, '5': 3, '10': 'phaseSinceMs'},
    {'1': 'kill_switch_on', '3': 13, '4': 1, '5': 8, '10': 'killSwitchOn'},
    {'1': 'egress_address', '3': 14, '4': 1, '5': 9, '10': 'egressAddress'},
    {'1': 'latency_ms', '3': 15, '4': 1, '5': 13, '10': 'latencyMs'},
    {'1': 'config_version', '3': 16, '4': 1, '5': 4, '10': 'configVersion'},
    {
      '1': 'probe',
      '3': 17,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.Probe',
      '10': 'probe'
    },
    {
      '1': 'last_end',
      '3': 18,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.SessionEnd',
      '10': 'lastEnd'
    },
  ],
};

/// Descriptor for `Status`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statusDescriptor = $convert.base64Decode(
    'CgZTdGF0dXMSJgoFcGhhc2UYASABKA4yEC5jaGFyb24udjEuUGhhc2VSBXBoYXNlEiMKBGdhdG'
    'UYAiABKA4yDy5jaGFyb24udjEuR2F0ZVIEZ2F0ZRIoChBhY3RpdmVfc2VydmVyX2lkGAMgASgJ'
    'Ug5hY3RpdmVTZXJ2ZXJJZBIoChBjaG9zZW5fc2VydmVyX2lkGAQgASgJUg5jaG9zZW5TZXJ2ZX'
    'JJZBIbCglvbl9iYWNrdXAYBSABKAhSCG9uQmFja3VwEhgKB2F0dGVtcHQYBiABKA1SB2F0dGVt'
    'cHQSIQoMbWF4X2F0dGVtcHRzGAcgASgNUgttYXhBdHRlbXB0cxIjCg5uZXh0X3RyeV9hdF9tcx'
    'gIIAEoA1ILbmV4dFRyeUF0TXMSJAoOc2VydmljZV9ub3dfbXMYCSABKANSDHNlcnZpY2VOb3dN'
    'cxI2CgtxdW90YV9sZXZlbBgKIAEoDjIVLmNoYXJvbi52MS5RdW90YUxldmVsUgpxdW90YUxldm'
    'VsEjsKDGxhc3RfZmFpbHVyZRgLIAEoDjIYLmNoYXJvbi52MS5GYWlsdXJlUmVhc29uUgtsYXN0'
    'RmFpbHVyZRIkCg5waGFzZV9zaW5jZV9tcxgMIAEoA1IMcGhhc2VTaW5jZU1zEiQKDmtpbGxfc3'
    'dpdGNoX29uGA0gASgIUgxraWxsU3dpdGNoT24SJQoOZWdyZXNzX2FkZHJlc3MYDiABKAlSDWVn'
    'cmVzc0FkZHJlc3MSHQoKbGF0ZW5jeV9tcxgPIAEoDVIJbGF0ZW5jeU1zEiUKDmNvbmZpZ192ZX'
    'JzaW9uGBAgASgEUg1jb25maWdWZXJzaW9uEiYKBXByb2JlGBEgASgOMhAuY2hhcm9uLnYxLlBy'
    'b2JlUgVwcm9iZRIwCghsYXN0X2VuZBgSIAEoDjIVLmNoYXJvbi52MS5TZXNzaW9uRW5kUgdsYX'
    'N0RW5k');

@$core.Deprecated('Use quotaDescriptor instead')
const Quota$json = {
  '1': 'Quota',
  '2': [
    {'1': 'server_id', '3': 1, '4': 1, '5': 9, '10': 'serverId'},
    {'1': 'bytes_out', '3': 2, '4': 1, '5': 4, '10': 'bytesOut'},
    {'1': 'bytes_in', '3': 3, '4': 1, '5': 4, '10': 'bytesIn'},
    {'1': 'counted_bytes', '3': 4, '4': 1, '5': 4, '10': 'countedBytes'},
    {
      '1': 'level',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.QuotaLevel',
      '10': 'level'
    },
    {'1': 'period_start_ms', '3': 6, '4': 1, '5': 3, '10': 'periodStartMs'},
    {'1': 'resets_at_ms', '3': 7, '4': 1, '5': 3, '10': 'resetsAtMs'},
  ],
};

/// Descriptor for `Quota`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List quotaDescriptor = $convert.base64Decode(
    'CgVRdW90YRIbCglzZXJ2ZXJfaWQYASABKAlSCHNlcnZlcklkEhsKCWJ5dGVzX291dBgCIAEoBF'
    'IIYnl0ZXNPdXQSGQoIYnl0ZXNfaW4YAyABKARSB2J5dGVzSW4SIwoNY291bnRlZF9ieXRlcxgE'
    'IAEoBFIMY291bnRlZEJ5dGVzEisKBWxldmVsGAUgASgOMhUuY2hhcm9uLnYxLlF1b3RhTGV2ZW'
    'xSBWxldmVsEiYKD3BlcmlvZF9zdGFydF9tcxgGIAEoA1INcGVyaW9kU3RhcnRNcxIgCgxyZXNl'
    'dHNfYXRfbXMYByABKANSCnJlc2V0c0F0TXM=');

@$core.Deprecated('Use noticeDescriptor instead')
const Notice$json = {
  '1': 'Notice',
  '2': [
    {
      '1': 'kind',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.NoticeKind',
      '10': 'kind'
    },
    {'1': 'server_id', '3': 2, '4': 1, '5': 9, '10': 'serverId'},
    {'1': 'at_ms', '3': 3, '4': 1, '5': 3, '10': 'atMs'},
  ],
};

/// Descriptor for `Notice`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List noticeDescriptor = $convert.base64Decode(
    'CgZOb3RpY2USKQoEa2luZBgBIAEoDjIVLmNoYXJvbi52MS5Ob3RpY2VLaW5kUgRraW5kEhsKCX'
    'NlcnZlcl9pZBgCIAEoCVIIc2VydmVySWQSEwoFYXRfbXMYAyABKANSBGF0TXM=');

@$core.Deprecated('Use throughputDescriptor instead')
const Throughput$json = {
  '1': 'Throughput',
  '2': [
    {'1': 'down_bps', '3': 1, '4': 1, '5': 4, '10': 'downBps'},
    {'1': 'up_bps', '3': 2, '4': 1, '5': 4, '10': 'upBps'},
    {'1': 'at_ms', '3': 3, '4': 1, '5': 3, '10': 'atMs'},
  ],
};

/// Descriptor for `Throughput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List throughputDescriptor = $convert.base64Decode(
    'CgpUaHJvdWdocHV0EhkKCGRvd25fYnBzGAEgASgEUgdkb3duQnBzEhUKBnVwX2JwcxgCIAEoBF'
    'IFdXBCcHMSEwoFYXRfbXMYAyABKANSBGF0TXM=');

@$core.Deprecated('Use logLineDescriptor instead')
const LogLine$json = {
  '1': 'LogLine',
  '2': [
    {'1': 'seq', '3': 1, '4': 1, '5': 4, '10': 'seq'},
    {'1': 'at_ms', '3': 2, '4': 1, '5': 3, '10': 'atMs'},
    {
      '1': 'level',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.LogLevel',
      '10': 'level'
    },
    {'1': 'text', '3': 4, '4': 1, '5': 9, '10': 'text'},
  ],
};

/// Descriptor for `LogLine`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logLineDescriptor = $convert.base64Decode(
    'CgdMb2dMaW5lEhAKA3NlcRgBIAEoBFIDc2VxEhMKBWF0X21zGAIgASgDUgRhdE1zEikKBWxldm'
    'VsGAMgASgOMhMuY2hhcm9uLnYxLkxvZ0xldmVsUgVsZXZlbBISCgR0ZXh0GAQgASgJUgR0ZXh0');

@$core.Deprecated('Use logBatchDescriptor instead')
const LogBatch$json = {
  '1': 'LogBatch',
  '2': [
    {
      '1': 'source',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.LogSource',
      '10': 'source'
    },
    {
      '1': 'lines',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.charon.v1.LogLine',
      '10': 'lines'
    },
    {'1': 'dropped', '3': 3, '4': 1, '5': 13, '10': 'dropped'},
  ],
};

/// Descriptor for `LogBatch`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logBatchDescriptor = $convert.base64Decode(
    'CghMb2dCYXRjaBIsCgZzb3VyY2UYASABKA4yFC5jaGFyb24udjEuTG9nU291cmNlUgZzb3VyY2'
    'USKAoFbGluZXMYAiADKAsyEi5jaGFyb24udjEuTG9nTGluZVIFbGluZXMSGAoHZHJvcHBlZBgD'
    'IAEoDVIHZHJvcHBlZA==');

@$core.Deprecated('Use configResultDescriptor instead')
const ConfigResult$json = {
  '1': 'ConfigResult',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 4, '10': 'version'},
    {'1': 'accepted', '3': 2, '4': 1, '5': 8, '10': 'accepted'},
    {'1': 'applies_now', '3': 3, '4': 3, '5': 9, '10': 'appliesNow'},
    {
      '1': 'applies_next_connect',
      '3': 4,
      '4': 3,
      '5': 9,
      '10': 'appliesNextConnect'
    },
    {
      '1': 'error',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Error',
      '10': 'error'
    },
  ],
};

/// Descriptor for `ConfigResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List configResultDescriptor = $convert.base64Decode(
    'CgxDb25maWdSZXN1bHQSGAoHdmVyc2lvbhgBIAEoBFIHdmVyc2lvbhIaCghhY2NlcHRlZBgCIA'
    'EoCFIIYWNjZXB0ZWQSHwoLYXBwbGllc19ub3cYAyADKAlSCmFwcGxpZXNOb3cSMAoUYXBwbGll'
    'c19uZXh0X2Nvbm5lY3QYBCADKAlSEmFwcGxpZXNOZXh0Q29ubmVjdBImCgVlcnJvchgFIAEoCz'
    'IQLmNoYXJvbi52MS5FcnJvclIFZXJyb3I=');

@$core.Deprecated('Use updateStateDescriptor instead')
const UpdateState$json = {
  '1': 'UpdateState',
  '2': [
    {
      '1': 'kind',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.UpdateKind',
      '10': 'kind'
    },
    {
      '1': 'stage',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.UpdateStage',
      '10': 'stage'
    },
    {'1': 'current_version', '3': 3, '4': 1, '5': 9, '10': 'currentVersion'},
    {'1': 'new_version', '3': 4, '4': 1, '5': 9, '10': 'newVersion'},
    {'1': 'size_bytes', '3': 5, '4': 1, '5': 4, '10': 'sizeBytes'},
    {'1': 'progress_percent', '3': 6, '4': 1, '5': 13, '10': 'progressPercent'},
    {'1': 'staged_installer', '3': 7, '4': 1, '5': 9, '10': 'stagedInstaller'},
    {'1': 'failure_key', '3': 8, '4': 1, '5': 9, '10': 'failureKey'},
  ],
};

/// Descriptor for `UpdateState`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateStateDescriptor = $convert.base64Decode(
    'CgtVcGRhdGVTdGF0ZRIpCgRraW5kGAEgASgOMhUuY2hhcm9uLnYxLlVwZGF0ZUtpbmRSBGtpbm'
    'QSLAoFc3RhZ2UYAiABKA4yFi5jaGFyb24udjEuVXBkYXRlU3RhZ2VSBXN0YWdlEicKD2N1cnJl'
    'bnRfdmVyc2lvbhgDIAEoCVIOY3VycmVudFZlcnNpb24SHwoLbmV3X3ZlcnNpb24YBCABKAlSCm'
    '5ld1ZlcnNpb24SHQoKc2l6ZV9ieXRlcxgFIAEoBFIJc2l6ZUJ5dGVzEikKEHByb2dyZXNzX3Bl'
    'cmNlbnQYBiABKA1SD3Byb2dyZXNzUGVyY2VudBIpChBzdGFnZWRfaW5zdGFsbGVyGAcgASgJUg'
    '9zdGFnZWRJbnN0YWxsZXISHwoLZmFpbHVyZV9rZXkYCCABKAlSCmZhaWx1cmVLZXk=');

@$core.Deprecated('Use configDescriptor instead')
const Config$json = {
  '1': 'Config',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 4, '10': 'version'},
    {
      '1': 'servers',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.charon.v1.Server',
      '10': 'servers'
    },
    {'1': 'chosen_server_id', '3': 3, '4': 1, '5': 9, '10': 'chosenServerId'},
    {
      '1': 'settings',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Settings',
      '10': 'settings'
    },
    {
      '1': 'split',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.SplitTunnel',
      '10': 'split'
    },
  ],
};

/// Descriptor for `Config`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List configDescriptor = $convert.base64Decode(
    'CgZDb25maWcSGAoHdmVyc2lvbhgBIAEoBFIHdmVyc2lvbhIrCgdzZXJ2ZXJzGAIgAygLMhEuY2'
    'hhcm9uLnYxLlNlcnZlclIHc2VydmVycxIoChBjaG9zZW5fc2VydmVyX2lkGAMgASgJUg5jaG9z'
    'ZW5TZXJ2ZXJJZBIvCghzZXR0aW5ncxgEIAEoCzITLmNoYXJvbi52MS5TZXR0aW5nc1IIc2V0dG'
    'luZ3MSLAoFc3BsaXQYBSABKAsyFi5jaGFyb24udjEuU3BsaXRUdW5uZWxSBXNwbGl0');

@$core.Deprecated('Use serverDescriptor instead')
const Server$json = {
  '1': 'Server',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
    {
      '1': 'protocol',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.Protocol',
      '10': 'protocol'
    },
    {'1': 'address', '3': 4, '4': 1, '5': 9, '10': 'address'},
    {'1': 'port', '3': 5, '4': 1, '5': 13, '10': 'port'},
    {'1': 'uuid', '3': 6, '4': 1, '5': 9, '10': 'uuid'},
    {'1': 'flow', '3': 7, '4': 1, '5': 9, '10': 'flow'},
    {
      '1': 'reality',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Reality',
      '10': 'reality'
    },
    {'1': 'transport', '3': 9, '4': 1, '5': 9, '10': 'transport'},
    {'1': 'country_code', '3': 10, '4': 1, '5': 9, '10': 'countryCode'},
    {
      '1': 'quota',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.QuotaPlan',
      '10': 'quota'
    },
  ],
};

/// Descriptor for `Server`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverDescriptor = $convert.base64Decode(
    'CgZTZXJ2ZXISDgoCaWQYASABKAlSAmlkEiEKDGRpc3BsYXlfbmFtZRgCIAEoCVILZGlzcGxheU'
    '5hbWUSLwoIcHJvdG9jb2wYAyABKA4yEy5jaGFyb24udjEuUHJvdG9jb2xSCHByb3RvY29sEhgK'
    'B2FkZHJlc3MYBCABKAlSB2FkZHJlc3MSEgoEcG9ydBgFIAEoDVIEcG9ydBISCgR1dWlkGAYgAS'
    'gJUgR1dWlkEhIKBGZsb3cYByABKAlSBGZsb3cSLAoHcmVhbGl0eRgIIAEoCzISLmNoYXJvbi52'
    'MS5SZWFsaXR5UgdyZWFsaXR5EhwKCXRyYW5zcG9ydBgJIAEoCVIJdHJhbnNwb3J0EiEKDGNvdW'
    '50cnlfY29kZRgKIAEoCVILY291bnRyeUNvZGUSKgoFcXVvdGEYCyABKAsyFC5jaGFyb24udjEu'
    'UXVvdGFQbGFuUgVxdW90YQ==');

@$core.Deprecated('Use realityDescriptor instead')
const Reality$json = {
  '1': 'Reality',
  '2': [
    {'1': 'public_key', '3': 1, '4': 1, '5': 9, '10': 'publicKey'},
    {'1': 'short_id', '3': 2, '4': 1, '5': 9, '10': 'shortId'},
    {'1': 'server_name', '3': 3, '4': 1, '5': 9, '10': 'serverName'},
    {'1': 'fingerprint', '3': 4, '4': 1, '5': 9, '10': 'fingerprint'},
  ],
};

/// Descriptor for `Reality`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List realityDescriptor = $convert.base64Decode(
    'CgdSZWFsaXR5Eh0KCnB1YmxpY19rZXkYASABKAlSCXB1YmxpY0tleRIZCghzaG9ydF9pZBgCIA'
    'EoCVIHc2hvcnRJZBIfCgtzZXJ2ZXJfbmFtZRgDIAEoCVIKc2VydmVyTmFtZRIgCgtmaW5nZXJw'
    'cmludBgEIAEoCVILZmluZ2VycHJpbnQ=');

@$core.Deprecated('Use quotaPlanDescriptor instead')
const QuotaPlan$json = {
  '1': 'QuotaPlan',
  '2': [
    {'1': 'cap_gb', '3': 1, '4': 1, '5': 13, '10': 'capGb'},
    {'1': 'billing_day', '3': 2, '4': 1, '5': 13, '10': 'billingDay'},
    {
      '1': 'counts',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.CountsMode',
      '10': 'counts'
    },
  ],
};

/// Descriptor for `QuotaPlan`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List quotaPlanDescriptor = $convert.base64Decode(
    'CglRdW90YVBsYW4SFQoGY2FwX2diGAEgASgNUgVjYXBHYhIfCgtiaWxsaW5nX2RheRgCIAEoDV'
    'IKYmlsbGluZ0RheRItCgZjb3VudHMYAyABKA4yFS5jaGFyb24udjEuQ291bnRzTW9kZVIGY291'
    'bnRz');

@$core.Deprecated('Use settingsDescriptor instead')
const Settings$json = {
  '1': 'Settings',
  '2': [
    {'1': 'kill_switch', '3': 1, '4': 1, '5': 8, '10': 'killSwitch'},
    {'1': 'auto_reconnect', '3': 2, '4': 1, '5': 8, '10': 'autoReconnect'},
    {
      '1': 'allow_local_network',
      '3': 3,
      '4': 1,
      '5': 8,
      '10': 'allowLocalNetwork'
    },
    {'1': 'update_check_off', '3': 4, '4': 1, '5': 8, '10': 'updateCheckOff'},
    {
      '1': 'background_download_off',
      '3': 5,
      '4': 1,
      '5': 8,
      '10': 'backgroundDownloadOff'
    },
    {'1': 'previous_core_off', '3': 6, '4': 1, '5': 8, '10': 'previousCoreOff'},
  ],
};

/// Descriptor for `Settings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List settingsDescriptor = $convert.base64Decode(
    'CghTZXR0aW5ncxIfCgtraWxsX3N3aXRjaBgBIAEoCFIKa2lsbFN3aXRjaBIlCg5hdXRvX3JlY2'
    '9ubmVjdBgCIAEoCFINYXV0b1JlY29ubmVjdBIuChNhbGxvd19sb2NhbF9uZXR3b3JrGAMgASgI'
    'UhFhbGxvd0xvY2FsTmV0d29yaxIoChB1cGRhdGVfY2hlY2tfb2ZmGAQgASgIUg51cGRhdGVDaG'
    'Vja09mZhI2ChdiYWNrZ3JvdW5kX2Rvd25sb2FkX29mZhgFIAEoCFIVYmFja2dyb3VuZERvd25s'
    'b2FkT2ZmEioKEXByZXZpb3VzX2NvcmVfb2ZmGAYgASgIUg9wcmV2aW91c0NvcmVPZmY=');

@$core.Deprecated('Use splitTunnelDescriptor instead')
const SplitTunnel$json = {
  '1': 'SplitTunnel',
  '2': [
    {
      '1': 'mode',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.SplitMode',
      '10': 'mode'
    },
    {
      '1': 'all_except_listed',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.charon.v1.Rule',
      '10': 'allExceptListed'
    },
    {
      '1': 'only_listed',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.charon.v1.Rule',
      '10': 'onlyListed'
    },
  ],
};

/// Descriptor for `SplitTunnel`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List splitTunnelDescriptor = $convert.base64Decode(
    'CgtTcGxpdFR1bm5lbBIoCgRtb2RlGAEgASgOMhQuY2hhcm9uLnYxLlNwbGl0TW9kZVIEbW9kZR'
    'I7ChFhbGxfZXhjZXB0X2xpc3RlZBgCIAMoCzIPLmNoYXJvbi52MS5SdWxlUg9hbGxFeGNlcHRM'
    'aXN0ZWQSMAoLb25seV9saXN0ZWQYAyADKAsyDy5jaGFyb24udjEuUnVsZVIKb25seUxpc3RlZA'
    '==');

@$core.Deprecated('Use ruleDescriptor instead')
const Rule$json = {
  '1': 'Rule',
  '2': [
    {
      '1': 'kind',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.RuleKind',
      '10': 'kind'
    },
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
    {
      '1': 'include_subdomains',
      '3': 3,
      '4': 1,
      '5': 8,
      '10': 'includeSubdomains'
    },
  ],
};

/// Descriptor for `Rule`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ruleDescriptor = $convert.base64Decode(
    'CgRSdWxlEicKBGtpbmQYASABKA4yEy5jaGFyb24udjEuUnVsZUtpbmRSBGtpbmQSFAoFdmFsdW'
    'UYAiABKAlSBXZhbHVlEi0KEmluY2x1ZGVfc3ViZG9tYWlucxgDIAEoCFIRaW5jbHVkZVN1YmRv'
    'bWFpbnM=');

@$core.Deprecated('Use syncPayloadDescriptor instead')
const SyncPayload$json = {
  '1': 'SyncPayload',
  '2': [
    {'1': 'schema_version', '3': 1, '4': 1, '5': 13, '10': 'schemaVersion'},
    {'1': 'revision', '3': 2, '4': 1, '5': 4, '10': 'revision'},
    {'1': 'written_at_ms', '3': 3, '4': 1, '5': 3, '10': 'writtenAtMs'},
    {
      '1': 'writer_device_name',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'writerDeviceName'
    },
    {
      '1': 'config',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.charon.v1.Config',
      '10': 'config'
    },
    {'1': 'ui', '3': 6, '4': 1, '5': 11, '6': '.charon.v1.UiSync', '10': 'ui'},
  ],
};

/// Descriptor for `SyncPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncPayloadDescriptor = $convert.base64Decode(
    'CgtTeW5jUGF5bG9hZBIlCg5zY2hlbWFfdmVyc2lvbhgBIAEoDVINc2NoZW1hVmVyc2lvbhIaCg'
    'hyZXZpc2lvbhgCIAEoBFIIcmV2aXNpb24SIgoNd3JpdHRlbl9hdF9tcxgDIAEoA1ILd3JpdHRl'
    'bkF0TXMSLAoSd3JpdGVyX2RldmljZV9uYW1lGAQgASgJUhB3cml0ZXJEZXZpY2VOYW1lEikKBm'
    'NvbmZpZxgFIAEoCzIRLmNoYXJvbi52MS5Db25maWdSBmNvbmZpZxIhCgJ1aRgGIAEoCzIRLmNo'
    'YXJvbi52MS5VaVN5bmNSAnVp');

@$core.Deprecated('Use uiSyncDescriptor instead')
const UiSync$json = {
  '1': 'UiSync',
  '2': [
    {
      '1': 'theme',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.charon.v1.SyncTheme',
      '10': 'theme'
    },
    {'1': 'language', '3': 2, '4': 1, '5': 9, '10': 'language'},
  ],
};

/// Descriptor for `UiSync`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uiSyncDescriptor = $convert.base64Decode(
    'CgZVaVN5bmMSKgoFdGhlbWUYASABKA4yFC5jaGFyb24udjEuU3luY1RoZW1lUgV0aGVtZRIaCg'
    'hsYW5ndWFnZRgCIAEoCVIIbGFuZ3VhZ2U=');
