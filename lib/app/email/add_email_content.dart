import 'dart:math';

import 'package:email_alias/app/config/config_controller.dart';
import 'package:email_alias/app/email/api.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

final _random = Random();

@immutable
final class AddEmailContent extends StatefulWidget {
  const AddEmailContent({super.key});

  @override
  State<AddEmailContent> createState() => _AddEmailContentState();
}

class _AddEmailContentState extends State<AddEmailContent> {
  final _formKey = GlobalKey<FormState>();
  final _config = ConfigController.instance.config!;
  final _emailController = TextEditingController();
  final _descriptionFocusNode = FocusNode();

  var _alias = '';
  var _description = '';

  @override
  Widget build(final BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SizedBox(
      width: 410,
      height: 330,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    localizations.addEmail,
                    style: theme.textTheme.titleLarge,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    controller: _emailController,
                    decoration: InputDecoration(
                      label: Text(localizations.alias),
                      suffixText: '@${_config.emailDomain}',
                      suffixIcon: IconButton(
                        onPressed: () {
                          _emailController.text = _random.randomString(length: 20);
                        },
                        icon: const Icon(Icons.casino),
                      ),
                    ),
                    validator: (final alias) {
                      if (alias == null || alias.isEmpty) {
                        return localizations.aliasEmpty;
                      }
                      return null;
                    },
                    onSaved: (final alias) {
                      if (alias != null) {
                        _alias = alias;
                      }
                    },
                    onFieldSubmitted: (final _) {
                      _descriptionFocusNode.requestFocus();
                    },
                  ),
                  TextFormField(
                    focusNode: _descriptionFocusNode,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      label: Text(localizations.description),
                    ),
                    validator: (final description) {
                      if (description == null || description.isEmpty) {
                        return localizations.descriptionEmpty;
                      }
                      return null;
                    },
                    onSaved: (final description) {
                      if (description != null) {
                        _description = description;
                      }
                    },
                    onFieldSubmitted: (final _) async {
                      await _saveEmail();
                    },
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () async {
                      await _saveEmail();
                    },
                    child: Text(localizations.add),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final emails = await api.getEmails();
      final email = '$_alias@${_config.emailDomain}';
      if (emails.where((final e) => e.address == email).isNotEmpty) {
        if (mounted) {
          final localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(days: 365),
              content: Text(localizations.emailAlreadyExists),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: localizations.ok,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }

        return;
      }

      await api.addEmail(address: email, goto: _config.email, privateComment: _description);

      if (mounted) {
        context.pop(true);
      }
    }
  }
}

extension _RandomString on Random {
  String randomString({required final int length}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._';
    return String.fromCharCodes(Iterable.generate(length, (final _) => chars.codeUnitAt(nextInt(chars.length))));
  }
}
