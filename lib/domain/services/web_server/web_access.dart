import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Who may open the web version: the PIN that unlocks it, the browsers that
/// entered it, and the port it is served on.
class WebAccess extends ChangeNotifier {
  WebAccess._(this._prefs, this._now, this._random) {
    final now = _now();
    for (final entry in _prefs.getStringList(_sessionsKey) ?? const []) {
      final [digest, expires] = entry.split(' ');
      final expiry = DateTime.fromMillisecondsSinceEpoch(int.parse(expires));
      if (now.isBefore(expiry)) _sessions[digest] = expiry;
    }
  }

  static const defaultPort = 8643;

  /// Below 1024 only the system may listen.
  static const minPort = 1024;
  static const maxPort = 65535;

  static const maxAttempts = 5;
  static const lockout = Duration(minutes: 5);
  static const sessionLifetime = Duration(days: 30);
  static final pinFormat = RegExp(r'^\d{4,8}$');

  static const _pinKey = 'web.pin';
  static const _portKey = 'web.port';
  static const _sessionsKey = 'web.sessions';

  static Future<WebAccess> load({
    DateTime Function() now = DateTime.now,
    Random? random,
  }) async => WebAccess._(
    await SharedPreferences.getInstance(),
    now,
    random ?? Random.secure(),
  );

  final SharedPreferences _prefs;
  final DateTime Function() _now;
  final Random _random;

  /// Digests of the browsers' session tokens, with when each expires.
  final _sessions = <String, DateTime>{};
  var _failures = 0;
  DateTime? _lockedUntil;

  /// Without a PIN the web version is not served at all.
  bool get hasPin => _prefs.containsKey(_pinKey);

  /// Sets the PIN, or removes it with `null`. Browsers that entered the old
  /// one have to enter the new one.
  Future<void> setPin(String? pin) async {
    if (pin != null && !pinFormat.hasMatch(pin)) {
      throw ArgumentError.value(pin, 'pin', 'Use 4 to 8 digits');
    }
    _sessions.clear();
    _failures = 0;
    _lockedUntil = null;
    await _prefs.remove(_sessionsKey);
    if (pin == null) {
      await _prefs.remove(_pinKey);
    } else {
      final salt = _randomBytes(16);
      await _prefs.setString(
        _pinKey,
        '${base64Encode(salt)} ${base64Encode(_pinDigest(salt, pin))}',
      );
    }
    notifyListeners();
  }

  int get port => _prefs.getInt(_portKey) ?? defaultPort;

  Future<void> setPort(int port) async {
    if (port < minPort || port > maxPort) {
      throw RangeError.range(port, minPort, maxPort, 'port');
    }
    await _prefs.setInt(_portKey, port);
    notifyListeners();
  }

  /// Checks a PIN typed in a browser. After [maxAttempts] wrong ones in a row
  /// every PIN is refused for [lockout].
  PinCheck checkPin(String pin) {
    final now = _now();
    final lockedUntil = _lockedUntil;
    if (lockedUntil != null) {
      if (now.isBefore(lockedUntil)) {
        return PinLocked(lockedUntil.difference(now));
      }
      _lockedUntil = null;
      _failures = 0;
    }
    final stored = _prefs.getString(_pinKey)?.split(' ');
    if (stored != null &&
        _equal(
          _pinDigest(base64Decode(stored[0]), pin),
          base64Decode(stored[1]),
        )) {
      _failures = 0;
      return const PinAccepted();
    }
    if (++_failures >= maxAttempts) {
      _lockedUntil = now.add(lockout);
      return const PinLocked(lockout);
    }
    return PinRejected(maxAttempts - _failures);
  }

  /// Remembers a browser that entered the PIN; returns the token for its
  /// cookie.
  Future<String> openSession() async {
    final token = base64UrlEncode(_randomBytes(32)).replaceAll('=', '');
    final now = _now();
    _sessions
      ..removeWhere((_, expiry) => !now.isBefore(expiry))
      ..[_tokenDigest(token)] = now.add(sessionLifetime);
    await _prefs.setStringList(_sessionsKey, [
      for (final MapEntry(key: digest, value: expiry) in _sessions.entries)
        '$digest ${expiry.millisecondsSinceEpoch}',
    ]);
    return token;
  }

  /// Whether [token] comes from a browser that entered the current PIN within
  /// [sessionLifetime].
  bool hasSession(String? token) {
    if (token == null) return false;
    final expiry = _sessions[_tokenDigest(token)];
    return expiry != null && _now().isBefore(expiry);
  }

  Uint8List _randomBytes(int length) => Uint8List.fromList([
    for (var i = 0; i < length; i++) _random.nextInt(256),
  ]);

  static List<int> _pinDigest(List<int> salt, String pin) =>
      Hmac(sha256, salt).convert(utf8.encode(pin)).bytes;

  static String _tokenDigest(String token) =>
      sha256.convert(utf8.encode(token)).toString();

  /// Compares in the same time wherever the first difference is.
  static bool _equal(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }
}

sealed class PinCheck {
  const PinCheck();
}

final class PinAccepted extends PinCheck {
  const PinAccepted();
}

final class PinRejected extends PinCheck {
  const PinRejected(this.attemptsLeft);

  final int attemptsLeft;
}

final class PinLocked extends PinCheck {
  const PinLocked(this.retryAfter);

  final Duration retryAfter;
}
