import 'package:email_alias/app/config/config_controller.dart';
import 'package:email_alias/app/database/email.dart';
import 'package:email_alias/app/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@immutable
final class EmailKeyboardListener extends StatelessWidget {
  const EmailKeyboardListener({required this.child, required this.emailCreatedCallback, super.key});

  final Widget child;
  final void Function(Email?) emailCreatedCallback;

  @override
  Widget build(final BuildContext context) {
    final isApple = defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.iOS;
    return CallbackShortcuts(
      bindings: {
        SingleActivator(LogicalKeyboardKey.keyN, meta: isApple, control: !isApple): () async {
          final email = await showAddEmailDialog(context: context);
          emailCreatedCallback(email);
        },
        SingleActivator(LogicalKeyboardKey.comma, meta: isApple, control: !isApple): () {
          const SettingsRoute().go(context);
        },
        SingleActivator(LogicalKeyboardKey.keyL, meta: isApple, control: !isApple): () async {
          await ConfigController.instance.logout();
        },
        SingleActivator(LogicalKeyboardKey.keyR, meta: isApple, control: !isApple): () async {
          await loadEmails();
        },
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<void Function(Email?)>.has('emailCreatedCallback', emailCreatedCallback));
  }
}
