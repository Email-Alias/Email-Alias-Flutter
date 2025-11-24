import 'dart:math';

import 'package:email_alias/app/config/config_controller.dart';
import 'package:email_alias/app/database/email.dart';
import 'package:email_alias/app/email/api.dart' as api;
import 'package:email_alias/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

final _random = Random();

@immutable
final class AddEmailContent extends StatefulWidget {
  const AddEmailContent({super.key});

  @override
  State<AddEmailContent> createState() => _AddEmailContentState();
}

class _AddEmailContentState extends State<AddEmailContent> {
  final _formKey = GlobalKey<FormState>();
  final _config = ConfigController.instance.value!;
  final _emailController = TextEditingController();
  final _descriptionFocusNode = FocusNode();
  final _gotoFocusNode = FocusNode();

  var _alias = '';
  var _description = '';
  var _additionalGoto = '';

  @override
  Widget build(final BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isApple = defaultTargetPlatform == .macOS || defaultTargetPlatform == .iOS;

    return CallbackShortcuts(
      bindings: {
        SingleActivator(.keyR, meta: isApple, control: !isApple, shift: true): _generateRandomEmail,
        SingleActivator(.escape): context.pop,
      },
      child: SizedBox(
        width: 410,
        height: 330,
        child: ClipRRect(
          borderRadius: .circular(20),
          child: Scaffold(
            body: Padding(
              padding: const .all(20),
              child: Form(
                key: _formKey,
                autovalidateMode: .onUserInteraction,
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    Text(
                      localizations.addEmail,
                      style: theme.textTheme.titleLarge,
                    ),
                    TextFormField(
                      autofocus: true,
                      textInputAction: .next,
                      controller: _emailController,
                      decoration: InputDecoration(
                        label: Text(localizations.alias),
                        suffixText: '@${_config.emailDomain}',
                        suffixIcon: IconButton(
                          onPressed: _generateRandomEmail,
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
                      textInputAction: .next,
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
                        _gotoFocusNode.requestFocus();
                      },
                    ),
                    TextFormField(
                      focusNode: _gotoFocusNode,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        label: Text(localizations.additionalGoto),
                      ),
                      onSaved: (final additionalGoto) {
                        if (additionalGoto != null) {
                          _additionalGoto = additionalGoto;
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
      ),
    );
  }

  void _generateRandomEmail() {
    _emailController.text = _random.randomString(length: 20);
    _descriptionFocusNode.requestFocus();
  }

  Future<void> _saveEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final emails = await api.getEmails();
      final address = '$_alias@${_config.emailDomain}';
      if (emails.where((final e) => e.address == address).isNotEmpty) {
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

      final goto = _additionalGoto.split(',').map((final goto) => goto.trim()).toSet()
        ..add(_config.email);

      final int id;
      if (ConfigController.instance.testMode) {
        final emails = Email.hiveBox.values.toList()
        ..sort((final e1, final e2) => e1.id.compareTo(e2.id));
        id = emails.last.id + 1;
      }
      else {
        id = await api.addEmail(
          address: address,
          privateComment: _description,
          goto: goto,
        );
      }

      final email = Email(
        id: id,
        address: address,
        privateComment: _description,
        goto: goto,
        active: true,
      );
      
      await Email.hiveBox.put(email.id, email);

      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        context.pop(email);
        await email.copyToClipboard(localizations: localizations);
      }
    }
  }
}

extension _RandomString on Random {
  String randomString({required final int length}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._';
    return .fromCharCodes(.generate(length, (final _) => chars.codeUnitAt(nextInt(chars.length))));
  }
}
