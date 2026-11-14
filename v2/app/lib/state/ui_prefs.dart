import 'dart:convert';
import 'dart:io';

/// What the window remembers between launches: choices of looks and the two
/// things typed for the Home greeting. UI only data, it never crosses the IPC
/// contract (`charon_ipc_contract.md`) and only theme and language sync.
///
/// Nothing derived from the device position is kept here. The city and the
/// country are saved only when the user typed or kept them.
class UiPrefs {
  const UiPrefs({
    this.theme = 'system',
    this.language = 'system',
    this.greetingName = '',
    this.detectCity = true,
    this.city = '',
    this.countryCode = '',
  });

  /// `system`, `light` or `dark`.
  final String theme;

  /// `system`, `en`, `id` or `zh_Hans`.
  final String language;
  final String greetingName;
  final bool detectCity;
  final String city;
  final String countryCode;

  /// The format of the file, so a later version can read an older one.
  static const format = 1;

  Map<String, Object> toJson() => {
        'format': format,
        'theme': theme,
        'language': language,
        'greetingName': greetingName,
        'detectCity': detectCity,
        'city': city,
        'countryCode': countryCode,
      };

  /// Reads what [toJson] wrote. A field that is missing or of the wrong kind
  /// falls back to its default, so a half written or edited file never breaks
  /// the launch. A format from the future is read as far as it makes sense.
  factory UiPrefs.fromJson(Object? json) {
    if (json is! Map) return const UiPrefs();
    String s(String k, String d, {int max = 80}) {
      final v = json[k];
      return v is String && v.length <= max ? v : d;
    }

    const themes = {'system', 'light', 'dark'};
    const languages = {'system', 'en', 'id', 'zh_Hans'};
    final theme = s('theme', 'system');
    final language = s('language', 'system');
    final d = json['detectCity'];
    return UiPrefs(
      theme: themes.contains(theme) ? theme : 'system',
      language: languages.contains(language) ? language : 'system',
      greetingName: s('greetingName', ''),
      detectCity: d is bool ? d : true,
      city: s('city', ''),
      countryCode: s('countryCode', '', max: 2).toUpperCase(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UiPrefs &&
      other.theme == theme &&
      other.language == language &&
      other.greetingName == greetingName &&
      other.detectCity == detectCity &&
      other.city == city &&
      other.countryCode == countryCode;

  @override
  int get hashCode => Object.hash(theme, language, greetingName, detectCity, city, countryCode);
}

/// Where [UiPrefs] live. An interface, like the Store of the core, so Android
/// can bring its own and a test can use memory.
abstract interface class UiPrefsStore {
  /// The saved prefs, or defaults when there is no file or it is not readable.
  Future<UiPrefs> load();

  Future<void> save(UiPrefs prefs);

  /// Removes everything saved ("Erase all data").
  Future<void> erase();
}

/// One small JSON file in the user's own profile, so it is per Windows user
/// and works before the service answers (the splash needs the theme).
class FileUiPrefsStore implements UiPrefsStore {
  FileUiPrefsStore(this.path);

  /// `%APPDATA%\Charon\ui.json`, or null where there is no such folder.
  static FileUiPrefsStore? windowsDefault() {
    final root = Platform.isWindows ? Platform.environment['APPDATA'] : null;
    if (root == null || root.isEmpty) return null;
    return FileUiPrefsStore('$root${Platform.pathSeparator}Charon${Platform.pathSeparator}ui.json');
  }

  final String path;

  @override
  Future<UiPrefs> load() async {
    try {
      final f = File(path);
      if (!await f.exists()) return const UiPrefs();
      // A file this big is not ours.
      if (await f.length() > 16 * 1024) return const UiPrefs();
      return UiPrefs.fromJson(jsonDecode(await f.readAsString()));
    } catch (_) {
      return const UiPrefs();
    }
  }

  /// Writes to a side file and renames it over the real one, so a crash in the
  /// middle leaves the old file, never half of a new one.
  @override
  Future<void> save(UiPrefs prefs) async {
    final target = File(path);
    final tmp = File('$path.tmp');
    try {
      await target.parent.create(recursive: true);
      await tmp.writeAsString(jsonEncode(prefs.toJson()), flush: true);
      await tmp.rename(path);
    } catch (_) {
      // Remembering is a convenience: a full disk or a locked file must not
      // break the window.
      try {
        if (await tmp.exists()) await tmp.delete();
      } catch (_) {}
    }
  }

  @override
  Future<void> erase() async {
    for (final p in [path, '$path.tmp']) {
      try {
        final f = File(p);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
  }
}
