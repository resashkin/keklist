import 'package:keklist/domain/services/analytics/analytics.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/helpers/bloc_utils.dart';
import 'package:keklist/presentation/core/shake/shake_detector.dart';
import 'package:keklist/presentation/core/shake/shake_hint_toast.dart';
import 'package:sensors_plus/sensors_plus.dart';

abstract final class ShakeScreenIds {
  static const String day = 'day';
  static const String settings = 'settings';
  static const String insights = 'insights';
  static const String calendar = 'calendar';
  static const String story = 'story';
  static const String creator = 'creator';
}

mixin ShakeToTweakMixin<W extends StatefulWidget> on State<W> {
  static final Set<String> _hintShownThisLaunch = {};
  static const Duration _hintDelay = Duration(milliseconds: 1200);
  static const Duration _hintVisibleDuration = Duration(seconds: 5);
  // The bottom padding already covers the floating tab bar, so this is just the gap above it.
  static const double _hintBottomSpacing = 8.0;
  static const double _hintSideSpacing = 16.0;

  final ShakeDetector _shakeDetector = ShakeDetector();
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool? _isScreenActive;
  Timer? _hintTimer;
  OverlayEntry? _hintEntry;

  String get shakeScreenId;

  void onShakeToTweak();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hidden IndexedStack tabs only report Visibility.of == false; see-through routes on top only flip isCurrent.
    final bool isActive =
        TickerMode.valuesOf(context).enabled && Visibility.of(context) && (ModalRoute.of(context)?.isCurrent ?? true);
    if (isActive == _isScreenActive) return;
    _isScreenActive = isActive;
    isActive ? _activate() : _deactivate();
  }

  @override
  void dispose() {
    _deactivate();
    super.dispose();
  }

  void requestTweak() {
    _hideHint();
    _hintShownThisLaunch.add(shakeScreenId);
    sendEventToBloc<SettingsBloc>(SettingsMarkShakeDiscovered(screenId: shakeScreenId));
    Haptics.vibrate(HapticsType.medium);
    onShakeToTweak();
  }

  void _activate() {
    Analytics.screenViewed(shakeScreenId);
    _accelerometerSubscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(_onAccelerometerEvent, onError: (_) {});
    if (!_hintShownThisLaunch.contains(shakeScreenId)) {
      _hintTimer = Timer(_hintDelay, _showHintIfUndiscovered);
    }
  }

  void _deactivate() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _hideHint();
  }

  bool get _isFrontmost => mounted && _isScreenActive == true && (ModalRoute.of(context)?.isCurrent ?? true);

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final bool isShake = _shakeDetector.addReading(x: event.x, y: event.y, z: event.z, timestamp: DateTime.now());
    if (isShake && _isFrontmost) requestTweak();
  }

  bool get _isShakeDiscovered {
    final SettingsState state = context.read<SettingsBloc>().state;
    return state is! SettingsDataState || state.settings.shakeDiscoveredScreenIds.contains(shakeScreenId);
  }

  void _showHintIfUndiscovered() {
    // A browser can't be shaken; the title's long press still opens the tweaks there.
    if (kIsWeb || !_isFrontmost || _isShakeDiscovered) return;
    _hintShownThisLaunch.add(shakeScreenId);
    final double bottom = MediaQuery.paddingOf(context).bottom + _hintBottomSpacing;
    _hintEntry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: bottom,
        left: _hintSideSpacing,
        right: _hintSideSpacing,
        child: Center(child: ShakeHintToast(onTap: _hideHint)),
      ),
    );
    Overlay.of(context).insert(_hintEntry!);
    _hintTimer = Timer(_hintVisibleDuration, _hideHint);
  }

  void _hideHint() {
    _hintTimer?.cancel();
    _hintTimer = null;
    _hintEntry?.remove();
    _hintEntry = null;
  }
}
