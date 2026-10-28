import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/blocs/emotion_bloc/emotion_bloc.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/core/extensions/story_settings_extension.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_context_menu/super_context_menu.dart';

/// Black on dark theme, white on light, with the matching text color; shared by stories and the viewer.
({Color background, Color foreground}) storyColorsOf(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? (background: Colors.black, foreground: Colors.white)
    : (background: Colors.white, foreground: Colors.black);

/// The lines of a story date header: "21 October", "Wednesday", "07:14", grouped by [layout].
List<String> storyDateLines(DateTime date, {required String locale, required StoryDateLayout layout}) {
  final DateTime local = date.toLocal();
  final String day = DateFormat.MMMMd(locale).format(local);
  final String weekday = toBeginningOfSentenceCase(DateFormat.EEEE(locale).format(local));
  final String time = DateFormat.Hm(locale).format(local);
  return switch (layout) {
    StoryDateLayout.oneLine => ['$day · $weekday · $time'],
    StoryDateLayout.twoLines => [day, '$weekday · $time'],
    StoryDateLayout.threeLines => [day, weekday, time],
  };
}

/// The date at the top of a story or viewer page, in a soft pill; how many lines it takes is a story tweak.
final class StoryDateHeader extends StatelessWidget {
  final DateTime date;

  const StoryDateHeader({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final Color foreground = storyColorsOf(context).foreground;
    final List<String> lines = storyDateLines(
      date,
      locale: Localizations.localeOf(context).toString(),
      layout: context.watchStorySettings().dateLayout,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(lines.length == 1 ? 20.0 : 16.0),
        color: foreground.withValues(alpha: 0.1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int index = 0; index < lines.length; index++)
            Text(
              lines[index],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: index == 0 ? foreground : foreground.withValues(alpha: 0.65),
                fontWeight: index == 0 ? FontWeight.w700 : FontWeight.w500,
                fontSize: index == 0 && lines.length > 1 ? 16.0 : 13.0,
              ),
            ),
        ],
      ),
    );
  }
}

/// A mind in a story: its circle (video or audio) and the text; comments open in their own sheet.
/// Its emotions are the texture behind it.
final class MindStoryDetails extends StatelessWidget {
  final Mind mind;

  /// The round video or audio circle.
  final Widget? media;

  final VoidCallback? onLongPressText;

  const MindStoryDetails({super.key, required this.mind, this.media, this.onLongPressText});

  @override
  Widget build(BuildContext context) {
    final Color foreground = storyColorsOf(context).foreground;
    final String text = mind.plainNote.trim();
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20.0,
      children: [
        ?media,
        if (text.isNotEmpty)
          GestureDetector(
            onLongPress: onLongPressText,
            child: Text(text, textAlign: TextAlign.center, style: mindStoryTextStyle(foreground)),
          ),
      ],
    );
  }
}

TextStyle mindStoryTextStyle(Color foreground) => TextStyle(color: foreground, fontSize: 20.0, height: 1.3);

/// "😄 Joy › Delight" for every emotion of a comment.
final class MindEmotionChips extends StatelessWidget {
  final Mind mind;

  const MindEmotionChips({super.key, required this.mind});

  @override
  Widget build(BuildContext context) {
    if (mind.emotionIds.isEmpty) return const SizedBox.shrink();
    final Color foreground = storyColorsOf(context).foreground;
    return BlocBuilder<EmotionBloc, EmotionState>(
      builder: (context, state) {
        if (state is! EmotionsList) return const SizedBox.shrink();
        final List<Emotion> emotions = mind.emotionIds.map(state.byId).whereType<Emotion>().toList();
        return Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            for (final Emotion emotion in emotions)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: foreground.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  '${emotion.emoji} ${[...state.ancestorsOf(emotion), emotion].map((e) => e.title).join(' › ')}',
                  style: TextStyle(color: foreground, fontSize: 15.0),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// The reflections of the mind with [rootId], oldest first.
List<Mind> mindReflectionsOf(Iterable<Mind> minds, String rootId) =>
    minds.where((other) => other.rootId == rootId).toList()..sort((a, b) => a.creationDate.compareTo(b.creationDate));

/// The mind's reflections, oldest first: time, emotions and full text of each.
final class MindReflectionsList extends StatelessWidget {
  final Mind mind;
  final List<MenuElement> Function(Mind reflection)? menu;

  const MindReflectionsList({super.key, required this.mind, this.menu});

  @override
  Widget build(BuildContext context) {
    final Color foreground = storyColorsOf(context).foreground;
    final String locale = Localizations.localeOf(context).toString();
    return BlocBuilder<MindBloc, MindState>(
      buildWhen: (_, current) => current is MindList,
      builder: (context, state) {
        final List<Mind> reflections = state is MindList ? mindReflectionsOf(state.values, mind.id) : const [];
        if (reflections.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10.0,
          children: [
            for (final Mind reflection in reflections)
              _ReflectionMenu(
                menu: menu == null ? null : () => menu!(reflection),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: foreground.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6.0,
                    children: [
                      Text(
                        DateFormat.yMMMd(locale).add_Hm().format(reflection.creationDate.toLocal()),
                        style: TextStyle(color: foreground.withValues(alpha: 0.55), fontSize: 12.0),
                      ),
                      if (reflection.emotionIds.isNotEmpty) MindEmotionChips(mind: reflection),
                      if (reflection.plainNote.trim().isNotEmpty)
                        Text(reflection.plainNote.trim(), style: TextStyle(color: foreground, fontSize: 16.0)),
                      if (reflection.noteContent.hasMedia)
                        Icon(
                          reflection.noteContent.hasVideo ? Icons.videocam_outlined : Icons.graphic_eq,
                          size: 18.0,
                          color: foreground.withValues(alpha: 0.55),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Wraps a reflection in the system context menu when there is one.
final class _ReflectionMenu extends StatelessWidget {
  final List<MenuElement> Function()? menu;
  final Widget child;

  const _ReflectionMenu({required this.menu, required this.child});

  @override
  Widget build(BuildContext context) => switch (menu) {
    final List<MenuElement> Function() menu => ContextMenuWidget(
      menuProvider: (_) => Menu(children: menu()),
      child: child,
    ),
    null => child,
  };
}
