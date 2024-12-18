import 'package:email_alias/app/config/config_content.dart';
import 'package:email_alias/app/config/config_controller.dart';
import 'package:email_alias/app/email/email_content.dart';
import 'package:email_alias/app/email/email_placeholder_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_split_view/flutter_split_view.dart';

@immutable
final class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(final BuildContext context) {
    final configController = ConfigController();
    return ValueListenableBuilder(
      valueListenable: configController,
      builder: (final _, final value, final ___) {
        if (value == null) {
          return const ConfigContent();
        }
        return SplitView.material(
          placeholder: EmailPlaceholderContent(),
          child: EmailContent(),
        );
      },
    );
  }
}
