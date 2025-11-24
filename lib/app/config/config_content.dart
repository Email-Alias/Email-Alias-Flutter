import 'package:email_alias/app/config/config_controller.dart';
import 'package:email_alias/app/email/api.dart';
import 'package:email_alias/app/settings/settings_icon.dart';
import 'package:email_alias/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

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
        autovalidateMode: .onUserInteraction,
        child: Padding(
          padding: const .all(30),
          child: Column(
            children: [
              TextFormField(
                keyboardType: .emailAddress,
                textInputAction: .next,
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
                keyboardType: .url,
                textInputAction: .next,
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
                textInputAction: .done,
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
              const Spacer(),
              Text(localizations.or, textAlign: .center),
              const Spacer(),
              TextButton(
                onPressed: _saveTestConfig,
                child: Text(localizations.testTheApp),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveConfig() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      await ConfigController.instance.saveConfig(
        Config(
          email: _email,
          apiDomain: _apiDomain,
          apiKey: _apiKey,
        ),
      );
    }
  }

  Future<void> _saveTestConfig() async {
    await _insertTestEmails();
    await ConfigController.instance.saveConfig(
      Config(
        email: testEmail,
        apiDomain: testDomain,
        apiKey: '',
      ),
    );
  }
  
  Future<void> _insertTestEmails() async {
    await Email.hiveBox.putAll({
      0: Email(id: 0, address: 'vAcd8HJOj6h9Hfq9n8F0@example.com', privateComment: 'Apple', goto: {testEmail}, active: true),
      1: Email(id: 1, address: 'gQo5Nu.H7j774eh3mscM@example.com', privateComment: 'Google', goto: {testEmail}, active: true),
      2: Email(id: 2, address: 'FPOjzL0h86Qq9yTZ8Ix4@example.com', privateComment: 'Netflix', goto: {testEmail}, active: true),
      3: Email(id: 3, address: 'glELoo9GWGnpT0VIZujM@example.com', privateComment: 'GitHub', goto: {testEmail}, active: true),
      4: Email(id: 4, address: 'nI0Ok0Q8x9hNutIiFRAK@example.com', privateComment: 'Facebook', goto: {testEmail}, active: true),
      5: Email(id: 5, address: 'yugS_xb992eLm3jRlk3Z@example.com', privateComment: 'Microsoft', goto: {testEmail}, active: true),
      6: Email(id: 6, address: '11iLJ6HK6jshFzqFOo6P@example.com', privateComment: 'Amazon', goto: {testEmail}, active: true),
    });
  }
}
