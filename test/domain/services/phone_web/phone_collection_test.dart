import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:keklist/domain/services/phone_web/browser_bridge.dart';
import 'package:keklist/domain/services/phone_web/phone_api.dart';
import 'package:keklist/domain/services/phone_web/phone_collection.dart';

final class _FakeBridge implements BrowserBridge {
  final StreamController<String> events = StreamController<String>.broadcast();
  int logins = 0;

  @override
  Stream<String> serverEvents(String url) => events.stream;

  @override
  void openLogin() => logins++;
}

void main() {
  late _FakeBridge bridge;
  late List<Map<String, String>> phone;
  late List<Object?> posts;

  PhoneCollection<Map<String, String>> collection({int status = 200}) => PhoneCollection<Map<String, String>>(
    api: PhoneApi(
      bridge: bridge,
      client: MockClient((request) async {
        if (request.method == 'POST') posts.add(jsonDecode(request.body));
        return http.Response(jsonEncode(phone), status);
      }),
    ),
    path: '/api/items',
    event: 'items',
    idOf: (item) => item['id']!,
    toJson: (item) => item,
    fromJson: (json) => json.cast<String, String>(),
  );

  setUp(() {
    bridge = _FakeBridge();
    phone = [
      {'id': 'a', 'text': 'one'},
    ];
    posts = [];
  });

  test('loads what the phone has', () async {
    expect((await collection().obtain()).toList(), phone);
  });

  test('reloads when the phone announces a change', () async {
    final PhoneCollection<Map<String, String>> items = collection();
    await items.obtain();
    phone = [
      {'id': 'b', 'text': 'two'},
    ];
    bridge.events.add('items');
    await expectLater(items.stream, emitsThrough(phone));
  });

  test('ignores events of other collections', () async {
    final PhoneCollection<Map<String, String>> items = collection();
    await items.obtain();
    phone = [];
    bridge.events.add('emotions');
    await pumpEventQueue();
    expect(items.values, isNotEmpty);
  });

  test('upsert shows at once and goes to the phone', () async {
    final PhoneCollection<Map<String, String>> items = collection();
    await items.obtain();
    final Future<void> sent = items.upsert([
      {'id': 'a', 'text': 'edited'},
    ]);
    expect(items['a']?['text'], 'edited');
    await sent;
    expect(posts, [
      {
        'upsert': [
          {'id': 'a', 'text': 'edited'},
        ],
      },
    ]);
  });

  test('delete removes at once and goes to the phone', () async {
    final PhoneCollection<Map<String, String>> items = collection();
    await items.obtain();
    await items.delete(['a']);
    expect(items.values, isEmpty);
    expect(posts, [
      {
        'delete': ['a'],
      },
    ]);
  });

  test('an expired session opens the PIN form', () async {
    final PhoneCollection<Map<String, String>> items = collection(status: 401);
    await expectLater(items.reload(), throwsA(isA<PhoneApiException>()));
    expect(bridge.logins, greaterThan(0));
  });
}
