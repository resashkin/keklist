import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The web version's files, packed into the app by scripts/build_web_bundle.sh.
class WebBundle {
  WebBundle.fromZip(Uint8List zip)
    : _files = {
        for (final file in ZipDecoder().decodeBytes(zip).files)
          if (file.isFile) file.name: file,
      };

  static const asset = 'assets/web/keklist_web.zip';

  /// The bundle in the app, or `null` when the app was built without one.
  static Future<WebBundle?> load([AssetBundle? assets]) async {
    final ByteData data;
    try {
      data = await (assets ?? rootBundle).load(asset);
    } on FlutterError {
      return null;
    }
    return WebBundle.fromZip(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  }

  final Map<String, ArchiveFile> _files;
  final _cache = <String, WebFile>{};

  /// The file at [path] ("index.html", "canvaskit/canvaskit.wasm", ...).
  WebFile? operator [](String path) {
    final cached = _cache[path];
    if (cached != null) return cached;
    final file = _files[path];
    if (file == null) return null;
    return _cache[path] = WebFile._(file);
  }
}

class WebFile {
  WebFile._(this._file)
    : contentType = contentTypeOf(_file.name),
      etag = '"${(_file.crc32 ?? 0).toRadixString(16)}-${_file.size}"';

  final ArchiveFile _file;
  final String contentType;
  final String etag;

  Uint8List get bytes => _file.readBytes() ?? Uint8List(0);

  /// The content as a gzip stream, made from the zip's own deflate data so
  /// that serving it costs no compression; `null` if the zip stored the file
  /// uncompressed.
  late final Uint8List? gzipped = _gzip();

  Uint8List? _gzip() {
    final crc = _file.crc32;
    final raw = _file.rawContent;
    if (_file.compression != CompressionType.deflate ||
        crc == null ||
        raw == null) {
      return null;
    }
    final deflated = raw.getStream(decompress: false).toUint8List();
    final trailer = ByteData(8)
      ..setUint32(0, crc, Endian.little)
      ..setUint32(4, _file.size, Endian.little);
    return (BytesBuilder(copy: false)
          // Magic, deflate, no flags, no time, no extra flags, unknown OS.
          ..add(const [0x1f, 0x8b, 8, 0, 0, 0, 0, 0, 0, 0xff])
          ..add(deflated)
          ..add(trailer.buffer.asUint8List()))
        .takeBytes();
  }

  static String contentTypeOf(String path) {
    final dot = path.lastIndexOf('.');
    final extension = dot < 0 ? '' : path.substring(dot + 1).toLowerCase();
    return _contentTypes[extension] ?? 'application/octet-stream';
  }

  static const _contentTypes = {
    'html': 'text/html; charset=utf-8',
    'js': 'text/javascript; charset=utf-8',
    'mjs': 'text/javascript; charset=utf-8',
    'css': 'text/css; charset=utf-8',
    'json': 'application/json; charset=utf-8',
    'txt': 'text/plain; charset=utf-8',
    'wasm': 'application/wasm',
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'heic': 'image/heic',
    'm4a': 'audio/mp4',
    'aac': 'audio/aac',
    'mp3': 'audio/mpeg',
    'wav': 'audio/wav',
    'mp4': 'video/mp4',
    'mov': 'video/quicktime',
    'svg': 'image/svg+xml',
    'ico': 'image/x-icon',
    'ttf': 'font/ttf',
    'otf': 'font/otf',
    'woff': 'font/woff',
    'woff2': 'font/woff2',
  };
}
