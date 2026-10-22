import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:keklist/domain/repositories/emotion/emotion_repository.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/web_server/gallery_routes.dart';
import 'package:keklist/domain/services/web_server/login_page.dart';
import 'package:keklist/domain/services/web_server/name_announcer.dart';
import 'package:keklist/domain/services/web_server/web_access.dart';
import 'package:keklist/domain/services/web_server/serve_file.dart';
import 'package:keklist/domain/services/web_server/web_bundle.dart';

sealed class WebServerState {
  const WebServerState();
}

/// Not served: without a PIN anyone in the Wi-Fi could open it.
final class WebServerNeedsPin extends WebServerState {
  const WebServerNeedsPin();
}

/// Not served: the app was built without scripts/build_web_bundle.sh.
final class WebServerNoBundle extends WebServerState {
  const WebServerNoBundle();
}

final class WebServerStarting extends WebServerState {
  const WebServerStarting();
}

final class WebServerRunning extends WebServerState {
  const WebServerRunning(this.port, this.hosts, {this.name, this.nameProblem});

  final int port;

  /// This device's addresses in the local network, the Wi-Fi first.
  final List<String> hosts;

  /// The name the network knows this device by, like "keklist.local".
  final String? name;

  /// Why there is no [name], when the user can do something about it.
  final String? nameProblem;

  /// Where to open the web version: by [name] first, then by address.
  List<String> get addresses => [
    if (name case final name?) 'http://$name:$port',
    for (final host in hosts) 'http://$host:$port',
  ];
}

final class WebServerFailed extends WebServerState {
  const WebServerFailed(this.message);

  final String message;
}

/// Serves the web version to browsers in the local network behind the PIN from [WebAccess], with an API over
/// the phone's minds, emotions and profile. See `documentation/WEB_VERSION_IMPLEMENTATION.md`.
final class KeklistWebServer extends ChangeNotifier {
  KeklistWebServer({
    required this.access,
    required MindRepository mindRepository,
    required EmotionRepository emotionRepository,
    required SettingsRepository settingsRepository,
    required AppFileRepository fileRepository,
    GalleryRoutes? gallery,
    NameAnnouncer? announcer,
  }) : _minds = mindRepository,
       _gallery = gallery,
       _emotions = emotionRepository,
       _settings = settingsRepository,
       _files = fileRepository,
       _announcer = announcer;

  final WebAccess access;
  final MindRepository _minds;
  final EmotionRepository _emotions;
  final SettingsRepository _settings;
  final AppFileRepository _files;
  final GalleryRoutes? _gallery;
  final NameAnnouncer? _announcer;

  static const _cookie = 'keklist_session';
  static const _maxBody = 16 << 20;
  static const _nameRetryDelay = Duration(seconds: 10);
  static const _nameRetries = 3;
  static const _keepAlive = Duration(seconds: 20);

  WebServerState _state = const WebServerStarting();
  WebBundle? _bundle;
  HttpServer? _server;
  int? _boundPort;
  AppLifecycleListener? _lifecycle;
  Timer? _nameRetry;
  var _nameAttempts = 0;
  var _disposed = false;
  final List<StreamSubscription<Object?>> _changes = [];
  final Set<HttpResponse> _listeners = {};

  /// Starts and restarts happen one after another.
  Future<void> _work = Future.value();

  WebServerState get state => _state;

  /// Serves whenever a PIN is set, from now on: setting or removing the PIN or changing the port takes effect at once.
  Future<void> start() {
    access.addListener(_accessChanged);
    _lifecycle = AppLifecycleListener(onResume: _resumed);
    _changes.addAll([
      _minds.stream.skip(1).listen((_) => _broadcast('minds')),
      _emotions.stream.skip(1).listen((_) => _broadcast('emotions')),
      ?_gallery?.changes.listen((_) => _broadcast('gallery')),
      _settings.stream
          .map((settings) => (settings.userName, settings.avatar))
          .distinct()
          .skip(1)
          .listen((_) => _broadcast('profile')),
    ]);
    return _apply();
  }

  void _accessChanged() {
    notifyListeners();
    _apply();
  }

  // iOS takes the socket away while the app is suspended.
  void _resumed() => _apply(restart: defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _apply({bool restart = false}) => _work = _work.then((_) => _update(restart: restart));

  Future<void> _update({required bool restart}) async {
    if (_disposed) return;
    if (!access.hasPin) return _end(const WebServerNeedsPin());
    if (!restart && _server != null && _boundPort == access.port) return _refreshHosts();
    await _close();
    final WebBundle? bundle = _bundle ??= await WebBundle.load();
    if (bundle == null) return _end(const WebServerNoBundle());
    _set(const WebServerStarting());
    final int port = access.port;
    final HttpServer server;
    try {
      server = await HttpServer.bind(InternetAddress.anyIPv4, port, shared: true);
    } on SocketException catch (error) {
      return _end(WebServerFailed(_describe(error, port)));
    }
    if (_disposed) {
      await server.close(force: true);
      return;
    }
    _server = server;
    _boundPort = port;
    server.listen(
      _handle,
      onError: (Object error) {
        if (identical(_server, server)) _apply(restart: true);
      },
    );
    await _announce();
  }

  /// Finds where the server is reached now and tells the network its name.
  Future<void> _announce() async {
    final List<String> hosts = await lanHosts();
    final HttpServer? server = _server;
    if (server == null || _disposed) return;
    final NameAnnouncer? announcer = _announcer;
    String? name;
    if (announcer != null) {
      if (hosts.isEmpty) {
        await announcer.withdraw();
      } else {
        name = await announcer.announce(address: InternetAddress(hosts.first), port: server.port);
        _retryName(missing: name == null);
      }
      if (!identical(_server, server)) return;
    }
    _set(WebServerRunning(server.port, hosts, name: name, nameProblem: name == null ? announcer?.problem : null));
  }

  void _retryName({required bool missing}) {
    _nameRetry?.cancel();
    if (!missing) {
      _nameAttempts = 0;
      return;
    }
    if (++_nameAttempts > _nameRetries) return;
    _nameRetry = Timer(_nameRetryDelay, () => _work = _work.then((_) => _refreshHosts()));
  }

  Future<void> _refreshHosts() async {
    if (_state is WebServerRunning) await _announce();
  }

  Future<void> _end(WebServerState state) async {
    await _close();
    _nameRetry?.cancel();
    _nameAttempts = 0;
    await _announcer?.withdraw();
    _set(state);
  }

  Future<void> _close() async {
    final HttpServer? server = _server;
    _server = null;
    _boundPort = null;
    for (final HttpResponse listener in _listeners.toList()) {
      unawaited(listener.close().catchError((_) {}));
    }
    _listeners.clear();
    await server?.close(force: true);
  }

  void _set(WebServerState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  static String _describe(SocketException error, int port) {
    // EADDRINUSE on Linux (Android) and on Darwin (iOS).
    final int? code = error.osError?.errorCode;
    if (code == 98 || code == 48) return 'Port $port is taken by another app. Choose another port.';
    return "Couldn't open port $port: ${error.osError?.message ?? error.message}";
  }

  @override
  void dispose() {
    _disposed = true;
    access.removeListener(_accessChanged);
    _lifecycle?.dispose();
    for (final StreamSubscription<Object?> change in _changes) {
      change.cancel();
    }
    _close();
    _nameRetry?.cancel();
    _announcer?.withdraw();
    super.dispose();
  }

  // Requests.

  Future<void> _handle(HttpRequest request) async {
    final HttpResponse response = request.response;
    response.headers
      ..set('X-Frame-Options', 'DENY')
      ..set('Referrer-Policy', 'no-referrer');
    var keepOpen = false;
    try {
      // A web page that points its own domain at this phone can't use this server through the visitor's browser.
      if (!_knownHost(request)) return _text(response, HttpStatus.misdirectedRequest, 'Unknown host');
      final String path = request.uri.path;
      if (path == '/login') return await _login(request);
      if (!access.hasSession(_sessionToken(request))) {
        if (path.startsWith('/api/') || path.startsWith('/files/') || path.startsWith('/gallery/')) {
          return _text(response, HttpStatus.unauthorized, 'Enter the PIN');
        }
        return _redirect(response, '/login');
      }
      switch (path) {
        case '/api/events':
          keepOpen = true;
          return await _events(request);
        case '/api/minds':
          return await _collection(request, read: _mindsJson, write: _writeMinds);
        case '/api/emotions':
          return await _collection(request, read: _emotionsJson, write: _writeEmotions);
        case '/api/profile':
          return await _profile(request);
        case '/api/gallery':
          return _gallery == null ? _json(response, null) : _json(response, _gallery.indexJson());
        case '/api/gallery/day':
          final int? day = int.tryParse(request.uri.queryParameters['day'] ?? '');
          if (_gallery == null || day == null) return _json(response, const []);
          return _json(response, await _gallery.dayJson(day));
        case '/gallery/thumb':
          return _gallery == null ? _text(response, HttpStatus.notFound, 'Not found') : await _gallery.thumbnail(request);
        case '/gallery/full':
          return _gallery == null ? _text(response, HttpStatus.notFound, 'Not found') : await _gallery.original(request);
      }
      if (path.startsWith('/files/')) return await _file(request);
      return _static(request);
    } on Object catch (error, stack) {
      debugPrint('Web server: $error\n$stack');
      try {
        response.statusCode = HttpStatus.internalServerError;
      } on StateError {
        // The headers were sent already.
      }
    } finally {
      if (!keepOpen) await response.close().catchError((_) {});
    }
  }

  /// Hosts the phone is reached by in the local network: addresses and ".local" names.
  static bool _knownHost(HttpRequest request) {
    final String? host = request.headers.host;
    if (host == null) return false;
    final String bare = host.startsWith('[') && host.endsWith(']') ? host.substring(1, host.length - 1) : host;
    return InternetAddress.tryParse(bare) != null || bare == 'localhost' || bare.endsWith('.local');
  }

  static String? _sessionToken(HttpRequest request) {
    try {
      for (final Cookie cookie in request.cookies) {
        if (cookie.name == _cookie) return cookie.value;
      }
    } on Object {
      // Malformed cookies, e.g. left by other servers on this address.
    }
    return null;
  }

  Future<void> _login(HttpRequest request) async {
    final HttpResponse response = request.response;
    response.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
    switch (request.method) {
      case 'GET' || 'HEAD':
        if (access.hasSession(_sessionToken(request))) return _redirect(response, '/');
        return _html(response, HttpStatus.ok, loginPage());
      case 'POST':
        final Uint8List? body = await _readBody(request, 1024);
        final String pin = body == null
            ? ''
            : Uri.splitQueryString(utf8.decode(body, allowMalformed: true))['pin'] ?? '';
        switch (access.checkPin(pin)) {
          case PinAccepted():
            response.cookies.add(
              Cookie(_cookie, await access.openSession())
                ..path = '/'
                ..maxAge = WebAccess.sessionLifetime.inSeconds
                ..httpOnly = true
                ..sameSite = SameSite.strict,
            );
            return _redirect(response, '/');
          case PinRejected(:final attemptsLeft):
            return _html(
              response,
              HttpStatus.unauthorized,
              loginPage(error: attemptsLeft == 1 ? 'Wrong PIN. 1 try left.' : 'Wrong PIN. $attemptsLeft tries left.'),
            );
          case PinLocked(:final retryAfter):
            final int minutes = (retryAfter.inSeconds / 60).ceil();
            response.headers.set(HttpHeaders.retryAfterHeader, retryAfter.inSeconds);
            return _html(
              response,
              HttpStatus.tooManyRequests,
              loginPage(error: 'Too many wrong PINs. Try again in ${minutes == 1 ? '1 minute' : '$minutes minutes'}.'),
            );
        }
      default:
        return _notAllowed(response, 'GET, POST');
    }
  }

  /// Server-sent events: "minds", "emotions" or "profile" whenever they change on the phone.
  Future<void> _events(HttpRequest request) async {
    final HttpResponse response = request.response;
    response
      ..bufferOutput = false
      ..headers.contentType = ContentType('text', 'event-stream', charset: 'utf-8')
      ..headers.set(HttpHeaders.cacheControlHeader, 'no-store');
    response.write(': connected\n\n');
    await response.flush();
    _listeners.add(response);
    final Timer keepAlive = Timer.periodic(_keepAlive, (_) => _send(response, ': ping\n\n'));
    await response.done.catchError((_) {});
    keepAlive.cancel();
    _listeners.remove(response);
  }

  void _broadcast(String event) {
    for (final HttpResponse listener in _listeners.toList()) {
      _send(listener, 'event: $event\ndata: {}\n\n');
    }
  }

  void _send(HttpResponse listener, String text) {
    try {
      listener.write(text);
      listener.flush().catchError((_) => _listeners.remove(listener));
    } on Object {
      _listeners.remove(listener);
    }
  }

  /// GET answers every item; POST `{"upsert": [...], "delete": [ids]}` changes several at once.
  Future<void> _collection(
    HttpRequest request, {
    required Future<Object?> Function() read,
    required Future<void> Function(List<Map<String, dynamic>> upsert, List<String> delete) write,
  }) async {
    final HttpResponse response = request.response;
    response.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
    switch (request.method) {
      case 'GET':
        return _json(response, await read());
      case 'POST':
        final Map<String, dynamic>? body = await _readJson(request);
        if (body == null) return;
        try {
          await write(
            (body['upsert'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>(),
            (body['delete'] as List<dynamic>? ?? const []).cast<String>(),
          );
        } on Object catch (error) {
          if (error is! TypeError && error is! FormatException && error is! ArgumentError) rethrow;
          return _text(response, HttpStatus.badRequest, 'Bad items');
        }
        response.statusCode = HttpStatus.noContent;
      default:
        return _notAllowed(response, 'GET, POST');
    }
  }

  Future<Object?> _mindsJson() async => [for (final Mind mind in await _minds.obtainMinds()) mind.toJson()];

  Future<void> _writeMinds(List<Map<String, dynamic>> upsert, List<String> delete) async {
    final List<Mind> minds = upsert.map(Mind.fromJson).toList();
    final Map<String, Mind> existing = {for (final Mind mind in await _minds.obtainMinds()) mind.id: mind};
    final List<Mind> created = minds.where((mind) => !existing.containsKey(mind.id)).toList();
    final List<Mind> updated = minds.where((mind) => existing.containsKey(mind.id)).toList();
    if (created.isNotEmpty) await _minds.createMinds(minds: created);
    if (updated.isNotEmpty) await _minds.updateMinds(minds: updated);
    for (final String id in delete) {
      await _minds.deleteMind(mindId: id);
    }
    // The browser can't touch the phone's files, so media its edits dropped goes here.
    final Set<String> dropped = {
      for (final Mind mind in [...updated, ...delete.map((id) => existing[id]).nonNulls])
        ...?existing[mind.id]?.noteContent.mediaFilePaths,
    }..removeAll(updated.expand((mind) => mind.noteContent.mediaFilePaths));
    for (final String path in dropped) {
      final File file = File(await _files.resolveAbsolutePath(path));
      if (await file.exists()) await file.delete().catchError((_) => file);
    }
  }

  Future<Object?> _emotionsJson() async => [
    for (final Emotion emotion in await _emotions.obtainEmotions()) emotion.toJson(),
  ];

  Future<void> _writeEmotions(List<Map<String, dynamic>> upsert, List<String> delete) async {
    final List<Emotion> emotions = upsert.map(Emotion.fromJson).toList();
    final Set<String> existing = (await _emotions.obtainEmotions()).map((emotion) => emotion.id).toSet();
    final List<Emotion> created = emotions.where((emotion) => !existing.contains(emotion.id)).toList();
    final List<Emotion> updated = emotions.where((emotion) => existing.contains(emotion.id)).toList();
    if (created.isNotEmpty) await _emotions.createEmotions(emotions: created);
    if (updated.isNotEmpty) await _emotions.updateEmotions(emotions: updated);
    for (final String id in delete) {
      await _emotions.deleteEmotion(id: id);
    }
  }

  /// GET `{"name", "emoji", "imagePath"}`; PUT changes the name and/or the emoji (which replaces a photo).
  Future<void> _profile(HttpRequest request) async {
    final HttpResponse response = request.response;
    response.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
    final KeklistSettings settings = _settings.value;
    switch (request.method) {
      case 'GET':
        return _json(response, {
          'name': settings.userName,
          'emoji': settings.avatar.emoji,
          'imagePath': settings.avatar.imagePath,
        });
      case 'PUT':
        final Map<String, dynamic>? body = await _readJson(request);
        if (body == null) return;
        if (body['name'] case final String name) await _settings.updateUserName(name.trim());
        if (body.containsKey('emoji')) {
          final Object? emoji = body['emoji'];
          await _settings.updateUserAvatar(
            emoji is String ? UserAvatar(emoji: emoji) : UserAvatar(imagePath: settings.avatar.imagePath),
          );
        }
        response.statusCode = HttpStatus.noContent;
      default:
        return _notAllowed(response, 'GET, PUT');
    }
  }

  /// The app's own audio, video and avatar files, with byte ranges so that browsers can seek in them.
  Future<void> _file(HttpRequest request) async {
    final HttpResponse response = request.response;
    if (request.method != 'GET' && request.method != 'HEAD') return _notAllowed(response, 'GET');
    final List<String> segments = request.uri.pathSegments.skip(1).toList();
    if (segments.isEmpty || segments.any((segment) => segment.isEmpty || segment == '.' || segment == '..')) {
      return _text(response, HttpStatus.notFound, 'Not found');
    }
    final File file = File(await _files.resolveAbsolutePath(segments.join('/')));
    if (!await file.exists()) return _text(response, HttpStatus.notFound, 'Not found');
    await serveFile(request, file, contentType: WebFile.contentTypeOf(file.path));
  }

  void _static(HttpRequest request) {
    final HttpResponse response = request.response;
    if (request.method != 'GET' && request.method != 'HEAD') return _notAllowed(response, 'GET');
    final List<String> segments = request.uri.pathSegments;
    final bool isBad = segments.any((segment) => segment.isEmpty || segment == '.' || segment == '..');
    final WebBundle bundle = _bundle!;
    // Unknown paths are the app's own routes, so they get index.html.
    final WebFile? file = isBad
        ? null
        : bundle[segments.isEmpty ? 'index.html' : segments.join('/')] ?? bundle['index.html'];
    if (file == null) return _text(response, HttpStatus.notFound, 'Not found');
    response.headers
      ..contentType = ContentType.parse(file.contentType)
      // Asked again on every load and answered with 304 while unchanged, so a new app version reaches the browser.
      ..set(HttpHeaders.cacheControlHeader, 'no-cache')
      ..set(HttpHeaders.etagHeader, file.etag)
      ..set(HttpHeaders.varyHeader, 'Accept-Encoding');
    if (request.headers.value(HttpHeaders.ifNoneMatchHeader) == file.etag) {
      response.statusCode = HttpStatus.notModified;
      return;
    }
    final bool acceptsGzip = request.headers.value(HttpHeaders.acceptEncodingHeader)?.contains('gzip') ?? false;
    final Uint8List? gzipped = acceptsGzip ? file.gzipped : null;
    final Uint8List body;
    if (gzipped != null) {
      response.headers.set(HttpHeaders.contentEncodingHeader, 'gzip');
      body = gzipped;
    } else {
      body = file.bytes;
    }
    response.contentLength = body.length;
    if (request.method == 'GET') response.add(body);
  }

  /// The JSON object of the body, or `null` after answering why it can't be read.
  static Future<Map<String, dynamic>?> _readJson(HttpRequest request) async {
    final HttpResponse response = request.response;
    // Browsers send JSON across sites only after asking, and this server never says yes; forms can't send JSON.
    if (request.headers.contentType?.mimeType != 'application/json') {
      _text(response, HttpStatus.unsupportedMediaType, 'Send JSON');
      return null;
    }
    final Uint8List? body = await _readBody(request, _maxBody);
    if (body == null) {
      _text(response, HttpStatus.requestEntityTooLarge, 'Too big');
      return null;
    }
    try {
      return jsonDecode(utf8.decode(body)) as Map<String, dynamic>;
    } on Object {
      _text(response, HttpStatus.badRequest, 'Bad JSON');
      return null;
    }
  }

  static Future<Uint8List?> _readBody(HttpRequest request, int limit) async {
    final BytesBuilder body = BytesBuilder(copy: false);
    await for (final List<int> chunk in request) {
      body.add(chunk);
      if (body.length > limit) return null;
    }
    return body.takeBytes();
  }

  static void _redirect(HttpResponse response, String location) {
    response
      ..statusCode = HttpStatus.seeOther
      ..headers.set(HttpHeaders.locationHeader, location);
  }

  static void _notAllowed(HttpResponse response, String allow) {
    response.headers.set(HttpHeaders.allowHeader, allow);
    _text(response, HttpStatus.methodNotAllowed, 'Method not allowed');
  }

  static void _text(HttpResponse response, int status, String text) {
    response
      ..statusCode = status
      ..headers.contentType = ContentType.text
      ..write(text);
  }

  static void _html(HttpResponse response, int status, String html) {
    response
      ..statusCode = status
      ..headers.contentType = ContentType.html
      ..write(html);
  }

  static void _json(HttpResponse response, Object? json) {
    response
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(json));
  }

  /// This device's private IPv4 addresses, the Wi-Fi first. Mobile data and VPN interfaces are left out.
  static Future<List<String>> lanHosts() async {
    final List<(int, String)> ranked = [];
    for (final NetworkInterface interface in await NetworkInterface.list(type: InternetAddressType.IPv4)) {
      final String name = interface.name;
      if (_unreachable.hasMatch(name)) continue;
      final int rank = name.startsWith('wlan') || name == 'en0' ? 0 : 1;
      for (final InternetAddress address in interface.addresses) {
        if (_isPrivate(address)) ranked.add((rank, address.address));
      }
    }
    ranked.sort((a, b) => a.$1.compareTo(b.$1));
    return [for (final (_, host) in ranked) host];
  }

  static final RegExp _unreachable = RegExp(r'^(lo|rmnet|ccmni|pdp_ip|v4-|clat|tun|utun|ipsec|ppp|dummy)');

  static bool _isPrivate(InternetAddress address) {
    final [a, b, ...] = address.rawAddress;
    return a == 10 || (a == 172 && b >= 16 && b < 32) || (a == 192 && b == 168);
  }
}
