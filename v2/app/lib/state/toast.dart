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
}

/// The one toast at the bottom of the window (Dialogs board). A new one replaces
/// the one that is showing.
class ToastMessage {
  const ToastMessage(this.kind, {this.code = '', this.label = '', this.order = 0, this.undo});

  final ToastKind kind;

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
