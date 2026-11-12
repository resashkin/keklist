import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// ⌘ on Apple platforms, Ctrl elsewhere (Googlebook, Android with a keyboard, web on Windows/Linux).
SingleActivator commandShortcut(LogicalKeyboardKey key) {
  final bool isApple = defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS;
  return SingleActivator(key, meta: isApple, control: !isApple);
}

const List<LogicalKeyboardKey> kTabDigitKeys = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
  LogicalKeyboardKey.digit7,
  LogicalKeyboardKey.digit8,
  LogicalKeyboardKey.digit9,
];
