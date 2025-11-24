import 'package:email_alias/app/email/api.dart';
import 'package:email_alias/app/watch_communicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared/shared.dart';

final class ConfigController extends ConfigControllerShared implements ValueListenable<Config?> {
  factory ConfigController() => instance;
  ConfigController._();
  static final ConfigController instance = ConfigController._();

  final List<VoidCallback> _callbacks = [];
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void addListener(final VoidCallback listener) {
    _callbacks.add(listener);
  }

  @override
  void removeListener(final VoidCallback listener) {
    _callbacks.remove(listener);
  }

  Future<void> saveConfig(final Config config) async {
    await configBox.put('email', config.email);
    await configBox.put('apiDomain', config.apiDomain);
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

  Future<void> logout() async {
    await configBox.delete('email');
    await configBox.delete('apiDomain');
    await _secureStorage.delete(key: 'apiKey');
    await Email.hiveBox.deleteAll(Email.hiveBox.keys);
    await WatchCommunicator.shared.updateApplicationContext(context: {'type': 'logout'});
    for (final callback in _callbacks) {
      callback();
    }
  }

  Future<String?> get apiKey async => _secureStorage.read(key: 'apiKey');
}