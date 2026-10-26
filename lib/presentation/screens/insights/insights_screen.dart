import 'package:material_ui/material_ui.dart' hide DateUtils;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/insights/insights_calculator.dart';
import 'package:keklist/domain/services/insights/insights_period.dart';
import 'package:keklist/domain/services/insights/insights_report.dart';
import 'package:keklist/domain/services/media_index/gallery_indexer.dart';
import 'package:keklist/domain/services/media_index/media_day_index.dart';
import 'package:keklist/presentation/blocs/emotion_bloc/emotion_bloc.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/helpers/bloc_utils.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart';
import 'package:keklist/presentation/core/screen/kek_screen_state.dart';
import 'package:keklist/presentation/core/widgets/glass_app_bar.dart';
import 'package:keklist/presentation/core/widgets/glass_segmented_switcher.dart';
import 'package:keklist/presentation/core/shake/shake_to_tweak_mixin.dart';
import 'package:keklist/presentation/screens/insights/insights_widget_id.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_activity_cards.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_card.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_emotion_cards.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_format.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_memory_media_cards.dart';
import 'package:keklist/presentation/blocs/user_profile_bloc/user_profile_bloc.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_profile_header.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_summary_cards.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_tweak_sheet.dart';
import 'package:keklist/presentation/screens/mind_collection/local_widgets/mind_collection_empty_day_widget.dart';
import 'package:keklist/presentation/screens/mind_day_collection/mind_day_collection_screen.dart';
import 'package:keklist/presentation/core/helpers/emotion_colors.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_item_viewer_screen.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';

/// Analytics: one period for the whole screen, calm cards in a user-defined order.
/// See `documentation/INSIGHTS_REDESIGN_IMPLEMENTATION.md`.
final class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

final class _InsightsScreenState extends KekWidgetState<InsightsScreen> with ShakeToTweakMixin {
  final List<Mind> _minds = [];

  @override
  String get shakeScreenId => ShakeScreenIds.insights;

  @override
  void onShakeToTweak() => KekSheet.show(context: context, builder: (_) => const InsightsTweakSheet());

  @override
  void initState() {
    super.initState();
    subscribeToBloc<MindBloc>(
      onNewState: (state) {
        if (state is! MindList) return;
        setState(
          () => _minds
            ..clear()
            ..addAll(state.values),
        );
      },
    )?.disposed(by: this);
    sendEventToBloc<MindBloc>(MindGetList());
  }

  @override
  Widget build(BuildContext context) {
    final SettingsState settingsState = context.watch<SettingsBloc>().state;
    final InsightsSettings insights = settingsState is SettingsDataState
        ? settingsState.settings.insights
        : const InsightsSettings();
    final EmotionState emotionState = context.watch<EmotionBloc>().state;
    final List<Emotion> emotions = emotionState is EmotionsList ? emotionState.emotions : const [];
    final GalleryIndexer indexer = context.read<GalleryIndexer>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        centerTitle: true,
        onTitleLongPress: requestTweak,
        title: Text(switch (context.watch<UserProfileBloc>().state.nickname?.trim()) {
          final String name when name.isNotEmpty => name,
          _ => context.l10n.insights,
        }),
      ),
      body: _minds.isEmpty
          ? ListView(
              padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
              children: [
                const InsightsProfileHeader(mindfulDays: 0),
                MindCollectionEmptyStateWidget.noInsights(context: context),
              ],
            )
          : StreamBuilder<GalleryIndexProgress>(
              stream: indexer.progress,
              builder: (context, _) => _buildBody(context, insights, emotions, indexer),
            ),
    );
  }

  Widget _buildBody(BuildContext context, InsightsSettings insights, List<Emotion> emotions, GalleryIndexer indexer) {
    final InsightsPeriodKind kind =
        InsightsPeriodKind.values[insights.periodIndex.clamp(0, InsightsPeriodKind.values.length - 1)];
    final int firstDayIndex = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final InsightsPeriod period = InsightsPeriod.of(
      kind,
      today: DateUtils.getTodayIndex(),
      firstDayOfWeek: firstDayIndex == 0 ? DateTime.sunday : firstDayIndex,
      firstMindDay: _minds.map((mind) => mind.dayIndex).reduce((a, b) => a < b ? a : b),
    );
    final InsightsReport report = InsightsCalculator(
      period: period,
      minds: _minds,
      emotions: emotions,
      libraryMediaByDay: {
        for (final MediaDayIndex entry in indexer.entries)
          entry.dayIndex: (photos: entry.photoCount, videos: entry.videoCount),
      },
    ).build();
    final InsightsCardContext data = InsightsCardContext(
      report: report,
      emotionById: {for (final Emotion emotion in emotions) emotion.id: emotion},
      mindById: {for (final Mind mind in _minds) mind.id: mind},
      emotionColors: emotionColorsOf(emotions),
      openMinds: _openMinds,
      openDay: _openDay,
      hasLibraryIndex: indexer.currentProgress.status != GalleryIndexStatus.unsupported,
    );
    final List<InsightsWidgetId> visibleIds = InsightsWidgetId.ordered(
      insights.widgetOrder,
    ).where((id) => !insights.hiddenWidgetIds.contains(id.name)).toList();

    return ListView(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top,
        bottom: MediaQuery.paddingOf(context).bottom + 96.0,
      ),
      children: [
        InsightsProfileHeader(mindfulDays: _mindfulDays),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          child: GlassSegmentedSwitcher<InsightsPeriodKind>(
            values: InsightsPeriodKind.values,
            selected: kind,
            labelOf: (value) => InsightsFormat.periodTitle(context, value),
            onChanged: (value) => sendEventToBloc<SettingsBloc>(
              SettingsUpdateInsights(insights: insights.copyWith(periodIndex: value.index)),
            ),
          ),
        ),
        for (final InsightsWidgetId id in visibleIds) _buildCard(id, data),
      ],
    );
  }

  int get _mindfulDays => _minds.map((mind) => mind.dayIndex).toSet().length;

  Widget _buildCard(InsightsWidgetId id, InsightsCardContext data) => switch (id) {
    InsightsWidgetId.counters => InsightsCountersCard(data: data),
    InsightsWidgetId.brightest => InsightsBrightestCard(data: data),
    InsightsWidgetId.emotionDistribution => InsightsEmotionDistributionCard(data: data),
    InsightsWidgetId.emotionTrend => InsightsEmotionTrendCard(data: data),
    InsightsWidgetId.emotionPairs => InsightsEmotionPairsCard(data: data),
    InsightsWidgetId.emotionRhythm => InsightsEmotionRhythmCard(data: data),
    InsightsWidgetId.streak => InsightsStreakCard(data: data),
    InsightsWidgetId.heatmap => InsightsHeatmapCard(data: data),
    InsightsWidgetId.activityTime => InsightsActivityTimeCard(data: data),
    InsightsWidgetId.onThisDay => InsightsOnThisDayCard(data: data),
    InsightsWidgetId.mediaCounters => InsightsMediaCountersCard(data: data),
    InsightsWidgetId.roundVideos => InsightsRoundVideosCard(data: data),
  };

  /// Each top-level emotion gets a palette color; nested ones inherit their root's.
  void _openMinds(List<String> mindIds, {int initialIndex = 0}) {
    final Map<String, Mind> byId = {for (final Mind mind in _minds) mind.id: mind};
    final Map<String, MindReflections> reflections = MindReflections.countAll(_minds);
    final List<DayFeedItem> items = [
      for (final Mind mind in mindIds.map((id) => byId[id]).whereType<Mind>())
        DayFeedMind(mind: mind, reflections: reflections[mind.id] ?? const MindReflections()),
    ];
    DayItemViewerScreen.show(
      context,
      items: items,
      initialIndex: initialIndex,
    );
  }

  void _openDay(int dayIndex) => Navigator.of(
    context,
  ).push(SwipeablePageRoute(builder: (_) => MindDayCollectionScreen(initialDayIndex: dayIndex)));
}
