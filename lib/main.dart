import 'dart:convert';

import 'package:email_alias/app/app.dart';
import 'package:email_alias/app/config/config.dart';
import 'package:email_alias/app/config/config_controller.dart';
import 'package:email_alias/app/email/email.dart';
import 'package:email_alias/app/settings/settings_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  final encryptionCipher = await _initializeHive();
  await SettingsController.instance.initialize(encryptionCipher: encryptionCipher);
  await ConfigController.instance.initialize(encryptionCipher: encryptionCipher);
  LicenseRegistry.addLicense(() async* {
    final materialIconsLicense = await rootBundle.loadString('licenses/MaterialIconsLicense');
    yield LicenseEntryWithLineBreaks(
      ['Material Icons'],
      materialIconsLicense,
    );
  });
  runApp(const AliasApp());
}

Future<HiveCipher> _initializeHive() async {
  await Hive.initFlutter();
  Hive
    ..registerAdapter(ConfigAdapter())
    ..registerAdapter(EmailAdapter());

  const storage = FlutterSecureStorage();
  final keyString = await storage.read(key: 'hive_key');
  final HiveAesCipher cipher;
  if (keyString != null) {
    final key = base64Decode(keyString);
    cipher = HiveAesCipher(key);
  }
  else {
    final key = Hive.generateSecureKey();
    await storage.write(key: 'hive_key', value: base64Encode(key));
    cipher = HiveAesCipher(key);
  }
  await Hive.openBox<Email>('emails', encryptionCipher: cipher);
  return cipher;
}
