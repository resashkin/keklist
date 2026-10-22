import 'dart:async';

import 'package:keklist/domain/services/phone_web/phone_api.dart';
import 'package:rxdart/rxdart.dart';

/// Items kept on the phone, mirrored in memory: changes show at once and go to the phone, and whatever changes
/// on the phone arrives through its events.
final class PhoneCollection<T> {
  PhoneCollection({
    required PhoneApi api,
    required this.path,
    required this.event,
    required this.idOf,
    required this.toJson,
    required this.fromJson,
  }) : _api = api {
    _events = _api.events.where((name) => name == event || name == 'open').listen((_) => reload().ignore());
    reload().ignore();
  }

  final PhoneApi _api;
  final String path;
  final String event;
  final String Function(T item) idOf;
  final Map<String, dynamic> Function(T item) toJson;
  final T Function(Map<String, dynamic> json) fromJson;

  final BehaviorSubject<Map<String, T>> _items = BehaviorSubject<Map<String, T>>.seeded(const {});
  late final StreamSubscription<String> _events;
  final Completer<void> _loaded = Completer<void>();

  Iterable<T> get values => _items.value.values;
  Stream<Iterable<T>> get stream => _items.stream.map((items) => items.values);

  /// Resolves once the first answer from the phone is in.
  Future<Iterable<T>> obtain() async {
    await _loaded.future;
    return values;
  }

  T? operator [](String id) => _items.value[id];

  Future<void> reload() async {
    try {
      final List<dynamic> json = await _api.get(path) as List<dynamic>;
      _items.add({
        for (final Map<String, dynamic> item in json.cast<Map<String, dynamic>>())
          idOf(fromJson(item)): fromJson(item),
      });
    } finally {
      if (!_loaded.isCompleted) _loaded.complete();
    }
  }

  Future<void> upsert(Iterable<T> items) async {
    if (items.isEmpty) return;
    _items.add({..._items.value, for (final T item in items) idOf(item): item});
    await _api.post(path, {'upsert': [for (final T item in items) toJson(item)]});
  }

  Future<void> delete(Iterable<String> ids) async {
    final Set<String> deleted = ids.toSet();
    if (deleted.isEmpty) return;
    _items.add(Map.of(_items.value)..removeWhere((id, _) => deleted.contains(id)));
    await _api.post(path, {'delete': deleted.toList()});
  }

  Future<void> dispose() async {
    await _events.cancel();
    await _items.close();
  }
}
