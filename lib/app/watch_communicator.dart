import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

@immutable
final class WatchCommunicator {
  factory WatchCommunicator() => shared;

  const WatchCommunicator._();

  static final shared = WatchCommunicator._();

  Future<void> updateApplicationContext({required final Map<String, Object> context}) async {
    if (Platform.isAndroid) {
      final methodChannel = MethodChannel('com.opdehipt.email_alias/watch');
      await methodChannel.invokeMethod('updateApplicationContext', context);
    }
  }
}
