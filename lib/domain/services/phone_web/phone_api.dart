import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:keklist/domain/services/phone_web/browser_bridge.dart';
import 'package:keklist/domain/services/phone_web/browser_bridge_stub.dart'
    if (dart.library.js_interop) 'package:keklist/domain/services/phone_web/browser_bridge_web.dart';

/// The phone's API as seen from the web version; the session cookie from the PIN form goes along by itself.
final class PhoneApi {
  PhoneApi({http.Client? client, BrowserBridge? bridge})
    : _client = client ?? http.Client(),
      _bridge = bridge ?? createBrowserBridge();

  final http.Client _client;
  final BrowserBridge _bridge;

  late final Stream<String> events = _bridge.serverEvents(_url('/api/events').toString());

  Stream<String> eventData(String event) => _bridge.eventData(event);

  /// Like [post], with the JSON answer.
  Future<Object?> postForJson(String path, Object body) async =>
      jsonDecode(utf8.decode(_check(await _client.post(_url(path), headers: _json, body: jsonEncode(body))).bodyBytes));

  Future<Object?> get(String path) async => jsonDecode(utf8.decode(_check(await _client.get(_url(path))).bodyBytes));

  Future<void> post(String path, Object body) async => _check(await _client.post(_url(path), headers: _json, body: jsonEncode(body)));

  Future<void> put(String path, Object body) async => _check(await _client.put(_url(path), headers: _json, body: jsonEncode(body)));

  /// Where the phone serves an app file such as `audio/<id>.m4a`.
  static String fileUrl(String relativePath) => _url('/files/$relativePath').toString();

  static Uri _url(String path) => Uri.base.resolve(path);

  static const Map<String, String> _json = {'Content-Type': 'application/json'};

  http.Response _check(http.Response response) {
    if (response.statusCode == 401) _bridge.openLogin();
    if (response.statusCode >= 400) throw PhoneApiException(response.statusCode, response.body);
    return response;
  }
}

final class PhoneApiException implements Exception {
  const PhoneApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'Phone API $statusCode: $message';
}
