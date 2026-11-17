import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:keklist/domain/services/phone_web/phone_web_mode.dart';
import 'package:material_ui/material_ui.dart';

/// Keeps stories upright on phones while letting full-screen photos turn. Tablets and the web always rotate.
abstract final class PhoneOrientation {
  static const double _tabletShortestSide = 600.0;

  static int _portraitLocks = 0;
  static int _rotationGrants = 0;

  static bool isPhone(BuildContext context) =>
      !kIsWeb && !kIsPhoneWeb && MediaQuery.sizeOf(context).shortestSide < _tabletShortestSide;

  static void lockPortrait() {
    _portraitLocks++;
    _apply();
  }

  static void unlockPortrait() {
    _portraitLocks--;
    _apply();
  }

  /// Lets the screen turn on top of a portrait lock, as long as the returned callback isn't called.
  static VoidCallback allowRotation() {
    _rotationGrants++;
    _apply();
    return () {
      _rotationGrants--;
      _apply();
    };
  }

  static void _apply() {
    final bool isLocked = _portraitLocks > 0 && _rotationGrants == 0;
    SystemChrome.setPreferredOrientations(isLocked ? const [DeviceOrientation.portraitUp] : const []);
  }
}
