import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/services/audio_duration_extractor.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/mind_audio_recorder_sheet.dart';
import 'package:keklist/presentation/core/widgets/round_video/round_video_recorder_screen.dart';

final class MediaRecording {
  static Future<MindNoteAudio?> recordAudio(BuildContext context) async {
    final AppFileRepository fileRepository = context.read<AppFileRepository>();
    final AudioRecordingResult recordedPath = await showModalBottomSheet<AudioRecordingResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: MindAudioRecorderSheet(fileRepository: fileRepository),
      ),
    );
    final String relativePath = recordedPath?.trim() ?? '';
    if (relativePath.isEmpty) return null;
    final String absolutePath = await fileRepository.resolveAbsolutePath(relativePath);
    final double duration = await const AudioDurationExtractor().extractDuration(absolutePath);
    return MindNoteAudio(appRelativeAbsoulutePath: relativePath, durationSeconds: duration);
  }

  static Future<MindNoteVideo?> recordVideo(BuildContext context) async {
    final RoundVideoRecordingResult? result =
        await RoundVideoRecorderScreen.show(context, fileRepository: context.read<AppFileRepository>());
    if (result == null) return null;
    return MindNoteVideo(appRelativePath: result.relativePath, durationSeconds: result.durationSeconds);
  }
}

enum MediaRecordMode { audio, video }

final class MediaRecordToggleButton extends StatefulWidget {
  final VoidCallback onRecordAudio;
  final VoidCallback onRecordVideo;
  final Color? color;

  const MediaRecordToggleButton({super.key, required this.onRecordAudio, required this.onRecordVideo, this.color});

  @override
  State<MediaRecordToggleButton> createState() => _MediaRecordToggleButtonState();
}

final class _MediaRecordToggleButtonState extends State<MediaRecordToggleButton> {
  MediaRecordMode _mode = MediaRecordMode.audio;

  void _switchMode() {
    final MediaRecordMode next = _mode == MediaRecordMode.audio ? MediaRecordMode.video : MediaRecordMode.audio;
    setState(() => _mode = next);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
            next == MediaRecordMode.audio ? context.l10n.holdToRecordAudio : context.l10n.holdToRecordVideo,
          ),
        ),
      );
  }

  void _record() => _mode == MediaRecordMode.audio ? widget.onRecordAudio() : widget.onRecordVideo();

  @override
  Widget build(BuildContext context) {
    final bool isAudio = _mode == MediaRecordMode.audio;
    // No tooltip: it would claim the long-press that starts recording.
    return GestureDetector(
      onLongPress: _record,
      child: IconButton(
        onPressed: _switchMode,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: Icon(
            isAudio ? Icons.mic : Icons.videocam_outlined,
            key: ValueKey(_mode),
            color: widget.color ?? Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}
