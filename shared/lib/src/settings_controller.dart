import 'dart:async';

import 'package:hive_ce/hive.dart';

abstract class SettingsControllerShared {
  late final Box _settingsBox;
  abstract final List<void Function()> _callbacks;

  int get themeModeRaw {
    return _settingsBox.get('theme') ?? 0;
  }

  Future<void> updateThemeModeRaw(final int themeMode) async {
    await _settingsBox.put('theme', themeMode);
    for (final callback in _callbacks) {
      callback();
    }
  }

  String? get localeRaw {
    final localeString = _settingsBox.get('locale');
    if (localeString == null) {
      return null;
    }
    return localeString;
  }

  Future<void> updateLocaleRaw(final String locale) async {
    await _settingsBox.put('locale', locale);
    for (final callback in _callbacks) {
      callback();
    }
  }

  Future<void> initialize() async {
    _settingsBox = await Hive.openBox('settings');
  }

  Future<void> reset() async {
    await _settingsBox.delete('theme');
    await _settingsBox.delete('locale');
  }
}
