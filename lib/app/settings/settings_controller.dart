import 'dart:async';

import 'package:email_alias/app/watch_communicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class SettingsController implements ValueListenable<(ThemeMode, Locale?)> {
  factory SettingsController() => instance;
  SettingsController._();
  static final SettingsController instance = SettingsController._();

  late final SharedPreferences _prefs;
  final List<VoidCallback> _callbacks = [];

  ThemeMode get themeMode {
    final themeString = _prefs.getString('theme');
    if (themeString == null) {
      return ThemeMode.system;
    }
    return _stringToBrightness(themeString);
  }
  Future<void> updateThemeMode(final ThemeMode themeMode) async {
    await _prefs.setString('theme', _brightnessToString(themeMode));
    for (final callback in _callbacks) {
      callback();
    }
  }

  Locale? get locale {
    final localeString = _prefs.getString('locale');
    if (localeString == null) {
      return null;
    }
    return _stringToLocale(localeString);
  }
  Future<void> updateLocale(final Locale locale) async {
    await _prefs.setString('locale', _localeToString(locale));
    await WatchCommunicator.shared.updateApplicationContext(context: {'type': 'settings', 'language': _localeToInt(locale)});
    for (final callback in _callbacks) {
      callback();
    }
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> reset() async {
    await _prefs.remove('theme');
    await _prefs.remove('locale');
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

  int _localeToInt(final Locale locale) =>
    locale.languageCode == 'en' ? 1 : 2;

  Locale _stringToLocale(final String value) =>
    switch (value.split('-')) {
      [final language] => Locale(language),
      [final language, final country] => Locale(language, country),
      [final language, final script, final country] => Locale.fromSubtags(languageCode: language, scriptCode: script, countryCode: country),
      _ => throw UnsupportedError("The locale couldn't be parsed"),
    };

  @override
  void addListener(final VoidCallback listener) {
    _callbacks.add(listener);
  }

  @override
  void removeListener(final VoidCallback listener) {
    _callbacks.remove(listener);
  }

  @override
  (ThemeMode, Locale?) get value => (themeMode, locale);
}
