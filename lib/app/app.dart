import 'package:email_alias/app/routes.dart';
import 'package:email_alias/app/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
        builder: (final _, final data, final __) {
          final (themeMode, locale) = data;
          return MaterialApp.router(
            theme: ThemeData.from(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green,
              ),
            ),
            darkTheme: ThemeData.from(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
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
