import 'package:email_alias/app/app.dart';
import 'package:email_alias/initialization.dart';
import 'package:email_alias/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static final _future = initializeApp();

  @override
  Widget build(final BuildContext context) => FutureBuilder(
    future: _future,
    builder: (final _, final snapshot) {
      if (snapshot.connectionState == .done && !snapshot.hasError) {
        return const AliasApp();
      }
      return MaterialApp(
        darkTheme: .dark(),
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: .min,
              children: [
                const Icon(
                  Icons.mail,
                  size: 200,
                ),
                Text(
                  lookupAppLocalizations(PlatformDispatcher.instance.locale).appName,
                  style: TextStyle(fontSize: 34),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
