import 'dart:io';

/// Every scenario file in v2/scenarios, in name order. Tests run from v2/app.
List<File> scenarioFiles() => Directory('../scenarios')
    .listSync()
    .whereType<File>()
    .where((f) => f.path.endsWith('.json'))
    .toList()
  ..sort((a, b) => a.path.compareTo(b.path));
