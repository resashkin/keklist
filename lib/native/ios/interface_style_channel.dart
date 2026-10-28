import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Keeps iOS windows on the app theme's brightness, see `AppDelegate.registerInterfaceStyleChannel`.
abstract final class InterfaceStyleChannel {
  static const MethodChannel _channel = MethodChannel('com.sashkyn.keklist/interface_style');
  static Brightness? _lastBrightness;

  static Future<void> sync(Brightness brightness) async {
    if (kIsWeb || !Platform.isIOS || brightness == _lastBrightness) return;
    _lastBrightness = brightness;
    await _channel
        .invokeMethod<void>('setInterfaceStyle', brightness == Brightness.dark ? 'dark' : 'light')
        .catchError((_) {});
  }
}
