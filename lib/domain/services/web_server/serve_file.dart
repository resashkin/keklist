import 'dart:io';

/// Answers with [file], honoring byte ranges so that browsers can seek in audio and video.
Future<void> serveFile(
  HttpRequest request,
  File file, {
  required String contentType,
  String cacheControl = 'private, max-age=31536000, immutable',
}) async {
  final HttpResponse response = request.response;
  final int length = await file.length();
  response.headers
    ..contentType = ContentType.parse(contentType)
    ..set(HttpHeaders.acceptRangesHeader, 'bytes')
    ..set(HttpHeaders.cacheControlHeader, cacheControl);
  int start = 0;
  int end = length - 1;
  final RegExpMatch? range = RegExp(
    r'^bytes=(\d*)-(\d*)$',
  ).firstMatch(request.headers.value(HttpHeaders.rangeHeader) ?? '');
  if (range != null && length > 0) {
    final int? from = int.tryParse(range[1]!);
    final int? to = int.tryParse(range[2]!);
    if (from == null && to != null) {
      start = (length - to).clamp(0, length - 1);
    } else if (from != null) {
      start = from;
      if (to != null) end = to.clamp(from, length - 1);
    }
    if (start >= length) {
      response
        ..statusCode = HttpStatus.requestedRangeNotSatisfiable
        ..headers.set(HttpHeaders.contentRangeHeader, 'bytes */$length');
      return;
    }
    response
      ..statusCode = HttpStatus.partialContent
      ..headers.set(HttpHeaders.contentRangeHeader, 'bytes $start-$end/$length');
  }
  response.contentLength = length == 0 ? 0 : end - start + 1;
  if (request.method == 'GET' && length > 0) await response.addStream(file.openRead(start, end + 1));
}
