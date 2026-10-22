import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:keklist/domain/services/emotions/frequent_emotions.dart';
import 'package:keklist/domain/services/entities/emotion.dart';

import 'package:material_ui/material_ui.dart';
import 'package:keklist/presentation/blocs/emotion_bloc/emotion_bloc.dart';
import 'package:keklist/presentation/core/screen/kek_screen_state.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/screens/emotions/emotion_marking_sheet.dart';
import 'package:keklist/presentation/screens/emotions/widgets/emotion_chip.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/presentation/core/widgets/round_video/media_recording.dart';
import 'package:keklist/presentation/core/widgets/round_video/round_video_views.dart';
import 'package:keklist/domain/services/phone_web/phone_web_mode.dart';

final class MindCreatorScreen extends StatefulWidget {
  final Function(String text, List<String> emotionIds) onDone;
  final String? hintText;

  const MindCreatorScreen({super.key, required this.onDone, this.hintText});

  @override
  State<MindCreatorScreen> createState() => _MindCreatorScreenState();
}

final class _MindCreatorScreenState extends KekWidgetState<MindCreatorScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final List<String> _selectedEmotionIds = [];
  BaseMindNotePiece? _attachedMedia;

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _removeAttachedMedia();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDone(_composeNote(), List.of(_selectedEmotionIds));
            },
            child: Text(context.l10n.save, style: const TextStyle(fontSize: 16.0, color: Colors.blueAccent)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_attachedMedia case final BaseMindNotePiece media)
              _AttachedMediaPreview(media: media, onRemove: _removeAttachedMedia),
            TextField(
              autofocus: true,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              controller: _textEditingController,
              style: const TextStyle(fontSize: 20.0),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(12.0),
                border: InputBorder.none,
                hintText: widget.hintText ?? context.l10n.writeSomething,
                suffixIcon: _attachedMedia == null && !kIsPhoneWeb
                    ? MediaRecordToggleButton(
                        onRecordAudio: () => _attach(MediaRecording.recordAudio),
                        onRecordVideo: () => _attach(MediaRecording.recordVideo),
                      )
                    : null,
              ),
            ),
            _CreatorEmotionsRow(
              selectedIds: _selectedEmotionIds,
              onToggle: (id) => setState(
                () => _selectedEmotionIds.contains(id) ? _selectedEmotionIds.remove(id) : _selectedEmotionIds.add(id),
              ),
              onOpenAll: _openMarkingSheet,
            ),
          ],
        ),
      ),
    );
  }

  void _openMarkingSheet() {
    EmotionMarkingSheet.show(
      context: context,
      initialSelectedIds: _selectedEmotionIds.toSet(),
      onSelectionChanged: (ids) => setState(
        () => _selectedEmotionIds
          ..clear()
          ..addAll(ids),
      ),
    );
  }

  Future<void> _attach(Future<BaseMindNotePiece?> Function(BuildContext) record) async {
    final BaseMindNotePiece? media = await record(context);
    if (media == null || !mounted) return;
    setState(() => _attachedMedia = media);
  }

  // A discarded recording is never saved into a mind, so its file can go right away.
  Future<void> _removeAttachedMedia() async {
    final BaseMindNotePiece? media = _attachedMedia;
    setState(() => _attachedMedia = null);
    if (media == null) return;
    final AppFileRepository fileRepository = context.read<AppFileRepository>();
    for (final String path in MindNoteContent.fromPieces([media]).mediaFilePaths) {
      final File file = File(await fileRepository.resolveAbsolutePath(path));
      if (await file.exists()) await file.delete();
    }
  }

  String _composeNote() {
    final String text = _textEditingController.text.trim();
    final BaseMindNotePiece? media = _attachedMedia;
    return MindNoteContent.fromPieces([
      ?media,
      if (text.isNotEmpty) MindNoteText(media == null ? text : '\n$text'),
    ]).toRawNoteString();
  }
}

final class _CreatorEmotionsRow extends StatelessWidget {
  final List<String> selectedIds;
  final ValueChanged<String> onToggle;
  final VoidCallback onOpenAll;

  const _CreatorEmotionsRow({required this.selectedIds, required this.onToggle, required this.onOpenAll});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmotionBloc, EmotionState>(
      builder: (context, state) {
        if (state is! EmotionsList) return const SizedBox.shrink();
        final List<Emotion> frequent = FrequentEmotions.pick(
          minds: context.read<MindRepository>().values,
          activeEmotions: state.activeEmotions,
          fallback: state.rootEmotions,
        );
        final List<Emotion> selected = selectedIds.map(state.byId).whereType<Emotion>().toList();
        final List<Emotion> chips = [...frequent, ...selected.where((emotion) => !frequent.contains(emotion))];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              for (final Emotion emotion in chips)
                EmotionChip(
                  emojis: [emotion.emoji],
                  label: emotion.title,
                  selected: selectedIds.contains(emotion.id),
                  onTap: () => onToggle(emotion.id),
                ),
              EmotionAddChip(label: context.l10n.allEmotions, onTap: onOpenAll),
            ],
          ),
        );
      },
    );
  }
}

final class _AttachedMediaPreview extends StatelessWidget {
  final BaseMindNotePiece media;
  final VoidCallback onRemove;

  const _AttachedMediaPreview({required this.media, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final Widget preview = switch (media) {
      MindNoteVideo video => RoundVideoMessage(video: video, size: 180.0),
      MindNoteAudio audio => Chip(
          avatar: const Icon(Icons.mic, size: 18.0),
          label: Text(_formatDuration(audio.duration ?? Duration.zero)),
        ),
      _ => const SizedBox.shrink(),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          preview,
          IconButton(icon: const Icon(Icons.delete_outline), tooltip: context.l10n.removeMedia, onPressed: onRemove),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) =>
      '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
}
