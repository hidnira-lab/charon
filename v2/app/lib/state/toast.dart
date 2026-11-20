/// What a toast says. The words come from the ARB files, so the state holds
/// the kind and the values, never a sentence.
enum ToastKind {
  /// "SRV-03 · Singapore added as #3 in failover order".
  serverAdded,

  /// "Saved SRV-02".
  serverSaved,

  /// "Saved · SRV-01 picks it up on the next connect" (the server carries traffic now).
  serverSavedActive,

  /// "SRV-02 · Backup VPS deleted", with Undo.
  serverDeleted,

  /// "Erased · Charon starts fresh".
  erased,

  /// "Unpaired · the server copy stays".
  unpaired,

  /// "Backup saved · keep your passphrase safe".
  vaultBackedUp,

  /// "Restored from file".
  vaultRestored,

  /// "3 apps added", with "rule changes apply on the next connect" while connected.
  appsAdded,

  /// "Rule added", with "applies on the next connect" while connected.
  ruleAdded,

  /// "Rule saved", with "applies on the next connect" while connected.
  ruleSaved,

  /// "Removed 192.0.2.0/24" (the value is in `label`), with Undo.
  ruleRemoved,
}

/// The one toast at the bottom of the window (Dialogs board). A new one replaces
/// the one that is showing.
class ToastMessage {
  const ToastMessage(this.kind, {this.code = '', this.label = '', this.order = 0, this.count = 0, this.nextConnect = false, this.undo});

  final ToastKind kind;

  /// How many things the toast is about (apps added).
  final int count;

  /// Adds "rule changes apply on the next connect": the tunnel is up, so the change waits.
  final bool nextConnect;

  /// The SRV code of the server the toast is about.
  final String code;

  /// "SRV-02 · Backup VPS", or just the code when the server has no name.
  final String label;

  /// Place in the failover order, from 1.
  final int order;

  /// The Undo button. Null means there is no button.
  final Future<void> Function()? undo;

  /// How long it stays: a toast with Undo stays longer, so the button can be reached.
  Duration get lifetime => Duration(seconds: undo == null ? 5 : 8);
}
