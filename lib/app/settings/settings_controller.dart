import 'dart:async';

import 'package:email_alias/app/watch_communicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

final class SettingsController extends SettingsControllerShared implements ValueListenable<(ThemeMode, Locale?)> {
  factory SettingsController() => instance;
  SettingsController._();
  static final SettingsController instance = SettingsController._();

  final List<VoidCallback> _callbacks = [];

  ThemeMode get themeMode => intToBrightness(themeModeRaw);
  Locale? get locale {
    final val = localeRaw;
    return val != null ? _stringToLocale(val) : null;
  }

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

  Future<void> updateLocale(final Locale locale) async {
    await WatchCommunicator.shared.updateApplicationContext(context: {'type': 'settings', 'language': localeToInt(locale)});
    await updateLocaleRaw(_localeToString(locale));
  }

  Future<void> updateThemeMode(final ThemeMode themeMode) async {
    await updateThemeModeRaw(_brightnessToInt(themeMode));
  }

  int _brightnessToInt(final ThemeMode themeMode) =>
    switch(themeMode) {
      ThemeMode.system => 0,
      ThemeMode.light => 1,
      ThemeMode.dark => 2,
    };

  static ThemeMode intToBrightness(final int value) =>
    switch(value) {
      0 => ThemeMode.system,
      1 => ThemeMode.light,
      2 => ThemeMode.dark,
      _ => throw UnsupportedError("The theme mode doesn't exist"),
    };

  int localeToInt(final Locale locale) => locale.languageCode == 'en' ? 1 : 2;

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
