/// Recognizes the same gallery photo or video on any device: when it was taken (UTC, to the second) and its size in
/// pixels. Comments and emotions of a gallery item hang on its [key], so they travel with an export to another
/// iPhone or an Android phone, where the photo has a different local id. See `documentation/DAY_FEED_IMPLEMENTATION.md`.
final class PhotoFingerprint {
  static const String prefix = 'photo:';

  /// Devices in other time zones may read the same capture time shifted by whole quarter hours.
  static const int _zoneStepSeconds = 15 * 60;
  static const int _maxZoneShiftSeconds = 14 * 60 * 60;

  final int takenAtSeconds;

  /// 0 when unknown (a file without EXIF): then only the time is compared.
  final int width;
  final int height;

  const PhotoFingerprint({required this.takenAtSeconds, required this.width, required this.height});

  factory PhotoFingerprint.of(DateTime takenAt, {int width = 0, int height = 0}) => PhotoFingerprint(
    takenAtSeconds: takenAt.toUtc().millisecondsSinceEpoch ~/ 1000,
    width: width,
    height: height,
  );

  String get key => '$prefix$takenAtSeconds:${width}x$height';

  static bool isKey(String value) => value.startsWith(prefix);

  static PhotoFingerprint? parse(String value) {
    if (!isKey(value)) return null;
    final List<String> parts = value.substring(prefix.length).split(':');
    if (parts.length != 2) return null;
    final List<String> size = parts[1].split('x');
    final int? seconds = int.tryParse(parts[0]);
    final int? width = size.length == 2 ? int.tryParse(size[0]) : null;
    final int? height = size.length == 2 ? int.tryParse(size[1]) : null;
    if (seconds == null || width == null || height == null) return null;
    return PhotoFingerprint(takenAtSeconds: seconds, width: width, height: height);
  }

  bool _hasSize() => width > 0 && height > 0;

  /// Same size (either way round, as rotation may be stored apart) or an unknown one.
  bool _sameSize(PhotoFingerprint other) =>
      !_hasSize() ||
      !other._hasSize() ||
      (width == other.width && height == other.height) ||
      (width == other.height && height == other.width);

  bool matches(PhotoFingerprint other) {
    if (!_sameSize(other)) return false;
    final int shift = (takenAtSeconds - other.takenAtSeconds).abs();
    return shift == 0 || (shift <= _maxZoneShiftSeconds && shift % _zoneStepSeconds == 0);
  }

  /// The root a gallery item's comments live on: an existing one that is the same photo, the exact one first, so a
  /// thread started on another device carries on; otherwise its own [key].
  String rootAmong(Iterable<String> roots) {
    PhotoFingerprint? shifted;
    String? shiftedKey;
    for (final String root in roots) {
      final PhotoFingerprint? other = parse(root);
      if (other == null || !matches(other)) continue;
      if (other.takenAtSeconds == takenAtSeconds) return root;
      if (shifted == null) {
        shifted = other;
        shiftedKey = root;
      }
    }
    return shiftedKey ?? key;
  }
}
