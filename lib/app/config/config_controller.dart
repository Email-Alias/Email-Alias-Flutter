import 'package:email_alias/app/config/config.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

final class ConfigController {
  factory ConfigController() => instance;
  ConfigController._();
  static final ConfigController instance = ConfigController._();

  late final Box<Config> _box;

  late final ValueListenable<Box<Config>> configListenable;

  Config? get config => _box.get('main');
  Future<void> saveConfig(final Config config) async {
    await _box.put('main', config);
  }

  Future<void> initialize({required final HiveCipher encryptionCipher}) async {
    _box = await Hive.openBox('config', encryptionCipher: encryptionCipher);
    configListenable = _box.listenable(keys: ['main']);
  }

  Future<void> reset() async {
    await _box.clear();
  }
}
