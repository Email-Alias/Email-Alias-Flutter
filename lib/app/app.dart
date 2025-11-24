import 'package:email_alias/app/routes.dart';
import 'package:email_alias/app/settings/settings_controller.dart';
import 'package:email_alias/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

final _router = GoRouter(routes: $appRoutes);

@immutable
final class AliasApp extends StatelessWidget {
  const AliasApp({super.key});

  @override
  Widget build(final BuildContext context) {
    final controller = SettingsController();
    return ToastificationWrapper(
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (final _, final data, final _) {
          final (themeMode, locale) = data;
          return MaterialApp.router(
            theme: .from(
              colorScheme: .fromSeed(
                seedColor: Colors.green,
              ),
            ),
            darkTheme: .from(
              colorScheme: .fromSeed(
                seedColor: Colors.blue,
                brightness: .dark,
              ),
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,
            themeMode: themeMode,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
