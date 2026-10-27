import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';
import 'package:keklist/presentation/core/widgets/round_video/media_recording.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/mind_story_details.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_context_menu/super_context_menu.dart';

/// Comments of a story mind, Instagram-reply style: the story shows only the newest, and the whole thread with
/// its input opens in [MindCommentsSheet].
abstract final class MindComments {
  static List<Mind> of(BuildContext context, String rootId) {
    final MindState state = context.read<MindBloc>().state;
    return state is MindList ? mindReflectionsOf(state.values, rootId) : const [];
  }

  static void save(BuildContext context, Mind root, String text) {
    if (text.trim().isEmpty) return;
    context.read<MindBloc>().add(
      MindCreate(dayIndex: root.dayIndex, mindContent: MindNoteContent.parse(text.trim()).pieces, rootId: root.id),
    );
  }

  static Future<void> record(
    BuildContext context,
    Mind root,
    Future<BaseMindNotePiece?> Function(BuildContext) record,
  ) async {
    final BaseMindNotePiece? media = await record(context);
    if (media == null || !context.mounted) return;
    context.read<MindBloc>().add(MindCreate(dayIndex: root.dayIndex, mindContent: [media], rootId: root.id));
  }
}

/// "💬 3 · the newest comment…  ›" at the bottom of a story, or "💬 Comment…" without any; a tap opens the thread.
final class MindCommentPreview extends StatelessWidget {
  final Mind root;
  final VoidCallback onTap;

  const MindCommentPreview({super.key, required this.root, required this.onTap});

  static const double height = 40.0;

  @override
  Widget build(BuildContext context) {
    final Color foreground = storyColorsOf(context).foreground;
    return BlocBuilder<MindBloc, MindState>(
      buildWhen: (_, current) => current is MindList,
      builder: (context, state) {
        final List<Mind> comments = state is MindList ? mindReflectionsOf(state.values, root.id) : const [];
        final Mind? newest = comments.lastOrNull;
        final String text = newest?.plainNote.trim() ?? context.l10n.viewerCommentHint;
        final Color muted = foreground.withValues(alpha: 0.6);
        // Opaque so the emotion texture never runs through the line.
        return Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 0.0),
          child: Material(
            color: Color.alphaBlend(foreground.withValues(alpha: 0.1), storyColorsOf(context).background),
            shape: const StadiumBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                height: height - 4.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Row(
                    spacing: 8.0,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 16.0, color: muted),
                      if (comments.isNotEmpty)
                        Text(
                          '${comments.length}',
                          style: TextStyle(color: muted, fontSize: 14.0, fontWeight: FontWeight.w600),
                        ),
                      if (newest != null && text.isEmpty && newest.noteContent.hasMedia)
                        Icon(
                          newest.noteContent.hasVideo ? Icons.videocam_outlined : Icons.graphic_eq,
                          size: 16.0,
                          color: muted,
                        ),
                      Expanded(
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: newest == null ? muted : foreground.withValues(alpha: 0.85),
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 18.0, color: muted),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The whole thread of a mind in chat order, newest right above its own input; long-press a comment for its menu.
final class MindCommentsSheet extends StatefulWidget {
  final Mind root;
  final List<MenuElement> Function(Mind comment) menu;

  const MindCommentsSheet({super.key, required this.root, required this.menu});

  static Future<void> show(
    BuildContext context, {
    required Mind root,
    required List<MenuElement> Function(Mind comment) menu,
  }) => KekSheet.show<void>(
    context: context,
    builder: (_) => MindCommentsSheet(root: root, menu: menu),
  );

  @override
  State<MindCommentsSheet> createState() => _MindCommentsSheetState();
}

final class _MindCommentsSheetState extends State<MindCommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  // Opened from "Comment…" on a mind without comments: straight to typing.
  late final bool _startsEmpty = MindComments.of(context, widget.root.id).isEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // As tall as the thread, up to the sheet's height limit, then it scrolls.
    return KekSheetScaffold(
      title: context.l10n.viewerComments,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: BlocBuilder<MindBloc, MindState>(
              buildWhen: (_, current) => current is MindList,
              builder: (context, state) {
                final bool isEmpty = state is! MindList || mindReflectionsOf(state.values, widget.root.id).isEmpty;
                if (isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Text(context.l10n.viewerNoComments, style: TextStyle(color: Theme.of(context).hintColor)),
                  );
                }
                // Reversed with a single child, the thread starts scrolled to its newest end.
                return ListView(
                  shrinkWrap: true,
                  reverse: true,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                  children: [MindReflectionsList(mind: widget.root, menu: widget.menu)],
                );
              },
            ),
          ),
          MindCommentBar(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: _startsEmpty,
            onSend: () {
              MindComments.save(context, widget.root, _controller.text);
              _controller.clear();
            },
            onRecordAudio: () => MindComments.record(context, widget.root, MediaRecording.recordAudio),
            onRecordVideo: () => MindComments.record(context, widget.root, MediaRecording.recordVideo),
          ),
        ],
      ),
    );
  }
}

/// The chat's input bar for comments: a rounded field and one round white button that sends the text, or records
/// audio or video (tap switches, hold records) while the field is empty.
final class MindCommentBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final VoidCallback onRecordAudio;
  final VoidCallback onRecordVideo;
  final bool autofocus;

  const MindCommentBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.onRecordAudio,
    required this.onRecordVideo,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasText = controller.text.trim().isNotEmpty;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 4.0, 8.0, 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 4.0,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: autofocus,
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: context.l10n.viewerCommentHint,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24.0), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                ),
              ),
            ),
            SizedBox.square(
              dimension: 52.0,
              child: hasText
                  ? IconButton.filled(
                      onPressed: onSend,
                      style: IconButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                      icon: const Icon(Icons.arrow_upward_rounded),
                    )
                  : MediaRecordToggleButton(isFilled: true, onRecordAudio: onRecordAudio, onRecordVideo: onRecordVideo),
            ),
          ],
        ),
      ),
    );
  }
}
