import 'dart:io';

import 'package:flutter/services.dart';

import 'package:keklist/domain/services/web_server/name_announcer.dart';

/// The iPhone's own Bonjour name, like "Romans-iPhone.local", which iOS
/// publishes while the app advertises the web version as a Bonjour service
/// (ios/Runner/BonjourPlugin.swift).
class BonjourAnnouncer implements NameAnnouncer {
  static const channel = MethodChannel('keklist/bonjour');

  @override
  String? problem;

  @override
  Future<String?> announce({
    required InternetAddress address,
    required int port,
  }) async {
    try {
      final name = await channel.invokeMethod<String>('advertise', {
        'port': port,
      });
      problem = null;
      return name;
    } on PlatformException catch (error) {
      problem = error.code == 'denied'
          ? 'To open it by name, allow Local Network for keklist in '
                'Settings → Privacy & Security → Local Network.'
          : null;
      return null;
    }
  }

  @override
  Future<void> withdraw() async {
    try {
      await channel.invokeMethod<void>('withdraw');
    } on PlatformException {
      // Nothing published.
    }
  }
}
