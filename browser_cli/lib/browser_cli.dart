import 'dart:convert';
import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:path/path.dart';
import 'package:shared/shared.dart';
import 'package:browser_cli/config_controller.dart';
import 'package:browser_cli/settings_controller.dart';

Future<Map<String, dynamic>> getEmails() async {
  final dir = await _getApplicationDocumentsDirectory();
  Hive.init(join(dir.path, 'email_alias', 'hive'));
  Hive.registerAdapters();
  final configController = ConfigController();
  final settingsController = SettingsController();
  await configController.initialize();
  await settingsController.initialize();
  await Email.openBox();

  final initialized = configController.value != null;
  final locale = settingsController.localeRaw ?? Platform.localeName;
  final theme = settingsController.themeModeRaw;
  final emails = Email.hiveBox.values;

  final json = jsonEncode(emails.toList());
  final messagesDe = {
    "copiedToClipboard": "E-Mail in die Zwischenablage kopiert",
    "ok": "OK",
    "register": "Du bist nicht registriert. Bitte registriere dich in der App.",
    "highlightedEmails": "Hervorgehobene E-Mails",
    "remainingEmails": "Restliche E-Mails",
    "unregisteredTitle": "Registrieren",
    "registeredTitle": "E-Mails",
    "licenses": "Lizenzen",
  };
  final messagesEn = {
    "copiedToClipboard": "Copied email to clipboard",
    "ok": "OK",
    "register": "You are unregistered. Please register in the app.",
    "highlightedEmails": "Highlighted emails",
    "remainingEmails": "Remaining emails",
    "unregisteredTitle": "Register",
    "registeredTitle": "Emails",
    "licenses": "Licenses",
  };
  final messages = locale.startsWith('en') ? messagesEn : messagesDe;

  return {
    "messages": messages,
    "colorScheme": theme,
    "isPhone": false,
    "registered": initialized,
    "emails": json
  };
}

Future<Directory> _getApplicationDocumentsDirectory() async {
  final env = Platform.environment;

  if (Platform.isWindows) {
    return Directory('${env['USERPROFILE']}\\Documents');
  } else if (Platform.isLinux) {
    return await _getXdgDocumentsDirectory();
  } else {
    throw UnsupportedError('Unsupported platform');
  }
}

Future<Directory> _getXdgDocumentsDirectory() async {
  final home = Platform.environment['HOME']!;
  final configFile = File('$home/.config/user-dirs.dirs');

  if (!await configFile.exists()) {
    return Directory('$home/Documents');
  }

  final content = await configFile.readAsLines();

  for (final line in content) {
    if (line.startsWith('XDG_DOCUMENTS_DIR')) {
      final match = RegExp(r'XDG_DOCUMENTS_DIR="(.+)"').firstMatch(line);
      if (match != null) {
        var path = match.group(1)!;
        path = path.replaceAll('\$HOME', home);
        return Directory(path);
      }
    }
  }

  return Directory('$home/Documents');
}