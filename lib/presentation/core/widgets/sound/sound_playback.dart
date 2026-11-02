import 'package:just_audio/just_audio.dart';
import 'package:keklist/presentation/core/widgets/sound/sound_envelope.dart';
import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

/// What is playing right now and how loud it is at its current position.
final class SoundPlayback {
  final Duration Function() _position;
  final bool Function() _isPlaying;
  SoundEnvelope? envelope;

  SoundPlayback({required Duration Function() position, required bool Function() isPlaying, this.envelope})
    : _position = position,
      _isPlaying = isPlaying;

  factory SoundPlayback.audio(AudioPlayer player) => SoundPlayback(
    position: () => player.position,
    isPlaying: () => player.playing && player.processingState != ProcessingState.completed,
  );

  factory SoundPlayback.video(VideoPlayerController controller) => SoundPlayback(
    position: () => controller.value.position,
    isPlaying: () => controller.value.isPlaying && controller.value.volume > 0.0,
  );

  /// 0 when paused, muted or the envelope is still loading.
  double get level => _isPlaying() ? envelope?.levelAt(_position()) ?? 0.0 : 0.0;

  /// Attaches the envelope of [absolutePath] once it is extracted.
  SoundPlayback withEnvelopeOf(String absolutePath) {
    SoundEnvelope.load(absolutePath).then((loaded) => envelope = loaded);
    return this;
  }
}

/// Lets players deep in a page tell the page's background what they are playing.
final class SoundPlaybackScope extends InheritedNotifier<ValueNotifier<SoundPlayback?>> {
  const SoundPlaybackScope({super.key, required ValueNotifier<SoundPlayback?> super.notifier, required super.child});

  static ValueNotifier<SoundPlayback?>? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SoundPlaybackScope>()?.notifier;

  static SoundPlayback? watch(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SoundPlaybackScope>()?.notifier?.value;
}
