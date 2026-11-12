import 'package:flutter/widgets.dart';

import '../../state/ui_state.dart';
import '../../theme/colors.dart';

/// The text, soft fill and dot colors of a [StateTone] in the current theme.
extension StateToneColors on CharonColors {
  (Color text, Color soft, Color dot) tone(StateTone t) => switch (t) {
        StateTone.connected => (connectedText, connectedSoft, connectedFill),
        StateTone.transition => (transitionText, transitionSoft, transitionFill),
        StateTone.critical => (criticalText, criticalSoft, criticalFill),
        StateTone.idle => (idleText, idleSoft, idleFill),
      };
}
