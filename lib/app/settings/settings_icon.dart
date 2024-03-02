import 'package:email_alias/app/routes.dart';
import 'package:flutter/material.dart';

@immutable
final class SettingsIcon extends StatelessWidget {
  const SettingsIcon({super.key});

  @override
  Widget build(final BuildContext context) =>
    IconButton(
      onPressed: () {
        const SettingsRoute().go(context);
      },
      icon: const Icon(Icons.settings),
    );
}
