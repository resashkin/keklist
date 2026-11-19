import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/presentation/core/helpers/keyboard_shortcuts.dart';
import 'package:keklist/domain/services/analytics/analytics.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/services/entities/emotion.dart';

import 'package:material_ui/material_ui.dart';
import 'package:keklist/presentation/core/helpers/emotion_colors.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/mind_audio_wave.dart';
import 'package:keklist/presentation/blocs/emotion_bloc/emotion_bloc.dart';
import 'package:keklist/presentation/core/screen/kek_screen_state.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/screens/emotions/emotion_marking_sheet.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/presentation/core/widgets/round_video/media_recording.dart';
import 'package:keklist/presentation/core/widgets/round_video/round_video_views.dart';
import 'package:keklist/domain/services/phone_web/phone_web_mode.dart';
import 'package:keklist/presentation/core/widgets/deferred_autofocus.dart';
import 'package:keklist/presentation/core/widgets/images/mind_images.dart';

final class MindCreatorScreen extends StatefulWidget {
  final Function(String text, List<String> emotionIds) onDone;
  final String? hintText;

  /// Set when editing: the text is prefilled, and recording and emotions are hidden.
  final String? initialText;

  /// Images the new mind starts with, already saved in the app files.
  final List<MindNoteImage> initialImages;

  const MindCreatorScreen({
    super.key,
    required this.onDone,
    this.hintText,
    this.initialText,
    this.initialImages = const [],
  });

  /// Edits an existing text full-screen; resolves to the new text, or null when closed without saving.
  static Future<String?> editText(BuildContext context, {required String initialText}) async {
    String? result;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => MindCreatorScreen(initialText: initialText, onDone: (text, _) => result = text),
      ),
    );
    return result;
  }

  @override
  State<MindCreatorScreen> createState() => _MindCreatorScreenState();
}

final class _MindCreatorScreenState extends KekWidgetState<MindCreatorScreen> {
  late final TextEditingController _textEditingController = TextEditingController(text: widget.initialText)
    ..selection = TextSelection.collapsed(offset: widget.initialText?.length ?? 0);
  final List<String> _selectedEmotionIds = [];
  BaseMindNotePiece? _attachedMedia;
  late List<MindNoteImage> _images = List.of(widget.initialImages);

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

  late bool _hasText = _textEditingController.text.isNotEmpty;

  bool get _isEditing => widget.initialText != null;

  void _textChanged() {
    final bool hasText = _textEditingController.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  void _save() {
    if (_isEditing) {
      Navigator.of(context).pop();
      widget.onDone(_textEditingController.text.trim(), const []);
      return;
    }
    Navigator.of(context).pop();
    widget.onDone(_composeNote(), List.of(_selectedEmotionIds));
  }

  @override
  Widget build(BuildContext context) {
    final bool canRecord = _attachedMedia == null && !_hasText && !kIsPhoneWeb && !_isEditing;
    final bool canAddImages = _images.length < kMaxMindImages && !kIsPhoneWeb && !_isEditing;
    final bool canMarkEmotions = !_isEditing;
    return CallbackShortcuts(
      bindings: {
        commandShortcut(LogicalKeyboardKey.enter): _save,
        const SingleActivator(LogicalKeyboardKey.escape): _close,
      },
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: IconButton(icon: const Icon(Icons.close), onPressed: _close),
          actions: [
            TextButton(
              onPressed: _save,
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
                      _AttachedMediaPreview(
                        media: media,
                        onRemove: _removeAttachedMedia,
                        emotionId: _selectedEmotionIds.firstOrNull,
                      ),
                    if (_images.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: MindImageStrip(images: _images, onChanged: _setImages),
                      ),
                    DeferredAutofocus(
                      builder: (_, focusNode) => TextField(
                        focusNode: focusNode,
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
                    ),
                  ],
                ),
              ),
            ),
            // Right above the keyboard, or clear of the rounded corners and the home indicator without it.
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 12.0),
                child: SizedBox(
                  height: 52.0,
                  child: Row(
                    children: [
                      const Spacer(),
                      if (canMarkEmotions)
                        Padding(
                          padding: EdgeInsets.only(right: canAddImages || canRecord ? 12.0 : 0.0),
                          child: _EmotionsButton(selectedIds: _selectedEmotionIds, onTap: _openMarkingSheet),
                        ),
                      if (canAddImages)
                        Padding(
                          padding: EdgeInsets.only(right: canRecord ? 12.0 : 0.0),
                          child: IconButton.filled(
                            onPressed: _addImages,
                            tooltip: context.l10n.attachImages,
                            icon: const Icon(Icons.add_photo_alternate_outlined, color: Colors.black),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              fixedSize: const Size.square(52.0),
                              minimumSize: const Size.square(52.0),
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ),
                      if (canRecord)
                        MediaRecordToggleButton(
                          isFilled: true,
                          onRecorded: (media) => setState(() => _attachedMedia = media),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _close() {
    _removeAttachedMedia();
    _setImages(const []);
    Navigator.of(context).pop();
  }

  Future<void> _addImages() async {
    final List<MindNoteImage> picked = await pickMindImages(
      context,
      limit: kMaxMindImages - _images.length,
      target: ImageAttachTarget.mind,
    );
    if (picked.isEmpty || !mounted) return;
    setState(() => _images = [..._images, ...picked]);
  }

  // Images taken out before saving never reach a mind, so their files go right away.
  void _setImages(List<MindNoteImage> images) {
    final Iterable<MindNoteImage> removed = _images.where((image) => !images.contains(image)).toList();
    setState(() => _images = List.of(images));
    MindImageAttaching.discard(context.read<AppFileRepository>(), removed);
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
    final List<BaseMindNotePiece> attachments = [?_attachedMedia, ..._images];
    _images = const [];
    return MindNoteContent.fromPieces([
      ...attachments,
      if (text.isNotEmpty) MindNoteText(attachments.isEmpty ? text : '\n$text'),
    ]).toRawNoteString();
  }
}

/// Opens the emotion sheet. A round white button like the attach ones; once emotions are chosen it grows into a pill
/// of their emojis.
final class _EmotionsButton extends StatelessWidget {
  static const double _size = 52.0;

  final List<String> selectedIds;
  final VoidCallback onTap;

  const _EmotionsButton({required this.selectedIds, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final EmotionState state = context.watch<EmotionBloc>().state;
    final List<String> emojis = state is EmotionsList
        ? selectedIds.map(state.byId).whereType<Emotion>().map((emotion) => emotion.emoji).toList()
        : const [];
    return Tooltip(
      message: context.l10n.emotions,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Container(
            height: _size,
            constraints: const BoxConstraints(minWidth: _size),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: emojis.isEmpty ? 0.0 : 12.0),
              alignment: Alignment.center,
              decoration: const ShapeDecoration(shape: StadiumBorder(), color: Colors.white),
              child: emojis.isEmpty
                  ? const Icon(Icons.add_reaction_outlined, color: Colors.black)
                  : Text(emojis.join(' '), style: const TextStyle(fontSize: 22.0)),
            ),
          ),
        ),
      ),
    );
  }
}

final class _AttachedMediaPreview extends StatelessWidget {
  final BaseMindNotePiece media;
  final VoidCallback onRemove;

  /// The first chosen emotion, which colors the audio's ▶ as in the story.
  final String? emotionId;

  const _AttachedMediaPreview({required this.media, required this.onRemove, this.emotionId});

  @override
  Widget build(BuildContext context) {
    final Widget delete = IconButton(
      icon: const Icon(Icons.delete_outline),
      tooltip: context.l10n.removeMedia,
      onPressed: onRemove,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 4.0, 8.0),
      child: switch (media) {
        // As in the story: ▶ on the left, the waveform across the width and the time, then delete.
        MindNoteAudio audio => Row(
          spacing: 4.0,
          children: [
            Expanded(
              child: MindAudioWave(
                key: ValueKey(audio.appRelativeAbsoulutePath),
                audio: audio,
                color: _accentOf(context),
              ),
            ),
            delete,
          ],
        ),
        MindNoteVideo video => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RoundVideoMessage(video: video, size: 180.0),
            delete,
          ],
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Color _accentOf(BuildContext context) => context.select<EmotionBloc, Color>((bloc) {
    final EmotionState state = bloc.state;
    final String? id = emotionId;
    if (state is! EmotionsList || id == null) return kEmotionPalette.last;
    return emotionColorsOf(state.emotions)[id] ?? kEmotionPalette.last;
  });
}
