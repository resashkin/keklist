import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/entities/emotion.dart';

import 'package:material_ui/material_ui.dart';
import 'package:keklist/presentation/blocs/emotion_bloc/emotion_bloc.dart';
import 'package:keklist/presentation/core/screen/kek_screen_state.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/shake/shake_to_tweak_mixin.dart';
import 'package:keklist/presentation/screens/emotions/emotion_marking_sheet.dart';
import 'package:keklist/presentation/screens/mind_creator/mind_creator_tweak_sheet.dart';
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

final class _MindCreatorScreenState extends KekWidgetState<MindCreatorScreen> with ShakeToTweakMixin {
  final TextEditingController _textEditingController = TextEditingController();
  final List<String> _selectedEmotionIds = [];
  BaseMindNotePiece? _attachedMedia;

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(_textChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  bool _hasText = false;

  void _textChanged() {
    final bool hasText = _textEditingController.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  String get shakeScreenId => ShakeScreenIds.creator;

  @override
  void onShakeToTweak() => MindCreatorTweakSheet.show(context);

  MindEmotionsPrompt get _emotionsPrompt => switch (context.watch<SettingsBloc>().state) {
    SettingsDataState(:final settings) => settings.mindEmotionsPrompt,
    _ => MindEmotionsPrompt.afterSave,
  };

  /// In the "after save" mode the emotions come right after Save, before the mind is created.
  Future<void> _save(MindEmotionsPrompt prompt) async {
    if (prompt == MindEmotionsPrompt.afterSave && _selectedEmotionIds.isEmpty) {
      FocusScope.of(context).unfocus();
      await EmotionMarkingSheet.show(
        context: context,
        initialSelectedIds: const {},
        onSelectionChanged: (ids) => _selectedEmotionIds
          ..clear()
          ..addAll(ids),
      );
      if (!mounted) return;
    }
    Navigator.of(context).pop();
    widget.onDone(_composeNote(), List.of(_selectedEmotionIds));
  }

  @override
  Widget build(BuildContext context) {
    final MindEmotionsPrompt emotionsPrompt = _emotionsPrompt;
    final bool canRecord = _attachedMedia == null && !_hasText && !kIsPhoneWeb;
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
            onPressed: () => _save(emotionsPrompt),
            child: Text(context.l10n.save, style: const TextStyle(fontSize: 16.0, color: Colors.blueAccent)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Sits right above the keyboard.
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 12.0),
            child: SizedBox(
              height: 52.0,
              child: Row(
                children: [
                  if (emotionsPrompt == MindEmotionsPrompt.button)
                    _EmotionsButton(selectedIds: _selectedEmotionIds, onTap: _openMarkingSheet),
                  const Spacer(),
                  if (canRecord)
                    MediaRecordToggleButton(
                      isFilled: true,
                      onRecordAudio: () => _attach(MediaRecording.recordAudio),
                      onRecordVideo: () => _attach(MediaRecording.recordVideo),
                    ),
                ],
              ),
            ),
          ),
        ],
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

/// Opens the emotion sheet; shows the chosen emojis once there are some.
final class _EmotionsButton extends StatelessWidget {
  final List<String> selectedIds;
  final VoidCallback onTap;

  const _EmotionsButton({required this.selectedIds, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final EmotionState state = context.watch<EmotionBloc>().state;
    final List<String> emojis = state is EmotionsList
        ? selectedIds.map(state.byId).whereType<Emotion>().map((emotion) => emotion.emoji).toList()
        : const [];
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(minimumSize: const Size(52.0, 52.0), shape: const StadiumBorder()),
      icon: emojis.isEmpty ? const Icon(Icons.add_reaction_outlined) : null,
      label: Text(emojis.isEmpty ? context.l10n.emotions : emojis.join(' ')),
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
