import 'package:email_alias/app/config/config_controller.dart';
import 'package:email_alias/app/database/email.dart';
import 'package:email_alias/app/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

@immutable
final class EmailKeyboardListener extends StatelessWidget {
  const EmailKeyboardListener({required this.child, required this.emailCreatedCallback, super.key});

  final Widget child;
  final void Function(Email?) emailCreatedCallback;

  @override
  Widget build(final BuildContext context) {
    final isApple = defaultTargetPlatform == .macOS || defaultTargetPlatform == .iOS;
    return CallbackShortcuts(
      bindings: {
        SingleActivator(.add, meta: isApple, control: !isApple): () async {
          final email = await showAddEmailDialog(context: context);
          emailCreatedCallback(email);
        },
        SingleActivator(.comma, meta: isApple, control: !isApple): () {
          const SettingsRoute().go(context);
        },
        SingleActivator(.keyL, meta: isApple, control: !isApple): () async {
          await ConfigController.instance.logout();
        },
        SingleActivator(.keyR, meta: isApple, control: !isApple): () async {
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
