# scenarios

Shared scenario files. One format, one source of truth. The same file drives three things: the state machine tests in `core/`, the fake core, and the UI integration tests (see CLAUDE.md section 8).

Status: format and the first scenario set drafted at M0. The list of effect types is provisional until the state machine is written in M1, and may change then. The scenarios are the spec for M1: write the machine until they pass.

## Rules

* Plain JSON, so Go and Dart read it with no extra dependency.
* Fixtures use only documentation addresses (192.0.2.0/24, 198.51.100.0/24, 203.0.113.0/24, 2001:db8::/32) and example.com. Keys and UUIDs are obvious placeholders. No real server, key or user data.
* The `description` is plain words that match the spec. It is what the owner reads to review a scenario, so it must say what should happen and why.
* One file per scenario, named in snake case after the `name` field.

## Shape

```
{
  "name":        short plain name
  "description": what happens and why, in plain words
  "config":      a Config in protobuf JSON form (field names as in charon.proto)
  "saved":       what the service saved before this run (for boot scenarios)
  "steps":       ordered list of steps
}
```

A step:

```
{
  "at_ms":   virtual time of the input, in milliseconds from the start of the run
  "input":   what happens (see below)
  "effects": the effects the machine must return for this input, in order
  "expect":  the state after the step, as a partial Status
}
```

## Time

Time is virtual. The machine never reads a real clock, so a scenario that spans minutes runs instantly. The service clock starts at 0, so `next_try_at_ms` in an `expect` is an absolute virtual time. A timer is not fired by waiting. It appears as an effect (`SetTimer`), and a later step injects the matching input (`TimerFired`) at the right virtual time.

## Input types

User commands, named as in the IPC contract: `Connect`, `Disconnect`, `Cancel`, `SwitchNow`, `MoveTo` and `TrySrv` (both carry `server_id`), `Release`, `RetryNow`.

System events, named as in the state machine document: `ServiceStarted`, `XrayStarted`, `XrayExited`, `TunAdapterLost`, `VerifyOk` (carries `egress_address` and `latency_ms`), `VerifyFailed` (carries `reason`, a `FailureReason` name), `VerifyTimeout`, `TimerFired` (carries `name`), `NetworkChanged`, `SystemResumed`, `SettingsChanged`, `QuotaUpdated` (carries `server_id` and `counted_bytes`, the machine works out the level from the plan).

One input is added here: `XrayStopped`. The state machine document says "on Xray stopped" in the Stopping phase but does not list it as an event.

## Effect types (provisional)

`SetGate` (gate), `StartXray` and `StopXray` (server id), `StartVerify` (server id), `SetTimer` (name and `after_ms`), `CancelTimer` (name), `SaveLastSession` (connected, active server id), `Notify` (notice kind and server id).

Timer names used so far: `retry` (5 s between tries), `verify_timeout` (15 s), `network_debounce` (2 s), `network_ready_wait` (20 s after a wake).

## Expect

`expect` is a partial Status. It uses the field names and enum names of `Status` in `charon.proto`. Only the fields that are listed are checked, so a scenario says only what it cares about.

## Defaults chosen at M0 (to confirm)

The documents do not settle these. Each scenario follows the choice below. If the owner decides differently, change the scenarios first, then the machine.

1. **Attempt counter.** `attempt` is the number of the try the machine is waiting for or running. After an Up session loses Xray it is 1 (nothing has failed yet). After a failed probe or a failed first check on a switch target, that failed check already counts as attempt 1, so the next try is attempt 2. Five tries per server in total either way. After Up again it is 0.
2. **Gate while retrying.** With the kill switch on, the gate is Held for the whole of Retrying, including a retry after boot. The boot matrix text says Armed for that row, but Armed would show an unprotected state with the tunnel down, so Held is used.
3. **Resume and Retry now start at once.** A boot resume and Retry now start Xray immediately, without waiting the 5 seconds. The 5 second wait is only between failed tries.
4. **Wake from sleep.** After `SystemResumed` Charon waits for the network for up to 20 seconds. A `NetworkChanged` in that time cancels the wait and starts the normal 2 second debounce. If the 20 seconds pass with no network event, the probe starts anyway. This second case has no scenario yet.
5. **Xray is stopped after a failed try.** After each failed verification the machine stops Xray before the next try, and restarts it when the retry timer fires.
6. **Notices.** `TRAFFIC_HELD` is sent when the gate becomes Held after an unexpected loss, `RECONNECTED` when a Retrying session is Up again, `MOVED_TO_BACKUP` when failover ends Up on another server.
7. **Quota size.** `cap_gb` is decimal gigabytes (1 GB is 1,000,000,000 bytes), as providers count it. Amber from 80 percent, red at 100 percent.

## Gaps in the documents that no scenario covers yet

* `Disconnect` is allowed in every phase except Idle and Stopping, but the transition table only defines it for Up, Retrying and Blocked.
* `XrayExited` while Retrying or Switching is restarting Xray is not defined.
* `SettingsChanged` has no transitions (for example the kill switch turned on while Up, which should apply at once).
* The wake case where the network never comes back (see default 4).
