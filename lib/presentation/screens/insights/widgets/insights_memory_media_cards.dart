import 'package:material_ui/material_ui.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/domain/services/insights/insights_report.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/round_video/round_video_views.dart';
import 'package:keklist/presentation/screens/insights/insights_widget_id.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_card.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_format.dart';

final class InsightsOnThisDayCard extends StatelessWidget {
  final InsightsCardContext data;

  const InsightsOnThisDayCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<OnThisDayGroup> groups = data.report.onThisDay;
    return InsightsCard(
      category: InsightsCategory.memories,
      title: context.l10n.insightsOnThisDay,
      child: groups.isEmpty
          ? InsightsEmptyHint(context.l10n.insightsEmptyOnThisDay)
          : Column(
              children: [
                for (final OnThisDayGroup group in groups)
                  InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: () => data.openMinds(group.mindIds),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: _row(context, group),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _row(BuildContext context, OnThisDayGroup group) {
    final List<Mind> minds = group.mindIds.map((id) => data.mindById[id]).whereType<Mind>().toList();
    final String emojis = minds.expand((mind) => mind.emotionIds).map(data.emojiOf).toSet().join(' ');
    final String preview = minds.map((mind) => mind.plainNote.trim()).firstWhere((text) => text.isNotEmpty, orElse: () => '');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12.0,
      children: [
        SizedBox(
          width: 88.0,
          child: Text(InsightsFormat.day(context, group.dayIndex), style: Theme.of(context).textTheme.labelLarge),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (emojis.isNotEmpty) Text(emojis),
              if (preview.isNotEmpty) Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Text(
          InsightsFormat.number(context, minds.length),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).hintColor),
        ),
      ],
    );
  }
}

final class InsightsMediaCountersCard extends StatelessWidget {
  final InsightsCardContext data;

  const InsightsMediaCountersCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final MediaInsight media = data.report.media;
    final List<(int, String)> values = [
      if (data.hasLibraryIndex) ...[
        (media.libraryPhotos, context.l10n.insightsPhotos),
        (media.libraryVideos, context.l10n.insightsVideos),
      ],
      (media.audioMinds, context.l10n.insightsVoiceNotes),
      (media.videoMinds, context.l10n.insightsRoundVideos),
    ];
    return InsightsCard(
      category: InsightsCategory.media,
      title: context.l10n.insightsMediaCounters,
      trailing: InsightsFormat.periodTitle(context, data.report.period.kind),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.0,
        children: [
          for (final (int value, String caption) in values)
            Expanded(child: InsightsValue(value: InsightsFormat.number(context, value), caption: caption)),
        ],
      ),
    );
  }
}

final class InsightsRoundVideosCard extends StatelessWidget {
  static const double _size = 72.0;

  final InsightsCardContext data;

  const InsightsRoundVideosCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<String> ids = data.report.media.roundVideoMindIds;
    final List<(String, MindNoteVideo)> videos = [
      for (final String id in ids)
        if (data.mindById[id]?.noteContent.videoPieces.firstOrNull case final MindNoteVideo video) (id, video),
    ];
    return InsightsCard(
      category: InsightsCategory.media,
      title: context.l10n.insightsRoundVideos,
      trailing: InsightsFormat.periodTitle(context, data.report.period.kind),
      child: videos.isEmpty
          ? InsightsEmptyHint(context.l10n.insightsEmptyRoundVideos)
          : SizedBox(
              height: _size,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: videos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8.0),
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => data.openMinds([for (final (String id, _) in videos) id], initialIndex: index),
                  child: RoundVideoThumbnail(video: videos[index].$2, size: _size),
                ),
              ),
            ),
    );
  }
}
