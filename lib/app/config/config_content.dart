import 'package:email_alias/app/config/config.dart';
import 'package:email_alias/app/config/config_controller.dart';
import 'package:email_alias/app/settings/settings_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@immutable
final class ConfigContent extends StatefulWidget {
  const ConfigContent({super.key});

  @override
  State<ConfigContent> createState() => _ConfigContentState();
}

class _ConfigContentState extends State<ConfigContent> {
  final _formKey = GlobalKey<FormState>();
  final _domainFocusNode = FocusNode();
  final _apiKeyFocusNode = FocusNode();

  var _email = '';
  var _apiDomain = '';
  var _apiKey = '';
  var _showApiKey = false;

  @override
  Widget build(final BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.configuration),
        actions: const [
          SettingsIcon(),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(30),
          children: [
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                label: Text(localizations.email),
              ),
              validator: (final email) {
                if (email == null || email.isEmpty) {
                  return localizations.emailEmpty;
                }
                if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
                  return localizations.emailMalformed;
                }
                return null;
              },
              onSaved: (final email) {
                if (email != null) {
                  _email = email;
                }
              },
              onFieldSubmitted: (final _) {
                _domainFocusNode.requestFocus();
              },
            ),
            TextFormField(
              focusNode: _domainFocusNode,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                label: Text(localizations.apiDomain),
              ),
              validator: (final domain) {
                if (domain == null || domain.isEmpty) {
                  return localizations.domainEmpty;
                }
                if (!RegExp(r'[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(domain)) {
                  return localizations.domainMalformed;
                }
                return null;
              },
              onSaved: (final apiDomain) {
                if (apiDomain != null) {
                  _apiDomain = apiDomain;
                }
              },
              onFieldSubmitted: (final _) {
                _apiKeyFocusNode.requestFocus();
              },
            ),
            TextFormField(
              focusNode: _apiKeyFocusNode,
              textInputAction: TextInputAction.done,
              obscureText: !_showApiKey,
              decoration: InputDecoration(
                label: Text(localizations.apiKey),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _showApiKey = !_showApiKey;
                    });
                  },
                  icon: Icon(_showApiKey ? Icons.visibility_off : Icons.visibility),
                ),
              ),
              validator: (final apiKey) {
                if (apiKey == null || apiKey.isEmpty) {
                  return localizations.apiKeyEmpty;
                }
                return null;
              },
              onSaved: (final apiKey) {
                if (apiKey != null) {
                  _apiKey = apiKey;
                }
              },
              onFieldSubmitted: (final _) async {
                await _saveConfig();
              },
            ),
            const SizedBox(height: 50),
            TextButton(
              onPressed: () async {
                await _saveConfig();
              },
              child: Text(localizations.save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveConfig() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      await ConfigController().saveConfig(
        Config(
          email: _email,
          apiDomain: _apiDomain,
          apiKey: _apiKey,
        ),
      );
    }
  }
}
