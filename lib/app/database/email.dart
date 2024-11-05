import 'package:email_alias/app/config/config_controller.dart';
import 'package:email_alias/app/database/database.dart';
import 'package:email_alias/app/email/add_email_content.dart';
import 'package:email_alias/app/email/api.dart' as api;
import 'package:email_alias/app/email/detail_email_content.dart';
import 'package:email_alias/app/json_converters.dart';
import 'package:floor/floor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_split_view/flutter_split_view.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:toastification/toastification.dart';

part 'email.g.dart';

@entity
@JsonSerializable(fieldRename: FieldRename.snake)
final class Email {
  Email({required this.id, required this.address, required this.privateComment, required this.goto, required this.active});

  factory Email.fromJson(final Map<String, dynamic> json) => _$EmailFromJson(json);

  @primaryKey
  final int id;
  final String address;
  final String? privateComment;
  @StringToSetConverter()
  Set<String> goto;
  @IntToBoolConverter()
  bool active;

  String description({required final AppLocalizations localizations}) => privateComment ?? localizations.noDescription;

  @override
  bool operator ==(final Object other) =>
    other is Email &&
    other.id == id &&
    other.address == address &&
    other.privateComment == privateComment &&
    setEquals(other.goto, goto) &&
    other.active == active;

  @override
  int get hashCode => Object.hash(id, address, privateComment, goto, active);

  Future<void> copyToClipboard({required final AppLocalizations localizations}) async {
    await Clipboard.setData(ClipboardData(text: address));
    toastification.show(
      description: Text(localizations.copiedEmailToClipboard, textAlign: TextAlign.center),
      autoCloseDuration: const Duration(seconds: 2),
      alignment: Alignment.bottomCenter,
    );
  }
}

Future<void> showAddEmailDialog({required final BuildContext context}) async {
  final email = await showDialog<Email>(
    context: context,
    builder: (final _) =>
      const Dialog(
        child: ScaffoldMessenger(
          child: AddEmailContent(),
        ),
      ),
  );
  if (email != null) {
    if (context.mounted) {
      showEmailDetail(context: context, email: email);
    }
  }
}

Future<void> loadEmails() async {
  if (!ConfigController.instance.testMode) {
    var emails = await api.getEmails();
    emails = emails.where((final e) => e.goto.contains(ConfigController.instance.value!.email)).toList();

    final cachedEmails = await emailDatabase.emailDao.getAll();
    for (final email in emails) {
      final firstCached = cachedEmails.where((final e) => e.id == email.id).firstOrNull;
      if (firstCached != null) {
        if (firstCached != email) {
          await emailDatabase.emailDao.updateEmail(email);
        }
      }
      else {
        await emailDatabase.emailDao.insertEmail(email);
      }
    }

    final deleteEmails = cachedEmails.where((final email) => emails.where((final e) => email.id == e.id).isEmpty);
    for (final email in deleteEmails) {
      await emailDatabase.emailDao.deleteEmail(email);
    }
  }
}

void showEmailDetail({
  required final BuildContext context,
  required final Email email,
}) {
  SplitView.of(context).setSide(
    DetailEmailContent(email: email),
  );
}
