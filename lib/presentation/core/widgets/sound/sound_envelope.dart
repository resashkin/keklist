import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:just_waveform/just_waveform.dart';

/// Loudness of a sound file over time, 0…1, normalized to the file's own loud parts so quiet voice notes move too.
final class SoundEnvelope {
  static const int levelsPerSecond = 30;
  static const double _loudPercentile = 0.95;
  static final Map<String, Future<SoundEnvelope?>> _cache = {};

  final List<double> levels;

  const SoundEnvelope(this.levels);

  double levelAt(Duration position) {
    if (levels.isEmpty) return 0.0;
    final double exact = position.inMicroseconds / Duration.microsecondsPerSecond * levelsPerSecond;
    final int index = exact.floor().clamp(0, levels.length - 1);
    final int next = math.min(index + 1, levels.length - 1);
    final double fraction = (exact - exact.floor()).clamp(0.0, 1.0);
    return levels[index] + (levels[next] - levels[index]) * fraction;
  }

  /// Extracted once per file (audio or the sound of a video) and kept next to it as `<file>.waveform`.
  static Future<SoundEnvelope?> load(String absolutePath) =>
      _cache.putIfAbsent(absolutePath, () => _extract(absolutePath).catchError((_) => null));

  static Future<SoundEnvelope?> _extract(String absolutePath) async {
    if (absolutePath.startsWith('http')) return null;
    final File source = File(absolutePath);
    if (!await source.exists()) return null;
    final File waveformFile = File('$absolutePath.waveform');
    if (await waveformFile.exists()) return fromWaveform(await JustWaveform.parse(waveformFile));
    final WaveformProgress done = await JustWaveform.extract(
      audioInFile: source,
      waveOutFile: waveformFile,
      zoom: const WaveformZoom.pixelsPerSecond(levelsPerSecond),
    ).firstWhere((progress) => progress.waveform != null);
    return fromWaveform(done.waveform!);
  }

  static SoundEnvelope fromWaveform(Waveform waveform) => fromRaw([
    for (int i = 0; i < waveform.length; i++)
      math.max(waveform.getPixelMin(i).abs(), waveform.getPixelMax(i).abs()).toDouble(),
  ]);

  static SoundEnvelope fromRaw(List<double> raw) {
    if (raw.isEmpty) return const SoundEnvelope([]);
    final List<double> sorted = [...raw]..sort();
    final double loud = sorted[((sorted.length - 1) * _loudPercentile).round()];
    if (loud <= 0.0) return SoundEnvelope(List.filled(raw.length, 0.0));
    return SoundEnvelope([for (final double value in raw) (value / loud).clamp(0.0, 1.0)]);
  }
}
