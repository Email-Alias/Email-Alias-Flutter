import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@immutable
final class EmailPlaceholderContent extends StatelessWidget {
  const EmailPlaceholderContent({super.key});

  @override
  Widget build(final BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.selectEmail),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(localizations.selectEmailBody),
        ),
      ),
    );
  }
}
