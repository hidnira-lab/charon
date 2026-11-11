import '../ui/common/ghost.dart';
import 'service_supervisor.dart';

/// The six states of the Service board.
enum ServiceKind { stopped, starting, startFailed, needsUpdate, installing, running }

/// What the Service screen shows, from what the supervisor knows. It holds no
/// words: the screen picks the copy for the [kind]. Null from [serviceView]
/// means there is no Service screen, the window can talk to the service.
class ServiceView {
  const ServiceView(this.kind, {this.install, this.recovery});

  final ServiceKind kind;

  /// Set while [kind] is [ServiceKind.installing].
  final InstallMode? install;

  /// Set while [kind] is [ServiceKind.running]: how the service came back.
  final Recovery? recovery;

  /// The badge and the progress bar are amber while something is wrong or
  /// being fixed, and blue once the service answers.
  bool get isRunning => kind == ServiceKind.running;

  /// Asleep with a floating z while nothing is being done about it.
  bool get asleep => kind == ServiceKind.stopped || kind == ServiceKind.startFailed || kind == ServiceKind.needsUpdate;

  GhostEyes get eyes => switch (kind) {
        ServiceKind.running => GhostEyes.open,
        ServiceKind.starting || ServiceKind.installing => GhostEyes.half,
        _ => GhostEyes.sleep,
      };

  /// The badge square and the "..." after the line move while it works.
  bool get isWorking => kind == ServiceKind.starting || kind == ServiceKind.installing;

  bool get showsProgress => kind == ServiceKind.installing;

  /// The card about Charon's filters, for the states where the user may be
  /// cut off from the internet and the service cannot lift the filters.
  bool get showsReleaseCard =>
      kind == ServiceKind.stopped || kind == ServiceKind.starting || kind == ServiceKind.startFailed;

  /// "Trying again · every 5 s" under the buttons.
  bool get showsRetryLine => kind == ServiceKind.stopped || kind == ServiceKind.startFailed;
}

/// The Service screen for these facts, in the order the board's prototype
/// moves through them: a confirmation first, then what is running now, then
/// what is wrong.
ServiceView? serviceView({
  required ServiceStatus status,
  required bool starting,
  required bool startFailed,
  InstallMode? installing,
  Recovery? recovered,
}) {
  if (recovered != null) return ServiceView(ServiceKind.running, recovery: recovered);
  if (installing != null) return ServiceView(ServiceKind.installing, install: installing);
  if (starting) return const ServiceView(ServiceKind.starting);
  return switch (status) {
    ServiceStatus.running => null,
    ServiceStatus.needsUpdate => const ServiceView(ServiceKind.needsUpdate),
    ServiceStatus.notRunning => ServiceView(startFailed ? ServiceKind.startFailed : ServiceKind.stopped),
  };
}

extension ServiceViewOf on ServiceSupervisor {
  ServiceView? get view => serviceView(
        status: status,
        starting: isStarting,
        startFailed: startFailed,
        installing: installing,
        recovered: recovered,
      );
}
