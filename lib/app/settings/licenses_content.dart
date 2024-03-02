import 'package:email_alias/app/version.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@immutable
final class LicensesContent extends StatelessWidget {
  const LicensesContent({super.key});

  @override
  Widget build(final BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return LicensePage(
      applicationName: localizations.appName,
      applicationVersion: version,
      applicationIcon: const Icon(
        Icons.email,
        size: 60,
      ),
      applicationLegalese: 'Copyright 2023 - 2024 @ Sven Op de Hipt',
    );
  }
}
