import 'package:email_alias/app/config/config_controller.dart';
import 'package:email_alias/app/routes.dart';
import 'package:email_alias/app/settings/settings_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

@immutable
final class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  @override
  Widget build(final BuildContext context) {
    final controller = SettingsController();
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: ValueListenableBuilder(
        valueListenable: controller.settingsListenable,
        builder: (final _, final __, final ___) =>
          Column(
            children: [
              Expanded(
                child: SettingsList(
                  platform: DevicePlatform.android,
                  sections: [
                    SettingsSection(
                      title: Text(localizations.general),
                      tiles: [
                        _LocaleListTile(controller: controller),
                        _ThemeListTile(controller: controller),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await _open(url: Uri.https('github.com', 'svenopdehipt/Email-Alias'));
                      },
                      child: Text(localizations.sourceCode),
                    ),
                    TextButton(
                      onPressed: () {
                        const LicenseRoute().go(context);
                      },
                      child: Text(localizations.license),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }

  Future<void> _open({required final Uri url}) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}

@immutable
final class _LocaleListTile extends AbstractSettingsTile {
  const _LocaleListTile({required this.controller});

  final SettingsController controller;

  @override
  Widget build(final BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SettingsTile.navigation(
      leading: const Icon(Icons.language),
      title: Text(localizations.language),
      value: Text(context.localeToLocalizedString(Localizations.localeOf(context))),
      onPressed: (final _) async {
        final locale = await showDialog<Locale>(
          context: context,
          builder: (final _) =>
            SimpleDialog(
              title: Text(localizations.selectLanguage),
              children: AppLocalizations.supportedLocales.map((final e) =>
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, e);
                  },
                  child: Text(context.localeToLocalizedString(e)),
                ),
              ).toList(),
            ),
        );

        if (locale != null) {
          await controller.updateLocale(locale);
        }
      },
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<SettingsController>('controller', controller));
  }
}

@immutable
final class _ThemeListTile extends AbstractSettingsTile {
  const _ThemeListTile({required this.controller});

  final SettingsController controller;

  @override
  Widget build(final BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SettingsTile.navigation(
      leading: const Icon(Icons.dark_mode),
      title: Text(localizations.theme),
      value: Text(context.themeToLocalizedString(controller.themeMode)),
      onPressed: (final _) async {
        final theme = await showDialog<ThemeMode>(
          context: context,
          builder: (final _) =>
            SimpleDialog(
              title: Text(localizations.selectTheme),
              children: ThemeMode.values.map((final e) =>
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, e);
                  },
                  child: Text(context.themeToLocalizedString(e)),
                ),
              ).toList(),
            ),
        );

        if (theme != null) {
          await controller.updateThemeMode(theme);
        }
      },
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<SettingsController>('controller', controller));
  }
}

extension _Localize on BuildContext {
  String localeToLocalizedString(final Locale locale) {
    final localizations = AppLocalizations.of(this)!;

    return switch(locale.languageCode) {
      'de' => localizations.de,
      'en' => localizations.en,
        _ => throw UnsupportedError("The locale couldn't be parsed"),
    };
  }
  String themeToLocalizedString(final ThemeMode theme) {
    final localizations = AppLocalizations.of(this)!;

    return switch(theme) {
      ThemeMode.light => localizations.light,
      ThemeMode.dark => localizations.dark,
      ThemeMode.system => localizations.system,
    };
  }
}
