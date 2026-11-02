/// Browsers don't tell the memory; the web version never runs models.
abstract final class DeviceMemory {
  static int? get totalBytes => null;

  static double? get totalGb => null;

  static int? get availableBytes => null;
}
