import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/analytics/analytics_payloads.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Anonymous usage analytics and remote feature flags through PostHog, see `documentation/ANALYTICS_IMPLEMENTATION.md`.
/// Runs only in release builds of the iOS and Android apps; everywhere else every call does nothing.
abstract final class Analytics {
  static const String _defaultHost = 'https://eu.i.posthog.com';
  static const String aiChatFlag = 'ai-chat';

  static bool _isSetUp = false;
  static bool _isEnabled = false;
  static Map<String, Object>? _tweaks;
  static String? _screen;

  /// The `ai-chat` flag; false until PostHog answers, and while analytics is off.
  static final ValueNotifier<bool> isAiChatFlagOn = ValueNotifier(false);

  static String? get _key => dotenv.maybeGet('POSTHOG_API_KEY');

  static bool get isSupported => kReleaseMode && !kIsWeb && (_key?.isNotEmpty ?? false);

  static Future<void> setUp(KeklistSettings settings) async {
    if (!isSupported || _isSetUp) return;
    final PostHogConfig config = PostHogConfig(
      _key!,
      beforeSend: [(event) => event..properties = _scrubbed(event.properties)],
    );
    config
      ..host = dotenv.maybeGet('POSTHOG_HOST') ?? _defaultHost
      ..personProfiles = PostHogPersonProfiles.never
      ..captureApplicationLifecycleEvents = false
      ..sessionReplay = false
      ..surveys = false
      ..sendFeatureFlagEvent = false
      ..optOut = !settings.isAnalyticsEnabled
      ..onFeatureFlags = _readFlags;
    config.rageClickConfig.enabled = false;
    config.errorTrackingConfig
      ..captureFlutterErrors = true
      ..capturePlatformDispatcherErrors = true
      ..inAppIncludes.add('keklist');
    await Posthog().setup(config);
    _isSetUp = true;
    _isEnabled = settings.isAnalyticsEnabled;
    _tweaks = analyticsTweaksOf(settings);
    if (_isEnabled) _capture('app_opened', {..._tweaks!});
  }

  static Future<void> setEnabled(bool isEnabled) async {
    if (!_isSetUp || isEnabled == _isEnabled) return;
    _isEnabled = isEnabled;
    if (isEnabled) {
      await Posthog().optIn();
      await Posthog().reloadFeatureFlags();
    } else {
      await Posthog().optOut();
      isAiChatFlagOn.value = false;
    }
  }

  /// A new random id: later events can't be linked to earlier ones.
  static Future<void> resetId() async {
    if (_isSetUp) await Posthog().reset();
  }

  /// Sends `tweak_changed` for every tweak that differs from the last settings seen.
  static void settingsChanged(KeklistSettings settings) {
    final Map<String, Object> current = analyticsTweaksOf(settings);
    final Map<String, Object>? previous = _tweaks;
    _tweaks = current;
    if (previous == null) return;
    for (final MapEntry<String, Object> tweak in changedTweaks(previous, current).entries) {
      _capture('tweak_changed', {'key': tweak.key, 'value': tweak.value, 'screen': ?_screen});
    }
  }

  static void screenViewed(String name) {
    if (name == _screen) return;
    _screen = name;
    if (_isSetUp && _isEnabled) Posthog().screen(screenName: name);
  }

  static void paywallShown({required bool tipsOnly}) => _capture('paywall_shown', {'tips_only': tipsOnly});

  static void tipPurchased(String productId) => _capture('tip_purchased', {'product_id': productId});

  static void proPurchased(String productId) => _capture('pro_purchased', {'product_id': productId});

  static void _capture(String event, Map<String, Object> properties) {
    if (_isSetUp && _isEnabled) Posthog().capture(eventName: event, properties: properties);
  }

  static Future<void> _readFlags() async {
    isAiChatFlagOn.value = _isEnabled && await Posthog().getFeatureFlag(aiChatFlag) == true;
  }

  static Map<String, Object>? _scrubbed(Map<String, Object>? properties) =>
      properties == null ? null : withoutExceptionMessages(properties);
}
