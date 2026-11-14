/// Where "Detect city from this device" stands (the three states of the Settings
/// board, plus the moments around them).
enum LocationStatus {
  /// The switch is off: the city is what the user typed.
  off,

  /// Asking the device for its position.
  looking,

  /// A city was found: the field shows it and cannot be typed in.
  found,

  /// Windows location is off for Charon: "no permission, using the city you typed".
  denied,

  /// No position could be had (no sensor, no fix, or this system cannot tell).
  unavailable,
}
