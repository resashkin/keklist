import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:video_player/video_player.dart';

const double _kCircleMaxSize = 320.0;
const double _kCircleHorizontalInset = 48.0;

final class RoundVideoRecordingResult {
  final String relativePath;
  final double durationSeconds;

  const RoundVideoRecordingResult({required this.relativePath, required this.durationSeconds});
}

final class RoundVideoRecorderScreen extends StatefulWidget {
  final AppFileRepository fileRepository;

  const RoundVideoRecorderScreen({super.key, required this.fileRepository});

  static Future<RoundVideoRecordingResult?> show(BuildContext context, {required AppFileRepository fileRepository}) =>
      Navigator.of(context).push<RoundVideoRecordingResult>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => RoundVideoRecorderScreen(fileRepository: fileRepository),
        ),
      );

  @override
  State<RoundVideoRecorderScreen> createState() => _RoundVideoRecorderScreenState();
}

enum _RecorderPhase { initializing, unavailable, ready, recording, saving, preview }

final class _RoundVideoRecorderScreenState extends State<RoundVideoRecorderScreen> {
  List<CameraDescription> _cameras = const [];
  CameraController? _camera;
  VideoPlayerController? _preview;
  AppFileHandle? _recordedVideo;
  _RecorderPhase _phase = _RecorderPhase.initializing;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _initializeCameras();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _camera?.dispose();
    _preview?.dispose();
    super.dispose();
  }

  Future<void> _initializeCameras() async {
    try {
      _cameras = await availableCameras();
    } on CameraException {
      _cameras = const [];
    }
    if (_cameras.isEmpty) {
      if (mounted) setState(() => _phase = _RecorderPhase.unavailable);
      return;
    }
    final CameraDescription front = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );
    await _openCamera(front);
  }

  Future<void> _openCamera(CameraDescription description) async {
    final CameraController? previous = _camera;
    final CameraController controller = CameraController(description, ResolutionPreset.high, enableAudio: true);
    try {
      await controller.initialize();
    } on CameraException {
      await controller.dispose();
      if (mounted) setState(() => _phase = _RecorderPhase.unavailable);
      return;
    }
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() {
      _camera = controller;
      _phase = _RecorderPhase.ready;
    });
    await previous?.dispose();
  }

  Future<void> _flipCamera() async {
    final CameraController? camera = _camera;
    if (camera == null || _cameras.length < 2) return;
    final CameraDescription next = _cameras.firstWhere(
      (description) => description.lensDirection != camera.description.lensDirection,
      orElse: () => camera.description,
    );
    setState(() => _phase = _RecorderPhase.initializing);
    await _openCamera(next);
  }

  Future<void> _startRecording() async {
    final CameraController? camera = _camera;
    if (camera == null) return;
    try {
      final XFile still = await camera.takePicture();
      await camera.startVideoRecording();
      _recordedVideo = await widget.fileRepository.createVideoFile(extension: 'mp4');
      await _saveThumbnail(still, video: _recordedVideo!);
    } on CameraException {
      _showError();
      return;
    }
    _stopwatch
      ..reset()
      ..start();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => setState(() {}));
    setState(() => _phase = _RecorderPhase.recording);
  }

  Future<void> _saveThumbnail(XFile still, {required AppFileHandle video}) async {
    await File(still.path).copy(videoThumbnailPathFor(video.file.path));
    await File(still.path).delete();
  }

  Future<void> _stopRecording() async {
    final CameraController? camera = _camera;
    final AppFileHandle? target = _recordedVideo;
    if (camera == null || target == null) return;
    _ticker?.cancel();
    _stopwatch.stop();
    setState(() => _phase = _RecorderPhase.saving);
    try {
      final XFile recorded = await camera.stopVideoRecording();
      await File(recorded.path).copy(target.file.path);
      await File(recorded.path).delete();
    } on CameraException {
      _showError();
      return;
    }
    final VideoPlayerController preview = VideoPlayerController.file(target.file);
    await preview.initialize();
    await preview.setLooping(true);
    if (!mounted) {
      await preview.dispose();
      return;
    }
    setState(() {
      _preview = preview;
      _phase = _RecorderPhase.preview;
    });
    await preview.play();
  }

  Future<void> _retake() async {
    await _preview?.dispose();
    _preview = null;
    await _deleteRecording();
    setState(() => _phase = _RecorderPhase.ready);
  }

  void _use() {
    final AppFileHandle? recorded = _recordedVideo;
    final VideoPlayerController? preview = _preview;
    if (recorded == null || preview == null) return;
    _recordedVideo = null;
    Navigator.of(context).pop(
      RoundVideoRecordingResult(
        relativePath: recorded.relativePath,
        durationSeconds: preview.value.duration.inMilliseconds / 1000.0,
      ),
    );
  }

  Future<void> _close() async {
    if (_phase == _RecorderPhase.recording) await _camera?.stopVideoRecording();
    await _deleteRecording();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _deleteRecording() async {
    final AppFileHandle? recorded = _recordedVideo;
    _recordedVideo = null;
    if (recorded == null) return;
    for (final File file in [recorded.file, File(videoThumbnailPathFor(recorded.file.path))]) {
      if (await file.exists()) await file.delete();
    }
  }

  void _showError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.roundVideoRecordError)));
    setState(() => _phase = _RecorderPhase.ready);
  }

  @override
  Widget build(BuildContext context) {
    final double circleSize =
        (MediaQuery.sizeOf(context).width - _kCircleHorizontalInset).clamp(0.0, _kCircleMaxSize);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          leading: IconButton(icon: const Icon(Icons.close), onPressed: _close),
          title: _phase == _RecorderPhase.recording ? Text(_elapsedLabel()) : null,
          centerTitle: true,
          actions: [
            if (_phase == _RecorderPhase.ready && _cameras.length > 1)
              IconButton(icon: const Icon(Icons.cameraswitch_outlined), onPressed: _flipCamera),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: Center(child: _buildCircle(circleSize))),
              Padding(padding: const EdgeInsets.only(bottom: 32.0), child: _buildControls()),
            ],
          ),
        ),
      ),
    );
  }

  String _elapsedLabel() {
    final int seconds = _stopwatch.elapsed.inSeconds;
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  Widget _buildCircle(double size) {
    final Widget content = switch (_phase) {
      _RecorderPhase.unavailable => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              context.l10n.roundVideoCameraUnavailable,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
      _RecorderPhase.preview => _coverFit(_preview!.value.size, VideoPlayer(_preview!)),
      _ when _camera?.value.isInitialized ?? false =>
        _coverFit(_camera!.value.previewSize ?? const Size(1, 1), CameraPreview(_camera!), isPreviewLandscape: true),
      _ => const Center(child: CircularProgressIndicator(color: Colors.white)),
    };
    final bool isRecording = _phase == _RecorderPhase.recording;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white10,
        border: Border.all(color: isRecording ? Colors.redAccent : Colors.white24, width: 3.0),
      ),
      child: ClipOval(child: content),
    );
  }

  // The camera reports its preview size in landscape, while the phone is held in portrait.
  Widget _coverFit(Size size, Widget child, {bool isPreviewLandscape = false}) {
    final Size oriented = isPreviewLandscape ? Size(size.height, size.width) : size;
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(width: oriented.width, height: oriented.height, child: child),
    );
  }

  Widget _buildControls() {
    return switch (_phase) {
      _RecorderPhase.preview => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: _retake,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.roundVideoRetake),
            ),
            FilledButton.icon(onPressed: _use, icon: const Icon(Icons.check), label: Text(context.l10n.roundVideoUse)),
          ],
        ),
      _RecorderPhase.ready || _RecorderPhase.recording => _RecordButton(
          isRecording: _phase == _RecorderPhase.recording,
          onTap: _phase == _RecorderPhase.recording ? _stopRecording : _startRecording,
        ),
      _ => const SizedBox(height: 72.0),
    };
  }
}

final class _RecordButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onTap;

  const _RecordButton({required this.isRecording, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72.0,
        height: 72.0,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4.0)),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isRecording ? 28.0 : 56.0,
            height: isRecording ? 28.0 : 56.0,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(isRecording ? 6.0 : 28.0),
            ),
          ),
        ),
      ),
    );
  }
}
