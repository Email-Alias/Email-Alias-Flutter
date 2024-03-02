import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

final class SettingsController {
  factory SettingsController() => instance;
  SettingsController._();
  static final SettingsController instance = SettingsController._();

  late final Box _box;

  late final ValueListenable<Box> settingsListenable;

  ThemeMode get themeMode {
    final String? themeString = _box.get('theme');
    if (themeString == null) {
      return ThemeMode.system;
    }
    return _stringToBrightness(themeString);
  }
  Future<void> updateThemeMode(final ThemeMode themeMode) async {
    await _box.put('theme', _brightnessToString(themeMode));
  }

  Locale? get locale {
    final String? localeString = _box.get('locale');
    if (localeString == null) {
      return null;
    }
    return _stringToLocale(localeString);
  }
  Future<void> updateLocale(final Locale locale) async {
    await _box.put('locale', _localeToString(locale));
  }

  Future<void> initialize({required final HiveCipher encryptionCipher}) async {
    _box = await Hive.openBox('settings', encryptionCipher: encryptionCipher);
    settingsListenable = _box.listenable();
  }

  Future<void> reset() async {
    await _box.clear();
  }

  String _brightnessToString(final ThemeMode themeMode) =>
    switch(themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

  ThemeMode _stringToBrightness(final String value) =>
    switch(value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => throw UnsupportedError("The theme mode doesn't exist"),
    };

  String _localeToString(final Locale locale) =>
    locale.toLanguageTag();

  Locale _stringToLocale(final String value) =>
    switch (value.split('-')) {
      [final language] => Locale(language),
      [final language, final country] => Locale(language, country),
      [final language, final script, final country] => Locale.fromSubtags(languageCode: language, scriptCode: script, countryCode: country),
      _ => throw UnsupportedError("The locale couldn't be parsed"),
    };
}
