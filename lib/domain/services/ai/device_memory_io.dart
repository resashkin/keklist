import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

/// The phone's physical memory, to hide models it can't hold.
abstract final class DeviceMemory {
  static int? _cached;

  static int? get totalBytes {
    if (kIsWeb) return null;
    return _cached ??= switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => _sysctlMemSize(),
      TargetPlatform.android || TargetPlatform.linux => _procMemTotal(),
      _ => null,
    };
  }

  static double? get totalGb => switch (totalBytes) {
    final int bytes => bytes / (1 << 30),
    null => null,
  };

  /// What this app may still allocate before the system stops it; null where the system doesn't say.
  static int? get availableBytes {
    if (kIsWeb) return null;
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => _procAvailableMemory(),
      TargetPlatform.android || TargetPlatform.linux => _procMemAvailable(),
      _ => null,
    };
  }

  static int? _procAvailableMemory() {
    try {
      final int available = DynamicLibrary.process().lookupFunction<Size Function(), int Function()>(
        'os_proc_available_memory',
      )();
      return available > 0 ? available : null;
    } on Object {
      return null;
    }
  }

  static int? _procMemAvailable() {
    try {
      final RegExpMatch? match = RegExp(
        r'MemAvailable:\s+(\d+) kB',
      ).firstMatch(File('/proc/meminfo').readAsStringSync());
      return match == null ? null : int.parse(match.group(1)!) * 1024;
    } on Object {
      return null;
    }
  }

  static int? _procMemTotal() {
    try {
      final RegExpMatch? match = RegExp(r'MemTotal:\s+(\d+) kB').firstMatch(File('/proc/meminfo').readAsStringSync());
      return match == null ? null : int.parse(match.group(1)!) * 1024;
    } on Object {
      return null;
    }
  }

  static int? _sysctlMemSize() {
    try {
      final int Function(Pointer<Utf8>, Pointer<Uint64>, Pointer<Size>, Pointer<Void>, int) sysctlbyname =
          DynamicLibrary.process().lookupFunction<
            Int32 Function(Pointer<Utf8>, Pointer<Uint64>, Pointer<Size>, Pointer<Void>, Size),
            int Function(Pointer<Utf8>, Pointer<Uint64>, Pointer<Size>, Pointer<Void>, int)
          >('sysctlbyname');
      final Pointer<Utf8> name = 'hw.memsize'.toNativeUtf8();
      final Pointer<Uint64> value = calloc<Uint64>();
      final Pointer<Size> length = calloc<Size>()..value = sizeOf<Uint64>();
      try {
        return sysctlbyname(name, value, length, nullptr, 0) == 0 ? value.value : null;
      } finally {
        calloc.free(name);
        calloc.free(value);
        calloc.free(length);
      }
    } on Object {
      return null;
    }
  }
}
