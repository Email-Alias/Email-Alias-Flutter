import 'package:email_alias/app/config/config.dart';
import 'package:email_alias/app/database/database.dart';
import 'package:email_alias/app/email/api.dart';
import 'package:email_alias/app/watch_communicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class ConfigController extends ValueListenable<Config?> {
  factory ConfigController() => instance;
  ConfigController._();
  static final ConfigController instance = ConfigController._();

  late final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final List<VoidCallback> _callbacks = [];

  Future<void> saveConfig(final Config config) async {
    await _prefs.setString('email', config.email);
    await _prefs.setString('apiDomain', config.apiDomain);
    await _secureStorage.write(key: 'apiKey', value: config.apiKey);
    await WatchCommunicator.shared.updateApplicationContext(
      context: {
        'type': 'register',
        'domain': config.apiDomain,
        'email': config.email,
        'apiKey': config.apiKey,
      },
    );
    for (final callback in _callbacks) {
      callback();
    }
  }

  bool get testMode => value?.apiDomain == testDomain;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> logout() async {
    await _prefs.remove('email');
    await _prefs.remove('apiDomain');
    await _secureStorage.delete(key: 'apiKey');
    await emailDatabase.emailDao.deleteAll();
    await WatchCommunicator.shared.updateApplicationContext(context: {'type': 'logout'});
    for (final callback in _callbacks) {
      callback();
    }
  }

  @override
  void addListener(final VoidCallback listener) {
    _callbacks.add(listener);
  }

  @override
  void removeListener(final VoidCallback listener) {
    _callbacks.remove(listener);
  }

  Future<String?> get apiKey async => _secureStorage.read(key: 'apiKey');

  @override
  Config? get value {
    final email = _prefs.getString('email');
    final apiDomain = _prefs.getString('apiDomain');
    if (email != null && apiDomain != null) {
      return Config(email: email, apiDomain: apiDomain, apiKey: '');
    }
    return null;
  }
}
