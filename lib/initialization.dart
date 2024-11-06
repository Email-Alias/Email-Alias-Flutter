import 'package:email_alias/app/config/config_controller.dart';
import 'package:email_alias/app/database/database.dart';
import 'package:email_alias/app/settings/settings_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

Future<void> initializeApp() async {
  emailDatabase = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
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
