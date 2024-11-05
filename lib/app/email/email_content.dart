import 'dart:async';

import 'package:email_alias/app/config/config_controller.dart';
import 'package:email_alias/app/email/add_email_content.dart';
import 'package:email_alias/app/email/api.dart' as api;
import 'package:email_alias/app/email/email.dart';
import 'package:email_alias/app/routes.dart';
import 'package:email_alias/app/settings/settings_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';

@immutable
final class EmailContent extends StatefulWidget {
  const EmailContent({super.key});

  @override
  State<EmailContent> createState() => _EmailContentState();
}

class _EmailContentState extends State<EmailContent> {
  final _controller = SearchController();

  var _search = '';
  BuildContext? _searchContext;

  @override
  void initState() {
    unawaited(loadEmails());
    _controller.addListener(() {
      setState(() {
        _search = _controller.text;
      });
      _searchContext?.findAncestorStateOfType()?.setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return EmailKeyboardListener(
      child: StreamBuilder(
        stream: emailDatabase.emailDao.getAllStream(),
        builder: (final _, final snapshot) {
          final emails = _filterEmail(snapshot.data ?? []);
          return Scaffold(
            appBar: AppBar(
              title: Text(localizations.emails),
              actions: [
                IconButton(
                  onPressed: () async {
                    await showAddEmailDialog(context: context);
                  },
                  icon: const Icon(Icons.add),
                ),
                const SettingsIcon(),
                IconButton(
                  onPressed: () async {
                    await ConfigController.instance.logout();
                  },
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await loadEmails();
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SearchAnchor.bar(
                      viewHintText: localizations.search,
                      searchController: _controller,
                      suggestionsBuilder: (final context, final controller) {
                        _searchContext = context;
                        return _filterEmail(snapshot.data ?? []).map((final e) => _EmailListTile(
                          email: e,
                          onTap: () {
                            controller.closeView(e.privateComment);
                            setState(() {
                              _search = e.description(localizations: localizations);
                            });
                          },
                        ),);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: emails.length,
                      itemBuilder: (final _, final i) {
                        final email = emails[i];
                        return Dismissible(
                          key: Key(email.id.toString()),
                          direction: DismissDirection.endToStart,
                          background: const ColoredBox(
                            color: Colors.red,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Icon(Icons.delete),
                              ),
                            ),
                          ),
                          confirmDismiss: (final _) async =>
                            showDialog(
                              context: context,
                              builder: (final context) =>
                                AlertDialog(
                                  title: Text(localizations.reallyDeleteEmail),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        context.pop(true);
                                      },
                                      child: Text(localizations.yes),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.pop(false);
                                      },
                                      child: Text(localizations.no),
                                    ),
                                  ],
                                ),
                            ),
                          onDismissed: (final _) async {
                            if (!ConfigController.instance.testMode) {
                              await api.deleteEmail(id: email.id);
                            }
                            await emailDatabase.emailDao.deleteEmail(email);
                          },
                          child: _EmailListTile(
                            email: email,
                            onTap: () {
                              showEmailDetail(
                                context: context,
                                email: email,
                              );
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    await email.copyToClipboard(localizations: localizations);
                                  },
                                  icon: const Icon(Icons.copy),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    email.active = !email.active;
                                    await api.updateEmail(id: email.id, active: email.active);
                                    await emailDatabase.emailDao.updateEmail(email);
                                  },
                                  icon: email.active ? const Icon(Icons.check_box) : const Icon(Icons.check_box_outline_blank),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (final _, final __) => const Divider(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Email> _filterEmail(final Iterable<Email> emails) =>
    (_search.isEmpty ? emails : emails.where((final e) {
      final searchFormatted = _search.toLowerCaseNoSpace();
      final commentFormatted = e.privateComment?.toLowerCaseNoSpace();
      final addressFormatted = e.address.toLowerCaseNoSpace();
      return (commentFormatted != null && commentFormatted.contains(searchFormatted)) || addressFormatted.contains(searchFormatted);
    })).toList()..sort((final email1, final email2) => email1.privateComment!.toLowerCase().compareTo(email2.privateComment!.toLowerCase()));
}

@immutable
final class _EmailListTile extends StatelessWidget {
  const _EmailListTile({required this.email, this.trailing, this.onTap});

  final Email email;
  final Widget? trailing;
  final void Function()? onTap;

  @override
  Widget build(final BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return ListTile(
      title: Text(email.description(localizations: localizations)),
      subtitle: Text(email.address),
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Email>('email', email))
      ..add(ObjectFlagProperty<void Function()?>.has('onTap', onTap));
  }
}

extension _StringLowercaseNoSpace on String {
  String toLowerCaseNoSpace() => toLowerCase().replaceAll(' ', '');
}
