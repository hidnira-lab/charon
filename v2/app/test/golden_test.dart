// Golden fixtures. Go writes the bytes (core/ipc/golden_test.go, fixtures in
// proto/fixtures/v1). This test builds the same messages in Dart and checks both
// directions: our encoding equals Go's bytes, and Go's bytes decode to our
// message. The list must stay in step with goldenSamples() in the Go test.
import 'dart:io';

import 'package:charon/gen/charon/v1/charon.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';

// An id of 0 means "an event". It is left unset, not set to zero: protobuf for
// Dart writes a field that was explicitly set to its default value, while Go
// leaves it out. Both decode the same, but the bytes would differ.
Envelope env(int id, {Hello? hello, HelloAck? helloAck, Command? command, Response? response, Event? event}) =>
    Envelope(
      protocolVersion: 1,
      requestId: id == 0 ? null : Int64(id),
      hello: hello,
      helloAck: helloAck,
      command: command,
      response: response,
      event: event,
    );

Server server(int i) => Server(
      id: 'SRV-${i.toString().padLeft(2, '0')}',
      displayName: 'Fixture server $i',
      protocol: Protocol.PROTOCOL_VLESS_REALITY,
      address: '192.0.2.$i',
      port: 443,
      uuid: '00000000-0000-0000-0000-${i.toString().padLeft(12, '0')}',
      flow: 'xtls-rprx-vision',
      reality: Reality(
        publicKey: 'FIXTURE_PUBLIC_KEY_NOT_A_REAL_KEY',
        shortId: '0000',
        serverName: 'example.com',
        fingerprint: 'chrome',
      ),
      transport: 'tcp',
      countryCode: 'US',
      quota: QuotaPlan(capGb: 2000, billingDay: 5, counts: CountsMode.COUNTS_OUT_ONLY),
    );

Config config(int version, int n) => Config(
      version: Int64(version),
      servers: [for (var i = 1; i <= n; i++) server(i)],
      chosenServerId: 'SRV-01',
      settings: Settings(killSwitch: true, autoReconnect: true, allowLocalNetwork: true),
      split: SplitTunnel(
        mode: SplitMode.SPLIT_ALL_EXCEPT_LISTED,
        allExceptListed: [
          Rule(kind: RuleKind.RULE_DOMAIN, value: 'example.com', includeSubdomains: true),
          Rule(kind: RuleKind.RULE_CIDR, value: '192.0.2.0/24'),
        ],
      ),
    );

final samples = <String, Envelope>{
  'hello': env(1,
      hello: Hello(minProtocolVersion: 1, maxProtocolVersion: 1, appVersion: '0.1.0', clientKind: 'ui')),
  'hello_ack': env(1,
      helloAck: HelloAck(
        protocolVersion: 1,
        serviceVersion: '0.1.0',
        xrayVersion: '26.3.27',
        configVersion: Int64(3),
        status: Status(
          phase: Phase.PHASE_UP,
          gate: Gate.GATE_ARMED,
          activeServerId: 'SRV-01',
          chosenServerId: 'SRV-01',
          maxAttempts: 5,
          serviceNowMs: Int64(1700000000000),
          quotaLevel: QuotaLevel.QUOTA_NORMAL,
          killSwitchOn: true,
          egressAddress: '192.0.2.1',
          latencyMs: 120,
          configVersion: Int64(3),
        ),
      )),
  'command_connect': env(5, command: Command(connect: Empty())),
  'command_move_to': env(6, command: Command(moveTo: ServerRef(serverId: 'SRV-02'))),
  'response_error': env(5,
      response: Response(
        error: Error(
          code: ErrorCode.ERROR_CONFIG_REJECTED,
          messageKey: 'error.config_rejected',
          fields: [
            FieldError(path: 'servers[0].port', messageKey: 'error.port_range'),
            FieldError(path: 'servers[1].uuid', messageKey: 'error.required'),
          ],
        ),
      )),
  'event_status': env(0,
      event: Event(
        statusChanged: Status(
          phase: Phase.PHASE_RETRYING,
          gate: Gate.GATE_HELD,
          activeServerId: 'SRV-01',
          chosenServerId: 'SRV-01',
          attempt: 2,
          maxAttempts: 5,
          nextTryAtMs: Int64(65000),
          serviceNowMs: Int64(62800),
          lastFailure: FailureReason.FAILURE_NETWORK_CHANGED,
          phaseSinceMs: Int64(62800),
          killSwitchOn: true,
        ),
      )),
  'event_status_waking': env(0,
      event: Event(
        statusChanged: Status(
          phase: Phase.PHASE_VERIFYING,
          gate: Gate.GATE_ARMED,
          activeServerId: 'SRV-01',
          chosenServerId: 'SRV-01',
          maxAttempts: 5,
          serviceNowMs: Int64(1700000000500),
          killSwitchOn: true,
          probe: Probe.PROBE_WAKE,
        ),
      )),
  'event_status_could_not_reach': env(0,
      event: Event(
        statusChanged: Status(
          phase: Phase.PHASE_IDLE,
          gate: Gate.GATE_DISARMED,
          chosenServerId: 'SRV-01',
          maxAttempts: 5,
          serviceNowMs: Int64(1700000003000),
          lastFailure: FailureReason.FAILURE_DNS_NOT_TUNNELLED,
          lastEnd: SessionEnd.SESSION_END_COULD_NOT_REACH,
        ),
      )),
  'event_notice': env(0,
      event: Event(
        notice: Notice(kind: NoticeKind.NOTICE_TRAFFIC_HELD, serverId: 'SRV-01', atMs: Int64(60000)),
      )),
  'config': env(7, response: Response(config: config(2, 2))),
  'config_32_servers': env(8, response: Response(config: config(9, 32))),
};

void main() {
  for (final entry in samples.entries) {
    group(entry.key, () {
      final file = File('../proto/fixtures/v1/${entry.key}.bin');

      test('Dart encodes to the same bytes as Go', () {
        expect(entry.value.writeToBuffer(), file.readAsBytesSync());
      });

      test('Dart decodes the Go bytes to the same message', () {
        expect(Envelope.fromBuffer(file.readAsBytesSync()), entry.value);
      });
    });
  }

  test('every fixture on disk has a sample here, so none goes untested', () {
    final onDisk = Directory('../proto/fixtures/v1')
        .listSync()
        .map((f) => f.uri.pathSegments.last.replaceAll('.bin', ''))
        .toSet();
    expect(onDisk, samples.keys.toSet());
  });
}
