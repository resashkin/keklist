import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:video_player/video_player.dart';

final class RoundVideoThumbnail extends StatelessWidget {
  final MindNoteVideo video;
  final double size;
  final bool showsPlayIcon;

  const RoundVideoThumbnail({super.key, required this.video, required this.size, this.showsPlayIcon = true});

  @override
  Widget build(BuildContext context) {
    final AppFileRepository fileRepository = context.read<AppFileRepository>();
    return SizedBox.square(
      dimension: size,
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Colors.black26),
            FutureBuilder<String>(
              future: fileRepository.resolveAbsolutePath(video.thumbnailRelativePath),
              builder: (context, snapshot) {
                final String? path = snapshot.data;
                if (path == null) return const SizedBox.shrink();
                return Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.videocam_outlined, color: Colors.white54),
                );
              },
            ),
            if (showsPlayIcon)
              Center(child: Icon(Icons.play_arrow_rounded, color: Colors.white70, size: size * 0.3)),
          ],
        ),
      ),
    );
  }
}

final class RoundVideoMessage extends StatefulWidget {
  final MindNoteVideo video;
  final double size;

  const RoundVideoMessage({super.key, required this.video, this.size = 220.0});

  @override
  State<RoundVideoMessage> createState() => _RoundVideoMessageState();
}

final class _RoundVideoMessageState extends State<RoundVideoMessage> {
  VideoPlayerController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    final VideoPlayerController? controller = _controller;
    if (controller == null) return _start();
    controller.value.isPlaying ? await controller.pause() : await controller.play();
  }

  Future<void> _start() async {
    final String path = await context.read<AppFileRepository>().resolveAbsolutePath(widget.video.appRelativePath);
    final VideoPlayerController controller = VideoPlayerController.file(File(path));
    await controller.initialize();
    if (!mounted) {
      await controller.dispose();
      return;
    }
    controller.addListener(() => _onProgress(controller));
    setState(() => _controller = controller);
    await controller.play();
  }

  void _onProgress(VideoPlayerController controller) {
    final VideoPlayerValue value = controller.value;
    if (value.isInitialized && !value.isPlaying && value.position >= value.duration) {
      controller.dispose();
      if (mounted) setState(() => _controller = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? controller = _controller;
    return GestureDetector(
      onTap: _onTap,
      child: SizedBox.square(
        dimension: widget.size,
        child: controller == null
            ? RoundVideoThumbnail(video: widget.video, size: widget.size)
            : Stack(
                fit: StackFit.expand,
                children: [
                  RoundVideoSurface(controller: controller),
                  RoundVideoProgressRing(controller: controller),
                ],
              ),
      ),
    );
  }
}

final class RoundVideoSurface extends StatelessWidget {
  final VideoPlayerController controller;

  const RoundVideoSurface({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final Size size = controller.value.size;
    return ClipOval(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(width: size.width, height: size.height, child: VideoPlayer(controller)),
      ),
    );
  }
}

final class RoundVideoProgressRing extends StatelessWidget {
  final VideoPlayerController controller;

  const RoundVideoProgressRing({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final int total = value.duration.inMilliseconds;
        return CircularProgressIndicator(
          value: total == 0 ? 0.0 : value.position.inMilliseconds / total,
          strokeWidth: 3.0,
          color: Colors.white,
          backgroundColor: Colors.white24,
        );
      },
    );
  }
}
