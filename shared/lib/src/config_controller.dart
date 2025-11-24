import 'package:hive_ce/hive.dart';
import 'package:shared/src/config.dart';

abstract class ConfigControllerShared {
  late final Box configBox;

  Future<void> initialize() async {
    configBox = await Hive.openBox('config');
  }

  Config? get value {
    final email = configBox.get('email');
    final apiDomain = configBox.get('apiDomain');
    if (email != null && apiDomain != null) {
      return Config(email: email, apiDomain: apiDomain, apiKey: '');
    }
    return null;
  }
}
