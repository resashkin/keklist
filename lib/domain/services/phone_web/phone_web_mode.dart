import 'package:flutter/foundation.dart';

/// The web build the phone serves to browsers in its Wi-Fi (`--dart-define=KEKLIST_WEB=phone`): data comes from the
/// phone's API instead of the browser's own storage. See `documentation/WEB_VERSION_IMPLEMENTATION.md`.
const bool kIsPhoneWeb = kIsWeb && String.fromEnvironment('KEKLIST_WEB') == 'phone';
