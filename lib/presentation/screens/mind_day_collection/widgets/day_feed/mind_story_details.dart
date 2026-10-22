import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/blocs/emotion_bloc/emotion_bloc.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/core/extensions/story_settings_extension.dart';
import 'package:material_ui/material_ui.dart';

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

/// Everything about a mind in a story or the viewer, content first: its circle (video or audio), the text,
/// the emotions pill and the comments. The viewer passes the edit callbacks; stories leave them null.
final class MindStoryDetails extends StatelessWidget {
  final Mind mind;

  /// The round video or audio circle.
  final Widget? media;

  final VoidCallback? onTapText;

  /// Replaces the text while it is being edited.
  final Widget? textEditor;

  final VoidCallback? onEditEmotions;
  final ValueChanged<Mind>? onLongPressReflection;

  const MindStoryDetails({
    super.key,
    required this.mind,
    this.media,
    this.onTapText,
    this.textEditor,
    this.onEditEmotions,
    this.onLongPressReflection,
  });

  @override
  Widget build(BuildContext context) {
    final Color foreground = storyColorsOf(context).foreground;
    final String text = mind.plainNote.trim();
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20.0,
      children: [
        ?media,
        if (textEditor != null)
          textEditor!
        else if (text.isNotEmpty)
          GestureDetector(
            onTap: onTapText,
            child: Text(text, textAlign: TextAlign.center, style: mindStoryTextStyle(foreground)),
          ),
        MindEmotionsPill(mind: mind, onTap: onEditEmotions),
        MindReflectionsList(mind: mind, onLongPress: onLongPressReflection),
      ],
    );
  }
}

TextStyle mindStoryTextStyle(Color foreground) => TextStyle(color: foreground, fontSize: 20.0, height: 1.3);

/// The mind's emotions grouped as overlapping emojis in one pill; with [onTap] it opens the emotion picker and
/// a pale "☺ +" stands in when there are none.
final class MindEmotionsPill extends StatelessWidget {
  final Mind mind;
  final VoidCallback? onTap;

  const MindEmotionsPill({super.key, required this.mind, this.onTap});

  static const double _emojiSize = 24.0;
  static const double _overlap = 8.0;

  @override
  Widget build(BuildContext context) {
    final Color foreground = storyColorsOf(context).foreground;
    final Color background = storyColorsOf(context).background;
    return BlocBuilder<EmotionBloc, EmotionState>(
      builder: (context, state) {
        final List<Emotion> emotions = state is EmotionsList
            ? mind.emotionIds.map(state.byId).whereType<Emotion>().toList()
            : const [];
        if (emotions.isEmpty && onTap == null) return const SizedBox.shrink();
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              color: Color.alphaBlend(foreground.withValues(alpha: emotions.isEmpty ? 0.05 : 0.1), background),
            ),
            child: emotions.isEmpty
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4.0,
                    children: [
                      Icon(Icons.sentiment_satisfied_alt_outlined, size: 22.0, color: foreground.withValues(alpha: 0.4)),
                      Icon(Icons.add_rounded, size: 18.0, color: foreground.withValues(alpha: 0.4)),
                    ],
                  )
                : SizedBox(
                    height: _emojiSize + 4.0,
                    width: _emojiSize + (emotions.length - 1) * (_emojiSize - _overlap),
                    child: Stack(
                      children: [
                        for (int index = 0; index < emotions.length; index++)
                          Positioned(
                            left: index * (_emojiSize - _overlap),
                            child: Text(emotions[index].emoji, style: const TextStyle(fontSize: _emojiSize)),
                          ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

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

/// The mind's reflections, oldest first: time, emotions and full text of each.
final class MindReflectionsList extends StatelessWidget {
  final Mind mind;
  final ValueChanged<Mind>? onLongPress;

  const MindReflectionsList({super.key, required this.mind, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final Color foreground = storyColorsOf(context).foreground;
    final String locale = Localizations.localeOf(context).toString();
    return BlocBuilder<MindBloc, MindState>(
      buildWhen: (_, current) => current is MindList,
      builder: (context, state) {
        final Iterable<Mind> all = state is MindList ? state.values : const [];
        final List<Mind> reflections = all.where((other) => other.rootId == mind.id).toList()
          ..sort((a, b) => a.creationDate.compareTo(b.creationDate));
        if (reflections.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10.0,
          children: [
            for (final Mind reflection in reflections)
              GestureDetector(
                onLongPress: onLongPress == null ? null : () => onLongPress!(reflection),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    // Opaque so the emotion texture never runs through the comment.
                    color: Color.alphaBlend(foreground.withValues(alpha: 0.07), storyColorsOf(context).background),
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
