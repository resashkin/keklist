import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/presentation/core/helpers/keyboard_shortcuts.dart';
import 'package:keklist/domain/services/analytics/analytics.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/entities/emotion.dart';

import 'package:material_ui/material_ui.dart';
import 'package:keklist/presentation/core/widgets/sound/audio_waveform.dart';
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

final class _MindCreatorScreenState extends KekWidgetState<MindCreatorScreen> with ShakeToTweakMixin {
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
    if (_isEditing) {
      Navigator.of(context).pop();
      widget.onDone(_textEditingController.text.trim(), const []);
      return;
    }
    if (prompt == MindEmotionsPrompt.afterSave && _selectedEmotionIds.isEmpty) {
      FocusScope.of(context).unfocus();
      await EmotionMarkingSheet.show(
        context: context,
        initialSelectedIds: const {},
        showsSaveButton: true,
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
    final bool canRecord = _attachedMedia == null && !_hasText && !kIsPhoneWeb && !_isEditing;
    final bool canAddImages = _images.length < kMaxMindImages && !kIsPhoneWeb && !_isEditing;
    return CallbackShortcuts(
      bindings: {
        commandShortcut(LogicalKeyboardKey.enter): () => _save(emotionsPrompt),
        const SingleActivator(LogicalKeyboardKey.escape): _close,
      },
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: IconButton(icon: const Icon(Icons.close), onPressed: _close),
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
                      if (emotionsPrompt == MindEmotionsPrompt.button && !_isEditing)
                        _EmotionsButton(selectedIds: _selectedEmotionIds, onTap: _openMarkingSheet),
                      const Spacer(),
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
        label: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8.0,
          children: [
            SizedBox(
              width: 120.0,
              height: 22.0,
              child: AudioWaveform(
                path: audio.appRelativeAbsoulutePath,
                color: Theme.of(context).colorScheme.onSurface,
                barWidth: 2.0,
                gap: 1.5,
              ),
            ),
            Text(_formatDuration(audio.duration ?? Duration.zero)),
          ],
        ),
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
