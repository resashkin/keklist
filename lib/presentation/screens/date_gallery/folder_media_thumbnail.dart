import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:keklist/native/android/media_folder_channel.dart';
import 'package:keklist/presentation/screens/date_gallery/folder_media_item.dart';

final class FolderMediaThumbnail extends StatefulWidget {
  final FolderMediaItem item;

  const FolderMediaThumbnail({super.key, required this.item});

  @override
  State<FolderMediaThumbnail> createState() => _FolderMediaThumbnailState();
}

final class _FolderMediaThumbnailState extends State<FolderMediaThumbnail> {
  Uint8List? _bytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final item = widget.item;
    if (item is FolderFileItem) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    if (item is FolderSafItem) {
      final Uint8List? bytes;
      if (item.isVideo) {
        bytes = await MediaFolderChannel.getVideoThumbnail(item.uri.toString());
      } else {
        bytes = await MediaFolderChannel.getDocumentThumbnail(item.uri.toString(), 300, 300);
      }
      if (mounted) setState(() { _bytes = bytes; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    switch (item) {
      case FolderFileItem(:final file):
        if (item.isVideo) {
          return Container(
            color: Colors.black12,
            child: const Center(child: Icon(Icons.play_circle_outline, size: 48, color: Colors.white)),
          );
        }
        return Image.file(file, fit: BoxFit.cover);
      case FolderSafItem():
        if (_loading) {
          final color = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);
          return Container(color: color)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1200.ms, color: Colors.white24);
        }
        final bytes = _bytes;
        if (bytes != null) return Image.memory(bytes, fit: BoxFit.cover);
        return Container(
          color: Colors.black12,
          child: Center(
            child: Icon(
              item.isVideo ? Icons.play_circle_outline : Icons.image_outlined,
              color: Colors.white54,
              size: 32,
            ),
          ),
        );
    }
  }
}
