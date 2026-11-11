import 'package:charon/state/home_controller.dart';
import 'package:charon/sync/sync_client.dart';

/// A SyncController that reports the state a test asks for, without a server.
class FakeSync extends SyncController {
  FakeSync(this.fakeState, {this.fakeReason, this.fakeUrl = 'https://sync.example.com'});

  SyncState fakeState;
  SyncErrorReason? fakeReason;
  String fakeUrl;
  int clearErrorCalls = 0;

  @override
  SyncState get state => fakeState;

  @override
  SyncErrorReason? get errorReason => fakeReason;

  @override
  String get serverUrl => fakeUrl;

  @override
  void clearError() {
    clearErrorCalls++;
    fakeState = SyncState.paired;
    fakeReason = null;
    notifyListeners();
  }
}

HomeController controllerWithSync(FakeSync sync) => HomeController(syncController: sync);
