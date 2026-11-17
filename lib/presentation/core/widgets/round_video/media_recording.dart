import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/services/audio_duration_extractor.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:material_ui/material_ui.dart';
import 'package:record/record.dart';

enum MediaRecordMode { audio, video }

/// The round record button, like Telegram's: a tap switches between audio and round video, holding records,
/// letting go saves. Slide left to throw the recording away, slide up to lock it and keep recording hands-free.
/// See `documentation/HOLD_TO_RECORD.md`.
final class MediaRecordToggleButton extends StatefulWidget {
  /// A finished audio ([MindNoteAudio]) or round video ([MindNoteVideo]).
  final ValueChanged<BaseMindNotePiece> onRecorded;

  /// True while a recording runs, e.g. to hold a story.
  final ValueChanged<bool>? onRecordingChanged;
  final Color? color;

  /// A white circle with a dark icon instead of a plain icon button.
  final bool isFilled;

  const MediaRecordToggleButton({
    super.key,
    required this.onRecorded,
    this.onRecordingChanged,
    this.color,
    this.isFilled = false,
  });

  @override
  State<MediaRecordToggleButton> createState() => _MediaRecordToggleButtonState();
}

final class _MediaRecordToggleButtonState extends State<MediaRecordToggleButton> {
  static const Duration _holdDelay = Duration(milliseconds: 250);
  static const double _cancelDistance = 120.0;
  static const double _lockDistance = 80.0;
  static const Duration _shortest = Duration(milliseconds: 700);

  MediaRecordMode _mode = MediaRecordMode.audio;
  _HoldRecorder? _recorder;
  OverlayEntry? _overlay;
  final ValueNotifier<_RecordingView> _view = ValueNotifier(const _RecordingView());
  bool _isReleased = false;

  @override
  void dispose() {
    _overlay?.remove();
    _overlay = null;
    unawaited(_recorder?.cancel());
    _view.dispose();
    super.dispose();
  }

  void _switchMode() =>
      setState(() => _mode = _mode == MediaRecordMode.audio ? MediaRecordMode.video : MediaRecordMode.audio);

  Future<void> _start() async {
    if (_recorder != null) return;
    final AppFileRepository files = context.read<AppFileRepository>();
    final _HoldRecorder recorder = _mode == MediaRecordMode.audio ? _AudioHoldRecorder(files) : _VideoHoldRecorder(files);
    _recorder = recorder;
    _isReleased = false;
    _view.value = _RecordingView(mode: _mode, recorder: recorder);
    unawaited(HapticFeedback.mediumImpact());
    widget.onRecordingChanged?.call(true);
    _showOverlay();
    final _StartResult result = await recorder.start();
    if (!mounted || _recorder != recorder) return;
    switch (result) {
      case _StartResult.started:
        _view.value = _view.value.copyWith(isRecording: true);
        // Let go while the recorder was still starting, e.g. under a permission prompt: nothing to keep.
        if (_isReleased && !_view.value.isLocked) await _cancel();
      case _StartResult.noPermission:
      case _StartResult.failed:
        await _cancel();
        if (!mounted) return;
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text(
              result == _StartResult.noPermission
                  ? (_mode == MediaRecordMode.audio
                        ? context.l10n.audioRecordPermissionError
                        : context.l10n.roundVideoCameraUnavailable)
                  : context.l10n.roundVideoRecordError,
            ),
          ),
        );
    }
  }

  void _move(LongPressMoveUpdateDetails details) {
    final _RecordingView view = _view.value;
    if (_recorder == null || view.isLocked) return;
    final Offset offset = details.offsetFromOrigin;
    if (offset.dx < -_cancelDistance) {
      unawaited(HapticFeedback.lightImpact());
      unawaited(_cancel());
      return;
    }
    if (offset.dy < -_lockDistance) {
      unawaited(HapticFeedback.selectionClick());
      _view.value = view.copyWith(isLocked: true, slide: 0.0, lift: 0.0);
      return;
    }
    _view.value = view.copyWith(
      slide: (-offset.dx / _cancelDistance).clamp(0.0, 1.0),
      lift: (-offset.dy / _lockDistance).clamp(0.0, 1.0),
    );
  }

  void _release() {
    _isReleased = true;
    if (_recorder == null || _view.value.isLocked) return;
    if (!_view.value.isRecording) return;
    unawaited(_finish());
  }

  Future<void> _finish() async {
    final _HoldRecorder? recorder = _recorder;
    if (recorder == null) return;
    _recorder = null;
    _hideOverlay();
    final bool isTooShort = recorder.elapsed < _shortest;
    final BaseMindNotePiece? piece = isTooShort ? null : await recorder.stop();
    if (isTooShort) await recorder.cancel();
    widget.onRecordingChanged?.call(false);
    if (piece == null || !mounted) return;
    unawaited(HapticFeedback.lightImpact());
    widget.onRecorded(piece);
  }

  Future<void> _cancel() async {
    final _HoldRecorder? recorder = _recorder;
    if (recorder == null) return;
    _recorder = null;
    _hideOverlay();
    await recorder.cancel();
    widget.onRecordingChanged?.call(false);
  }

  void _showOverlay() {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final Rect button = box.localToGlobal(Offset.zero) & box.size;
    _overlay = OverlayEntry(
      builder: (_) => _RecordingOverlay(
        view: _view,
        button: button,
        onCancel: () => unawaited(_cancel()),
        onSend: () => unawaited(_finish()),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_overlay!);
  }

  void _hideOverlay() {
    _overlay?.remove();
    _overlay = null;
    _view.value = const _RecordingView();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAudio = _mode == MediaRecordMode.audio;
    final Widget icon = AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
      child: Icon(
        isAudio ? Icons.mic : Icons.videocam_outlined,
        key: ValueKey(_mode),
        color: widget.isFilled ? Colors.black : widget.color ?? Colors.blueAccent,
      ),
    );
    // No tooltip: it would claim the long-press that starts recording.
    return RawGestureDetector(
      gestures: {
        TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
          TapGestureRecognizer.new,
          (recognizer) => recognizer.onTap = _switchMode,
        ),
        LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
          () => LongPressGestureRecognizer(duration: _holdDelay),
          (recognizer) => recognizer
            ..onLongPressStart = ((_) => unawaited(_start()))
            ..onLongPressMoveUpdate = _move
            ..onLongPressEnd = ((_) => _release())
            ..onLongPressCancel = _release,
        ),
      },
      child: widget.isFilled
          ? Container(
              width: 52.0,
              height: 52.0,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Center(child: icon),
            )
          : SizedBox.square(dimension: 48.0, child: Center(child: icon)),
    );
  }
}

/// What the overlay shows of the running recording.
final class _RecordingView {
  final MediaRecordMode mode;
  final _HoldRecorder? recorder;
  final bool isRecording;
  final bool isLocked;

  /// 0…1 of the way to cancelling (left) and to locking (up).
  final double slide;
  final double lift;

  const _RecordingView({
    this.mode = MediaRecordMode.audio,
    this.recorder,
    this.isRecording = false,
    this.isLocked = false,
    this.slide = 0.0,
    this.lift = 0.0,
  });

  _RecordingView copyWith({bool? isRecording, bool? isLocked, double? slide, double? lift}) => _RecordingView(
    mode: mode,
    recorder: recorder,
    isRecording: isRecording ?? this.isRecording,
    isLocked: isLocked ?? this.isLocked,
    slide: slide ?? this.slide,
    lift: lift ?? this.lift,
  );
}

/// The bar next to the button (timer, "slide to cancel"), the lock above it and, for video, the camera circle.
final class _RecordingOverlay extends StatelessWidget {
  static const double _barHeight = 52.0;

  final ValueNotifier<_RecordingView> view;
  final Rect button;
  final VoidCallback onCancel;
  final VoidCallback onSend;

  const _RecordingOverlay({required this.view, required this.button, required this.onCancel, required this.onSend});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<_RecordingView>(
    valueListenable: view,
    builder: (context, state, _) {
      final _HoldRecorder? recorder = state.recorder;
      if (recorder == null) return const SizedBox.shrink();
      final ColorScheme colors = Theme.of(context).colorScheme;
      final Size screen = MediaQuery.sizeOf(context);
      final bool isVideo = state.mode == MediaRecordMode.video;
      final double circle = (screen.width - 48.0).clamp(0.0, 320.0);
      return Stack(
        children: [
          // Locked, the screen waits for send or delete; while held, the finger owns every touch anyway.
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !state.isLocked,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                color: isVideo ? Colors.black.withValues(alpha: 0.75) : Colors.transparent,
              ),
            ),
          ),
          if (isVideo)
            Positioned(
              left: (screen.width - circle) / 2,
              top: (button.top - circle) / 2 - 24.0,
              width: circle,
              height: circle,
              child: IgnorePointer(child: _CameraCircle(recorder: recorder as _VideoHoldRecorder, isRecording: state.isRecording)),
            ),
          Positioned(
            left: 12.0,
            right: screen.width - button.left + 8.0,
            top: button.center.dy - _barHeight / 2,
            height: _barHeight,
            child: Material(
              color: colors.surfaceContainerHigh,
              shape: const StadiumBorder(),
              child: Row(
                children: [
                  const SizedBox(width: 16.0),
                  _BlinkingDot(isOn: state.isRecording),
                  const SizedBox(width: 8.0),
                  _Elapsed(recorder: recorder, style: TextStyle(color: colors.onSurface, fontSize: 15.0)),
                  const Spacer(),
                  if (state.isLocked)
                    IconButton(
                      onPressed: onCancel,
                      icon: Icon(Icons.delete_outline_rounded, color: colors.error),
                    )
                  else
                    IgnorePointer(
                      child: Opacity(
                        opacity: 1.0 - state.slide * 0.8,
                        child: Transform.translate(
                          offset: Offset(-state.slide * 40.0, 0.0),
                          child: Text(
                            '‹ ${context.l10n.recordSlideToCancel}',
                            style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6), fontSize: 14.0),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 12.0),
                ],
              ),
            ),
          ),
          if (!state.isLocked)
            Positioned(
              left: button.center.dx - 20.0,
              top: button.top - 96.0 - state.lift * 24.0,
              width: 40.0,
              height: 72.0,
              child: IgnorePointer(
                child: Material(
                  color: colors.surfaceContainerHigh,
                  shape: const StadiumBorder(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline_rounded, size: 20.0, color: colors.onSurface.withValues(alpha: 0.8)),
                      Icon(Icons.keyboard_arrow_up_rounded, size: 20.0, color: colors.onSurface.withValues(alpha: 0.5)),
                    ],
                  ),
                ),
              ),
            ),
          if (state.isLocked)
            Positioned.fromRect(
              rect: button,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onSend,
                  child: const Icon(Icons.arrow_upward_rounded, color: Colors.black),
                ),
              ),
            ),
        ],
      );
    },
  );
}

final class _BlinkingDot extends StatefulWidget {
  final bool isOn;

  const _BlinkingDot({required this.isOn});

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

final class _BlinkingDotState extends State<_BlinkingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: widget.isOn ? _blink : const AlwaysStoppedAnimation(0.3),
    child: Container(
      width: 10.0,
      height: 10.0,
      decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
    ),
  );
}

final class _Elapsed extends StatefulWidget {
  final _HoldRecorder recorder;
  final TextStyle style;

  const _Elapsed({required this.recorder, required this.style});

  @override
  State<_Elapsed> createState() => _ElapsedState();
}

final class _ElapsedState extends State<_Elapsed> {
  late final Timer _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) => setState(() {}));

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ticker;
    final Duration elapsed = widget.recorder.elapsed;
    final int tenths = elapsed.inMilliseconds % 1000 ~/ 100;
    return Text(
      '${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')},$tenths',
      style: widget.style.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
    );
  }
}

final class _CameraCircle extends StatelessWidget {
  final _VideoHoldRecorder recorder;
  final bool isRecording;

  const _CameraCircle({required this.recorder, required this.isRecording});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<CameraController?>(
    valueListenable: recorder.camera,
    builder: (context, camera, _) {
      final bool isReady = camera?.value.isInitialized ?? false;
      final Size preview = camera?.value.previewSize ?? const Size(1.0, 1.0);
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white10,
          border: Border.all(color: isRecording ? Colors.redAccent : Colors.white24, width: 3.0),
        ),
        child: ClipOval(
          child: isReady
              // The camera reports its preview size in landscape, while the phone is held upright.
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(width: preview.height, height: preview.width, child: CameraPreview(camera!)),
                )
              : const Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    },
  );
}

enum _StartResult { started, noPermission, failed }

/// One recording, started on hold and either kept ([stop]) or thrown away ([cancel]).
sealed class _HoldRecorder {
  final AppFileRepository files;
  final Stopwatch _stopwatch = Stopwatch();

  _HoldRecorder(this.files);

  Duration get elapsed => _stopwatch.elapsed;

  Future<_StartResult> start();

  Future<BaseMindNotePiece?> stop();

  Future<void> cancel();

  static Future<void> _delete(Iterable<File> files) async {
    for (final File file in files) {
      if (await file.exists()) await file.delete();
    }
  }
}

final class _AudioHoldRecorder extends _HoldRecorder {
  final AudioRecorder _recorder = AudioRecorder();
  AppFileHandle? _file;
  bool _isDone = false;

  _AudioHoldRecorder(super.files);

  @override
  Future<_StartResult> start() async {
    // Asking for the microphone shows a prompt over the held finger, so this hold only asks.
    if (!await _recorder.hasPermission(request: false)) {
      await _recorder.hasPermission();
      return _StartResult.noPermission;
    }
    try {
      final AppFileHandle file = await files.createAudioFile();
      _file = file;
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
        path: file.file.path,
      );
      _stopwatch.start();
      return _StartResult.started;
    } catch (_) {
      return _StartResult.failed;
    }
  }

  @override
  Future<BaseMindNotePiece?> stop() async {
    if (_isDone) return null;
    _isDone = true;
    _stopwatch.stop();
    final AppFileHandle? file = _file;
    try {
      final String? path = await _recorder.stop();
      if (path == null || file == null) return null;
      final double duration = await const AudioDurationExtractor().extractDuration(file.file.path);
      return MindNoteAudio(appRelativeAbsoulutePath: file.relativePath, durationSeconds: duration);
    } catch (_) {
      await _HoldRecorder._delete([?file?.file]);
      return null;
    } finally {
      await _recorder.dispose();
    }
  }

  @override
  Future<void> cancel() async {
    if (_isDone) return;
    _isDone = true;
    _stopwatch.stop();
    try {
      await _recorder.stop();
    } catch (_) {}
    await _recorder.dispose();
    await _HoldRecorder._delete([?_file?.file]);
  }
}

final class _VideoHoldRecorder extends _HoldRecorder {
  final ValueNotifier<CameraController?> camera = ValueNotifier(null);
  AppFileHandle? _file;
  bool _isRecording = false;
  bool _isDone = false;

  _VideoHoldRecorder(super.files);

  @override
  Future<_StartResult> start() async {
    try {
      final List<CameraDescription> cameras = await availableCameras();
      if (cameras.isEmpty) return _StartResult.failed;
      final CameraDescription front = cameras.firstWhere(
        (description) => description.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final CameraController controller = CameraController(front, ResolutionPreset.high, enableAudio: true);
      await controller.initialize();
      if (_isDone) {
        await controller.dispose();
        return _StartResult.failed;
      }
      camera.value = controller;
      final XFile still = await controller.takePicture();
      final AppFileHandle file = await files.createVideoFile(extension: 'mp4');
      _file = file;
      await File(still.path).copy(videoThumbnailPathFor(file.file.path));
      await File(still.path).delete();
      await controller.startVideoRecording();
      _isRecording = true;
      _stopwatch.start();
      return _StartResult.started;
    } on CameraException catch (error) {
      return error.code.contains('Access') ? _StartResult.noPermission : _StartResult.failed;
    } catch (_) {
      return _StartResult.failed;
    }
  }

  @override
  Future<BaseMindNotePiece?> stop() async {
    if (_isDone) return null;
    _isDone = true;
    _stopwatch.stop();
    final AppFileHandle? file = _file;
    final CameraController? controller = camera.value;
    try {
      if (controller == null || file == null || !_isRecording) return null;
      final XFile recorded = await controller.stopVideoRecording();
      await File(recorded.path).copy(file.file.path);
      await File(recorded.path).delete();
      return MindNoteVideo(appRelativePath: file.relativePath, durationSeconds: elapsed.inMilliseconds / 1000.0);
    } catch (_) {
      await _deleteFiles();
      return null;
    } finally {
      await _release();
    }
  }

  @override
  Future<void> cancel() async {
    if (_isDone) return;
    _isDone = true;
    _stopwatch.stop();
    try {
      if (_isRecording) await camera.value?.stopVideoRecording();
    } catch (_) {}
    await _release();
    await _deleteFiles();
  }

  Future<void> _deleteFiles() async {
    final AppFileHandle? file = _file;
    if (file == null) return;
    await _HoldRecorder._delete([file.file, File(videoThumbnailPathFor(file.file.path))]);
  }

  Future<void> _release() async {
    final CameraController? controller = camera.value;
    camera.value = null;
    await controller?.dispose();
  }
}
