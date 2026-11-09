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

import 'package:protobuf/protobuf.dart' as $pb;

class Phase extends $pb.ProtobufEnum {
  static const Phase PHASE_UNSPECIFIED =
      Phase._(0, _omitEnumNames ? '' : 'PHASE_UNSPECIFIED');
  static const Phase PHASE_IDLE =
      Phase._(1, _omitEnumNames ? '' : 'PHASE_IDLE');
  static const Phase PHASE_STARTING =
      Phase._(2, _omitEnumNames ? '' : 'PHASE_STARTING');
  static const Phase PHASE_VERIFYING =
      Phase._(3, _omitEnumNames ? '' : 'PHASE_VERIFYING');
  static const Phase PHASE_UP = Phase._(4, _omitEnumNames ? '' : 'PHASE_UP');
  static const Phase PHASE_RETRYING =
      Phase._(5, _omitEnumNames ? '' : 'PHASE_RETRYING');
  static const Phase PHASE_SWITCHING =
      Phase._(6, _omitEnumNames ? '' : 'PHASE_SWITCHING');
  static const Phase PHASE_STOPPING =
      Phase._(7, _omitEnumNames ? '' : 'PHASE_STOPPING');
  static const Phase PHASE_BLOCKED =
      Phase._(8, _omitEnumNames ? '' : 'PHASE_BLOCKED');

  static const $core.List<Phase> values = <Phase>[
    PHASE_UNSPECIFIED,
    PHASE_IDLE,
    PHASE_STARTING,
    PHASE_VERIFYING,
    PHASE_UP,
    PHASE_RETRYING,
    PHASE_SWITCHING,
    PHASE_STOPPING,
    PHASE_BLOCKED,
  ];

  static final $core.List<Phase?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 8);
  static Phase? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Phase._(super.value, super.name);
}

class Gate extends $pb.ProtobufEnum {
  static const Gate GATE_UNSPECIFIED =
      Gate._(0, _omitEnumNames ? '' : 'GATE_UNSPECIFIED');
  static const Gate GATE_DISARMED =
      Gate._(1, _omitEnumNames ? '' : 'GATE_DISARMED');
  static const Gate GATE_ARMED = Gate._(2, _omitEnumNames ? '' : 'GATE_ARMED');
  static const Gate GATE_HELD = Gate._(3, _omitEnumNames ? '' : 'GATE_HELD');

  static const $core.List<Gate> values = <Gate>[
    GATE_UNSPECIFIED,
    GATE_DISARMED,
    GATE_ARMED,
    GATE_HELD,
  ];

  static final $core.List<Gate?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Gate? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Gate._(super.value, super.name);
}

class QuotaLevel extends $pb.ProtobufEnum {
  static const QuotaLevel QUOTA_UNSPECIFIED =
      QuotaLevel._(0, _omitEnumNames ? '' : 'QUOTA_UNSPECIFIED');
  static const QuotaLevel QUOTA_NORMAL =
      QuotaLevel._(1, _omitEnumNames ? '' : 'QUOTA_NORMAL');
  static const QuotaLevel QUOTA_AMBER =
      QuotaLevel._(2, _omitEnumNames ? '' : 'QUOTA_AMBER');
  static const QuotaLevel QUOTA_RED =
      QuotaLevel._(3, _omitEnumNames ? '' : 'QUOTA_RED');

  static const $core.List<QuotaLevel> values = <QuotaLevel>[
    QUOTA_UNSPECIFIED,
    QUOTA_NORMAL,
    QUOTA_AMBER,
    QUOTA_RED,
  ];

  static final $core.List<QuotaLevel?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static QuotaLevel? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const QuotaLevel._(super.value, super.name);
}

class Protocol extends $pb.ProtobufEnum {
  static const Protocol PROTOCOL_UNSPECIFIED =
      Protocol._(0, _omitEnumNames ? '' : 'PROTOCOL_UNSPECIFIED');
  static const Protocol PROTOCOL_VLESS_REALITY =
      Protocol._(1, _omitEnumNames ? '' : 'PROTOCOL_VLESS_REALITY');

  static const $core.List<Protocol> values = <Protocol>[
    PROTOCOL_UNSPECIFIED,
    PROTOCOL_VLESS_REALITY,
  ];

  static final $core.List<Protocol?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static Protocol? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Protocol._(super.value, super.name);
}

class CountsMode extends $pb.ProtobufEnum {
  static const CountsMode COUNTS_UNSPECIFIED =
      CountsMode._(0, _omitEnumNames ? '' : 'COUNTS_UNSPECIFIED');
  static const CountsMode COUNTS_OUT_ONLY =
      CountsMode._(1, _omitEnumNames ? '' : 'COUNTS_OUT_ONLY');
  static const CountsMode COUNTS_IN_AND_OUT =
      CountsMode._(2, _omitEnumNames ? '' : 'COUNTS_IN_AND_OUT');

  static const $core.List<CountsMode> values = <CountsMode>[
    COUNTS_UNSPECIFIED,
    COUNTS_OUT_ONLY,
    COUNTS_IN_AND_OUT,
  ];

  static final $core.List<CountsMode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static CountsMode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CountsMode._(super.value, super.name);
}

class SplitMode extends $pb.ProtobufEnum {
  static const SplitMode SPLIT_UNSPECIFIED =
      SplitMode._(0, _omitEnumNames ? '' : 'SPLIT_UNSPECIFIED');
  static const SplitMode SPLIT_ALL_EXCEPT_LISTED =
      SplitMode._(1, _omitEnumNames ? '' : 'SPLIT_ALL_EXCEPT_LISTED');
  static const SplitMode SPLIT_ONLY_LISTED =
      SplitMode._(2, _omitEnumNames ? '' : 'SPLIT_ONLY_LISTED');

  static const $core.List<SplitMode> values = <SplitMode>[
    SPLIT_UNSPECIFIED,
    SPLIT_ALL_EXCEPT_LISTED,
    SPLIT_ONLY_LISTED,
  ];

  static final $core.List<SplitMode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static SplitMode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SplitMode._(super.value, super.name);
}

class RuleKind extends $pb.ProtobufEnum {
  static const RuleKind RULE_UNSPECIFIED =
      RuleKind._(0, _omitEnumNames ? '' : 'RULE_UNSPECIFIED');
  static const RuleKind RULE_DOMAIN =
      RuleKind._(1, _omitEnumNames ? '' : 'RULE_DOMAIN');
  static const RuleKind RULE_CIDR =
      RuleKind._(2, _omitEnumNames ? '' : 'RULE_CIDR');
  static const RuleKind RULE_APP =
      RuleKind._(3, _omitEnumNames ? '' : 'RULE_APP');

  static const $core.List<RuleKind> values = <RuleKind>[
    RULE_UNSPECIFIED,
    RULE_DOMAIN,
    RULE_CIDR,
    RULE_APP,
  ];

  static final $core.List<RuleKind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static RuleKind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const RuleKind._(super.value, super.name);
}

class Topic extends $pb.ProtobufEnum {
  static const Topic TOPIC_UNSPECIFIED =
      Topic._(0, _omitEnumNames ? '' : 'TOPIC_UNSPECIFIED');
  static const Topic TOPIC_THROUGHPUT =
      Topic._(1, _omitEnumNames ? '' : 'TOPIC_THROUGHPUT');
  static const Topic TOPIC_LOGS =
      Topic._(2, _omitEnumNames ? '' : 'TOPIC_LOGS');

  static const $core.List<Topic> values = <Topic>[
    TOPIC_UNSPECIFIED,
    TOPIC_THROUGHPUT,
    TOPIC_LOGS,
  ];

  static final $core.List<Topic?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Topic? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Topic._(super.value, super.name);
}

class LogSource extends $pb.ProtobufEnum {
  static const LogSource LOG_SOURCE_UNSPECIFIED =
      LogSource._(0, _omitEnumNames ? '' : 'LOG_SOURCE_UNSPECIFIED');
  static const LogSource LOG_SOURCE_XRAY_ACCESS =
      LogSource._(1, _omitEnumNames ? '' : 'LOG_SOURCE_XRAY_ACCESS');
  static const LogSource LOG_SOURCE_CHARON_CORE =
      LogSource._(2, _omitEnumNames ? '' : 'LOG_SOURCE_CHARON_CORE');

  static const $core.List<LogSource> values = <LogSource>[
    LOG_SOURCE_UNSPECIFIED,
    LOG_SOURCE_XRAY_ACCESS,
    LOG_SOURCE_CHARON_CORE,
  ];

  static final $core.List<LogSource?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static LogSource? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const LogSource._(super.value, super.name);
}

class LogLevel extends $pb.ProtobufEnum {
  static const LogLevel LOG_LEVEL_UNSPECIFIED =
      LogLevel._(0, _omitEnumNames ? '' : 'LOG_LEVEL_UNSPECIFIED');
  static const LogLevel LOG_LEVEL_INFO =
      LogLevel._(1, _omitEnumNames ? '' : 'LOG_LEVEL_INFO');
  static const LogLevel LOG_LEVEL_WARN =
      LogLevel._(2, _omitEnumNames ? '' : 'LOG_LEVEL_WARN');
  static const LogLevel LOG_LEVEL_ERROR =
      LogLevel._(3, _omitEnumNames ? '' : 'LOG_LEVEL_ERROR');

  static const $core.List<LogLevel> values = <LogLevel>[
    LOG_LEVEL_UNSPECIFIED,
    LOG_LEVEL_INFO,
    LOG_LEVEL_WARN,
    LOG_LEVEL_ERROR,
  ];

  static final $core.List<LogLevel?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static LogLevel? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const LogLevel._(super.value, super.name);
}

class UpdateKind extends $pb.ProtobufEnum {
  static const UpdateKind UPDATE_KIND_UNSPECIFIED =
      UpdateKind._(0, _omitEnumNames ? '' : 'UPDATE_KIND_UNSPECIFIED');
  static const UpdateKind UPDATE_KIND_CORE =
      UpdateKind._(1, _omitEnumNames ? '' : 'UPDATE_KIND_CORE');
  static const UpdateKind UPDATE_KIND_APP =
      UpdateKind._(2, _omitEnumNames ? '' : 'UPDATE_KIND_APP');

  static const $core.List<UpdateKind> values = <UpdateKind>[
    UPDATE_KIND_UNSPECIFIED,
    UPDATE_KIND_CORE,
    UPDATE_KIND_APP,
  ];

  static final $core.List<UpdateKind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static UpdateKind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const UpdateKind._(super.value, super.name);
}

class ApplyWhen extends $pb.ProtobufEnum {
  static const ApplyWhen APPLY_UNSPECIFIED =
      ApplyWhen._(0, _omitEnumNames ? '' : 'APPLY_UNSPECIFIED');
  static const ApplyWhen APPLY_NOW =
      ApplyWhen._(1, _omitEnumNames ? '' : 'APPLY_NOW');
  static const ApplyWhen APPLY_WHEN_DISCONNECTED =
      ApplyWhen._(2, _omitEnumNames ? '' : 'APPLY_WHEN_DISCONNECTED');

  static const $core.List<ApplyWhen> values = <ApplyWhen>[
    APPLY_UNSPECIFIED,
    APPLY_NOW,
    APPLY_WHEN_DISCONNECTED,
  ];

  static final $core.List<ApplyWhen?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ApplyWhen? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ApplyWhen._(super.value, super.name);
}

class UpdateStage extends $pb.ProtobufEnum {
  static const UpdateStage UPDATE_STAGE_UNSPECIFIED =
      UpdateStage._(0, _omitEnumNames ? '' : 'UPDATE_STAGE_UNSPECIFIED');
  static const UpdateStage UPDATE_UP_TO_DATE =
      UpdateStage._(1, _omitEnumNames ? '' : 'UPDATE_UP_TO_DATE');
  static const UpdateStage UPDATE_AVAILABLE =
      UpdateStage._(2, _omitEnumNames ? '' : 'UPDATE_AVAILABLE');
  static const UpdateStage UPDATE_DOWNLOADING =
      UpdateStage._(3, _omitEnumNames ? '' : 'UPDATE_DOWNLOADING');
  static const UpdateStage UPDATE_READY =
      UpdateStage._(4, _omitEnumNames ? '' : 'UPDATE_READY');
  static const UpdateStage UPDATE_QUEUED =
      UpdateStage._(5, _omitEnumNames ? '' : 'UPDATE_QUEUED');
  static const UpdateStage UPDATE_APPLYING =
      UpdateStage._(6, _omitEnumNames ? '' : 'UPDATE_APPLYING');
  static const UpdateStage UPDATE_UPDATED =
      UpdateStage._(7, _omitEnumNames ? '' : 'UPDATE_UPDATED');
  static const UpdateStage UPDATE_ROLLED_BACK =
      UpdateStage._(8, _omitEnumNames ? '' : 'UPDATE_ROLLED_BACK');
  static const UpdateStage UPDATE_CANNOT_CHECK =
      UpdateStage._(9, _omitEnumNames ? '' : 'UPDATE_CANNOT_CHECK');

  static const $core.List<UpdateStage> values = <UpdateStage>[
    UPDATE_STAGE_UNSPECIFIED,
    UPDATE_UP_TO_DATE,
    UPDATE_AVAILABLE,
    UPDATE_DOWNLOADING,
    UPDATE_READY,
    UPDATE_QUEUED,
    UPDATE_APPLYING,
    UPDATE_UPDATED,
    UPDATE_ROLLED_BACK,
    UPDATE_CANNOT_CHECK,
  ];

  static final $core.List<UpdateStage?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 9);
  static UpdateStage? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const UpdateStage._(super.value, super.name);
}

class NoticeKind extends $pb.ProtobufEnum {
  static const NoticeKind NOTICE_UNSPECIFIED =
      NoticeKind._(0, _omitEnumNames ? '' : 'NOTICE_UNSPECIFIED');
  static const NoticeKind NOTICE_RECONNECTED =
      NoticeKind._(1, _omitEnumNames ? '' : 'NOTICE_RECONNECTED');
  static const NoticeKind NOTICE_MOVED_TO_BACKUP =
      NoticeKind._(2, _omitEnumNames ? '' : 'NOTICE_MOVED_TO_BACKUP');
  static const NoticeKind NOTICE_TRAFFIC_HELD =
      NoticeKind._(3, _omitEnumNames ? '' : 'NOTICE_TRAFFIC_HELD');
  static const NoticeKind NOTICE_QUOTA_AMBER =
      NoticeKind._(4, _omitEnumNames ? '' : 'NOTICE_QUOTA_AMBER');
  static const NoticeKind NOTICE_QUOTA_CAP =
      NoticeKind._(5, _omitEnumNames ? '' : 'NOTICE_QUOTA_CAP');
  static const NoticeKind NOTICE_TUNNEL_LOST =
      NoticeKind._(6, _omitEnumNames ? '' : 'NOTICE_TUNNEL_LOST');

  static const $core.List<NoticeKind> values = <NoticeKind>[
    NOTICE_UNSPECIFIED,
    NOTICE_RECONNECTED,
    NOTICE_MOVED_TO_BACKUP,
    NOTICE_TRAFFIC_HELD,
    NOTICE_QUOTA_AMBER,
    NOTICE_QUOTA_CAP,
    NOTICE_TUNNEL_LOST,
  ];

  static final $core.List<NoticeKind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static NoticeKind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const NoticeKind._(super.value, super.name);
}

class FailureReason extends $pb.ProtobufEnum {
  static const FailureReason FAILURE_UNSPECIFIED =
      FailureReason._(0, _omitEnumNames ? '' : 'FAILURE_UNSPECIFIED');
  static const FailureReason FAILURE_TCP_TIMEOUT =
      FailureReason._(1, _omitEnumNames ? '' : 'FAILURE_TCP_TIMEOUT');
  static const FailureReason FAILURE_REALITY_HANDSHAKE =
      FailureReason._(2, _omitEnumNames ? '' : 'FAILURE_REALITY_HANDSHAKE');
  static const FailureReason FAILURE_EGRESS_MISMATCH =
      FailureReason._(3, _omitEnumNames ? '' : 'FAILURE_EGRESS_MISMATCH');
  static const FailureReason FAILURE_CONFIG_REJECTED =
      FailureReason._(4, _omitEnumNames ? '' : 'FAILURE_CONFIG_REJECTED');
  static const FailureReason FAILURE_ADAPTER_FAILED =
      FailureReason._(5, _omitEnumNames ? '' : 'FAILURE_ADAPTER_FAILED');
  static const FailureReason FAILURE_PORT_IN_USE =
      FailureReason._(6, _omitEnumNames ? '' : 'FAILURE_PORT_IN_USE');
  static const FailureReason FAILURE_XRAY_EXITED =
      FailureReason._(7, _omitEnumNames ? '' : 'FAILURE_XRAY_EXITED');
  static const FailureReason FAILURE_ADAPTER_LOST =
      FailureReason._(8, _omitEnumNames ? '' : 'FAILURE_ADAPTER_LOST');
  static const FailureReason FAILURE_NETWORK_CHANGED =
      FailureReason._(9, _omitEnumNames ? '' : 'FAILURE_NETWORK_CHANGED');
  static const FailureReason FAILURE_DNS_NOT_TUNNELLED =
      FailureReason._(10, _omitEnumNames ? '' : 'FAILURE_DNS_NOT_TUNNELLED');

  static const $core.List<FailureReason> values = <FailureReason>[
    FAILURE_UNSPECIFIED,
    FAILURE_TCP_TIMEOUT,
    FAILURE_REALITY_HANDSHAKE,
    FAILURE_EGRESS_MISMATCH,
    FAILURE_CONFIG_REJECTED,
    FAILURE_ADAPTER_FAILED,
    FAILURE_PORT_IN_USE,
    FAILURE_XRAY_EXITED,
    FAILURE_ADAPTER_LOST,
    FAILURE_NETWORK_CHANGED,
    FAILURE_DNS_NOT_TUNNELLED,
  ];

  static final $core.List<FailureReason?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 10);
  static FailureReason? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const FailureReason._(super.value, super.name);
}

class Probe extends $pb.ProtobufEnum {
  static const Probe PROBE_UNSPECIFIED =
      Probe._(0, _omitEnumNames ? '' : 'PROBE_UNSPECIFIED');
  static const Probe PROBE_NETWORK_CHANGE =
      Probe._(1, _omitEnumNames ? '' : 'PROBE_NETWORK_CHANGE');
  static const Probe PROBE_WAKE =
      Probe._(2, _omitEnumNames ? '' : 'PROBE_WAKE');

  static const $core.List<Probe> values = <Probe>[
    PROBE_UNSPECIFIED,
    PROBE_NETWORK_CHANGE,
    PROBE_WAKE,
  ];

  static final $core.List<Probe?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Probe? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Probe._(super.value, super.name);
}

class SessionEnd extends $pb.ProtobufEnum {
  static const SessionEnd SESSION_END_UNSPECIFIED =
      SessionEnd._(0, _omitEnumNames ? '' : 'SESSION_END_UNSPECIFIED');
  static const SessionEnd SESSION_END_MANUAL =
      SessionEnd._(1, _omitEnumNames ? '' : 'SESSION_END_MANUAL');
  static const SessionEnd SESSION_END_COULD_NOT_REACH =
      SessionEnd._(2, _omitEnumNames ? '' : 'SESSION_END_COULD_NOT_REACH');
  static const SessionEnd SESSION_END_TUNNEL_LOST =
      SessionEnd._(3, _omitEnumNames ? '' : 'SESSION_END_TUNNEL_LOST');

  static const $core.List<SessionEnd> values = <SessionEnd>[
    SESSION_END_UNSPECIFIED,
    SESSION_END_MANUAL,
    SESSION_END_COULD_NOT_REACH,
    SESSION_END_TUNNEL_LOST,
  ];

  static final $core.List<SessionEnd?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static SessionEnd? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SessionEnd._(super.value, super.name);
}

class ErrorCode extends $pb.ProtobufEnum {
  static const ErrorCode ERROR_UNSPECIFIED =
      ErrorCode._(0, _omitEnumNames ? '' : 'ERROR_UNSPECIFIED');
  static const ErrorCode ERROR_INVALID_ARGUMENT =
      ErrorCode._(1, _omitEnumNames ? '' : 'ERROR_INVALID_ARGUMENT');
  static const ErrorCode ERROR_UNKNOWN_SERVER =
      ErrorCode._(2, _omitEnumNames ? '' : 'ERROR_UNKNOWN_SERVER');
  static const ErrorCode ERROR_NOT_ALLOWED_IN_STATE =
      ErrorCode._(3, _omitEnumNames ? '' : 'ERROR_NOT_ALLOWED_IN_STATE');
  static const ErrorCode ERROR_CONFIG_VERSION_MISMATCH =
      ErrorCode._(4, _omitEnumNames ? '' : 'ERROR_CONFIG_VERSION_MISMATCH');
  static const ErrorCode ERROR_CONFIG_REJECTED =
      ErrorCode._(5, _omitEnumNames ? '' : 'ERROR_CONFIG_REJECTED');
  static const ErrorCode ERROR_UNSUPPORTED =
      ErrorCode._(6, _omitEnumNames ? '' : 'ERROR_UNSUPPORTED');
  static const ErrorCode ERROR_BUSY =
      ErrorCode._(7, _omitEnumNames ? '' : 'ERROR_BUSY');
  static const ErrorCode ERROR_UPDATE_SIGNATURE_INVALID =
      ErrorCode._(8, _omitEnumNames ? '' : 'ERROR_UPDATE_SIGNATURE_INVALID');
  static const ErrorCode ERROR_UPDATE_FAILED =
      ErrorCode._(9, _omitEnumNames ? '' : 'ERROR_UPDATE_FAILED');
  static const ErrorCode ERROR_INTERNAL =
      ErrorCode._(10, _omitEnumNames ? '' : 'ERROR_INTERNAL');

  static const $core.List<ErrorCode> values = <ErrorCode>[
    ERROR_UNSPECIFIED,
    ERROR_INVALID_ARGUMENT,
    ERROR_UNKNOWN_SERVER,
    ERROR_NOT_ALLOWED_IN_STATE,
    ERROR_CONFIG_VERSION_MISMATCH,
    ERROR_CONFIG_REJECTED,
    ERROR_UNSUPPORTED,
    ERROR_BUSY,
    ERROR_UPDATE_SIGNATURE_INVALID,
    ERROR_UPDATE_FAILED,
    ERROR_INTERNAL,
  ];

  static final $core.List<ErrorCode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 10);
  static ErrorCode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ErrorCode._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
