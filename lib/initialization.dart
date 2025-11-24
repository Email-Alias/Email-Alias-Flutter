import 'package:email_alias/app/config/config_controller.dart';
import 'package:email_alias/app/settings/settings_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';
import 'package:path/path.dart';

Future<void> _initializeHive() async {
  await Hive.initFlutter(join('email_alias', 'hive'));
  Hive.registerAdapters();
  await Email.openBox();
}

Future<void> initializeApp() async {
  await _initializeHive();
  await SettingsController.instance.initialize();
  await ConfigController.instance.initialize();
  LicenseRegistry.addLicense(() async* {
    final materialIconsLicense = await rootBundle.loadString('licenses/MaterialIconsLicense');
    yield LicenseEntryWithLineBreaks(
      ['Material Icons'],
      materialIconsLicense,
    );
  });
}
