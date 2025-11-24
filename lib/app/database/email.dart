import 'package:email_alias/app/config/config_controller.dart';
import 'package:email_alias/app/email/add_email_content.dart';
import 'package:email_alias/app/email/api.dart' as api;
import 'package:email_alias/app/email/detail_email_content.dart';
import 'package:email_alias/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_split_view/flutter_split_view.dart';
import 'package:shared/shared.dart';
import 'package:toastification/toastification.dart';

extension EmailUtils on Email {
  String description({
    required final AppLocalizations localizations
  }) => privateComment ?? localizations.noDescription;

  Future<void> copyToClipboard({
    required final AppLocalizations localizations
  }) async {
    await Clipboard.setData(ClipboardData(text: address));
    toastification.show(
      description: Text(
          localizations.copiedEmailToClipboard, textAlign: .center),
      autoCloseDuration: const Duration(seconds: 2),
      alignment: .bottomCenter,
    );
  }

  bool equals(final Email other) =>
    other.id == id &&
    other.address == address &&
    other.privateComment == privateComment &&
    setEquals(other.goto, goto) &&
    other.active == active;
}

Future<Email?> showAddEmailDialog({required final BuildContext context}) async {
  final email = await showDialog<Email>(
    context: context,
    builder: (final _) =>
      const Dialog(
        child: ScaffoldMessenger(
          child: AddEmailContent(),
        ),
      ),
  );
  return email;
}

Future<void> loadEmails() async {
  if (!ConfigController.instance.testMode) {
    var emails = await api.getEmails();
    emails = emails.where((final e) => e.goto.contains(ConfigController.instance.value!.email)).toList();

    final cachedEmails = Email.hiveBox.values;
    for (final email in emails) {
      final firstCached = cachedEmails.where((final e) => e.id == email.id).firstOrNull;
      if (firstCached != null) {
        if (!firstCached.equals(email)) {
          await Email.hiveBox.put(email.id, email);
        }
      }
      else {
        await Email.hiveBox.put(email.id, email);
      }
    }

    final deleteEmails = cachedEmails.where((final email) => emails.where((final e) => email.id == e.id).isEmpty);
    for (final email in deleteEmails) {
      await Email.hiveBox.delete(email.id);
    }
  }
}

void showEmailDetail({
  required final BuildContext context,
  required final Email email,
  required final void Function(Email?) emailCreatedCallback,
}) {
  SplitView.of(context).setSide(
    DetailEmailContent(email: email, emailCreatedCallback: emailCreatedCallback),
  );
}