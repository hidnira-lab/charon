import 'dart:typed_data';

import '../ui/tray/tray_art.dart';
import 'tray_view.dart';

/// A tray menu ready for the host: the items as plain maps, each with the id the
/// host sends back when it is picked, and the items by those ids.
class EncodedTrayMenu {
  const EncodedTrayMenu(this.items, this.byId);

  final List<Map<String, Object?>> items;
  final Map<int, TrayMenuItem> byId;
}

/// Turns the menu of [TrayView] into what the native menu is built from. Ids
/// count from 1 down the menu, submenus included, so they are the same for the
/// same menu.
EncodedTrayMenu encodeTrayMenu(List<TrayMenuItem> menu) {
  final byId = <int, TrayMenuItem>{};
  var next = 1;

  List<Map<String, Object?>> walk(List<TrayMenuItem> items) => [
        for (final item in items)
          if (item.separator)
            {'separator': true}
          else
            () {
              final hasKids = item.children.isNotEmpty;
              final id = hasKids ? 0 : next++;
              if (!hasKids) byId[id] = item;
              return <String, Object?>{
                'id': id,
                'label': item.label,
                'note': item.note,
                // A submenu opens, so it is never greyed. Items without a command
                // (the status line) are greyed, as the board says.
                'enabled': hasKids || (item.enabled && item.command != null),
                'checked': item.checked,
                'bold': item.bold,
                'children': walk(item.children),
              };
            }(),
      ];

  return EncodedTrayMenu(walk(menu), byId);
}

/// The tray icon as BGRA pixels for each size Windows asks for (16 at 100 %, 20,
/// 24 and 32 at higher scaling). The 16 pixel picture is scaled by whole numbers
/// and centred, as the Tray board says, never smoothed.
Map<int, Uint8List> trayIconPixels(TrayIconTone tone, {bool light = false, List<int> sizes = const [16, 20, 24, 32]}) {
  final rows = trayIconRows(tone);
  final palette = trayIconPalette(tone, light: light);
  return {
    for (final n in sizes)
      n: () {
        final scale = n < 16 ? 1 : n ~/ 16;
        final offset = (n - 16 * scale) ~/ 2;
        final out = Uint8List(n * n * 4);
        for (var y = 0; y < 16; y++) {
          for (var x = 0; x < 16; x++) {
            final c = palette[rows[y][x]];
            if (c == null) continue; // '.' and a box that is not drawn stay clear
            final argb = c.toARGB32();
            for (var dy = 0; dy < scale; dy++) {
              for (var dx = 0; dx < scale; dx++) {
                final px = offset + x * scale + dx, py = offset + y * scale + dy;
                if (px < 0 || py < 0 || px >= n || py >= n) continue;
                final i = (py * n + px) * 4;
                out[i] = argb & 0xFF; // B
                out[i + 1] = (argb >> 8) & 0xFF; // G
                out[i + 2] = (argb >> 16) & 0xFF; // R
                out[i + 3] = (argb >> 24) & 0xFF; // A
              }
            }
          }
        }
        return out;
      }(),
  };
}
