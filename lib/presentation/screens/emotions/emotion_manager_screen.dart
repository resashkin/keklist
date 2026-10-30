import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/presentation/blocs/emotion_bloc/emotion_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/glass_app_bar.dart';
import 'package:keklist/presentation/core/widgets/glass_capsule_button.dart';
import 'package:keklist/presentation/screens/emotions/emotion_archived_screen.dart';
import 'package:keklist/presentation/screens/emotions/emotion_editor_sheet.dart';
import 'package:material_ui/material_ui.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

/// Removes an emotion right away when no mind uses it, otherwise asks whether to archive or delete it.
Future<void> removeEmotion(BuildContext context, Emotion emotion, EmotionsList state) async {
  final Set<String> referenced = context.read<MindRepository>().values.expand((mind) => mind.emotionIds).toSet();
  final Set<String> subtree = {emotion.id, ...state.descendantIdsOf(emotion.id)};
  if (!subtree.any(referenced.contains)) {
    context.read<EmotionBloc>().add(EmotionDelete(id: emotion.id));
    return;
  }
  final String? action = await showModalActionSheet<String>(
    context: context,
    title: emotion.title,
    message: context.l10n.emotionInUseMessage,
    actions: [
      SheetAction(key: 'archive', label: context.l10n.archive),
      SheetAction(key: 'delete', label: context.l10n.delete, isDestructiveAction: true),
    ],
  );
  if (!context.mounted) return;
  if (action == 'archive') {
    context.read<EmotionBloc>().add(EmotionArchive(id: emotion.id));
  } else if (action == 'delete') {
    context.read<EmotionBloc>().add(EmotionDelete(id: emotion.id));
  }
}

/// Settings → Emotions: one level of emotions as a list; tap to edit, swipe to remove, drag the handle to reorder.
final class EmotionManagerScreen extends StatefulWidget {
  final String? parentId;

  const EmotionManagerScreen({super.key, this.parentId});

  static Future<void> push(BuildContext context, {String? parentId}) => Navigator.of(
    context,
  ).push<void>(SwipeablePageRoute<void>(builder: (_) => EmotionManagerScreen(parentId: parentId)));

  @override
  State<EmotionManagerScreen> createState() => _EmotionManagerScreenState();
}

final class _EmotionManagerScreenState extends State<EmotionManagerScreen> {
  // Holds the dropped order until the bloc emits it, so the row doesn't jump back for a frame.
  List<Emotion>? _pendingOrder;

  @override
  void initState() {
    super.initState();
    context.read<EmotionBloc>().add(EmotionSeedDefaults());
  }

  void _reorder(List<Emotion> emotions, int from, int to) {
    final List<Emotion> reordered = [...emotions];
    final Emotion moved = reordered.removeAt(from);
    reordered.insert(to, moved);
    Haptics.vibrate(HapticsType.light);
    setState(() => _pendingOrder = reordered);
    context.read<EmotionBloc>().add(EmotionReorder(orderedEmotionIds: reordered.map((e) => e.id).toList()));
  }

  void _openArchived() =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const EmotionArchivedScreen()));

  @override
  Widget build(BuildContext context) => BlocConsumer<EmotionBloc, EmotionState>(
    listener: (_, _) => setState(() => _pendingOrder = null),
    builder: (context, state) {
      final Emotion? parent = state is EmotionsList && widget.parentId != null ? state.byId(widget.parentId!) : null;
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: GlassAppBar(
          centerTitle: true,
          title: Text(
            parent == null || state is! EmotionsList
                ? context.l10n.emotions
                : '${state.lineageEmojis(parent).join(' ')}  ${parent.title}',
          ),
          actions: [
            GlassBarAction(icon: Icons.archive_outlined, tooltip: context.l10n.archived, onPressed: _openArchived),
          ],
        ),
        body: state is EmotionsList ? _buildList(context, state) : const Center(child: CircularProgressIndicator()),
      );
    },
  );

  Widget _buildList(BuildContext context, EmotionsList state) {
    final List<Emotion> emotions = _pendingOrder ?? state.childrenOf(widget.parentId);
    final EdgeInsets padding = MediaQuery.paddingOf(context);
    final bool canAdd = widget.parentId == null;
    return Column(
      children: [
        Expanded(
          child: emotions.isEmpty
              ? Center(child: Text(context.l10n.noEmotionsYet))
              : ReorderableListView.builder(
                  padding: EdgeInsets.only(top: padding.top + kToolbarHeight + 8.0, bottom: 8.0),
                  buildDefaultDragHandles: false,
                  itemCount: emotions.length,
                  onReorderItem: (from, to) => _reorder(emotions, from, to),
                  itemBuilder: (context, index) => _EmotionRow(
                    key: ValueKey(emotions[index].id),
                    index: index,
                    emotion: emotions[index],
                    hasChildren: state.hasActiveChildren(emotions[index].id),
                    onTap: () =>
                        EmotionEditorSheet.show(context: context, initial: emotions[index], parentId: widget.parentId),
                    onOpenChildren: () => EmotionManagerScreen.push(context, parentId: emotions[index].id),
                    onRemove: () => removeEmotion(context, emotions[index], state),
                  ),
                ),
        ),
        // New emotions only go to the top level; see ADR-0002.
        if (canAdd)
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, padding.bottom + 12.0),
            child: GlassCapsuleButton(
              height: 50.0,
              isExpanded: true,
              onTap: () => EmotionEditorSheet.show(context: context, parentId: null),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8.0,
                children: [
                  const Icon(Icons.add),
                  Text(context.l10n.addEmotion, style: const TextStyle(fontSize: 17.0)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

final class _EmotionRow extends StatelessWidget {
  final int index;
  final Emotion emotion;
  final bool hasChildren;
  final VoidCallback onTap;
  final VoidCallback onOpenChildren;
  final VoidCallback onRemove;

  const _EmotionRow({
    super.key,
    required this.index,
    required this.emotion,
    required this.hasChildren,
    required this.onTap,
    required this.onOpenChildren,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey('dismiss-${emotion.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onRemove();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        color: scheme.errorContainer,
        child: Icon(Icons.delete_outline_rounded, color: scheme.onErrorContainer),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsetsDirectional.only(start: 16.0, end: 4.0),
          leading: Text(emotion.emoji, style: const TextStyle(fontSize: 26.0)),
          title: Text(emotion.title),
          onTap: onTap,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasChildren) IconButton(icon: const Icon(Icons.chevron_right), onPressed: onOpenChildren),
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(Icons.drag_handle, color: Theme.of(context).hintColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
