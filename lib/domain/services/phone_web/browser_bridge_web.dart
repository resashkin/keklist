import 'dart:async';
import 'dart:js_interop';

import 'package:keklist/domain/services/phone_web/browser_bridge.dart';
import 'package:web/web.dart' as web;

BrowserBridge createBrowserBridge() => _WebBrowserBridge();

final class _WebBrowserBridge implements BrowserBridge {
  _WebBrowserBridge();

  static const List<String> _events = ['minds', 'emotions', 'profile', 'gallery', 'ai'];
  static const List<String> _dataEvents = ['ai-reply'];

  final Map<String, StreamController<String>> _data = {};

  StreamController<String> _dataOf(String event) => _data[event] ??= StreamController<String>.broadcast();

  @override
  Stream<String> eventData(String event) => _dataOf(event).stream;

  @override
  Stream<String> serverEvents(String url) {
    late final web.EventSource source;
    final StreamController<String> controller = StreamController<String>.broadcast(
      onCancel: () => source.close(),
    );
    // The browser reconnects by itself; "open" tells the app to reload what it may have missed meanwhile.
    source = web.EventSource(url)..onopen = ((web.Event _) => controller.add('open')).toJS;
    for (final String event in _events) {
      source.addEventListener(event, ((web.Event _) => controller.add(event)).toJS);
    }
    for (final String event in _dataEvents) {
      source.addEventListener(event, ((web.MessageEvent message) => _dataOf(event).add(message.data.toString())).toJS);
    }
    return controller.stream;
  }

  @override
  void openLogin() => web.window.location.href = '/login';
}
