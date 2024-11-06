import 'dart:io';

import 'package:email_alias/app/app.dart';
import 'package:email_alias/app/splash_screen.dart';
import 'package:email_alias/initialization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeApp();
    runApp(const AliasApp());
  }
  else {
    runApp(const SplashScreen());
  }
}
