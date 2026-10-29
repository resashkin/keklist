part of '../../mind_collection_screen.dart';

/// The calendar limited to one period, oldest day first; it follows the calendar tweaks.
final class _CalendarDigestScreen extends StatefulWidget {
  final String title;
  final int firstDayIndex;
  final int lastDayIndex;

  const _CalendarDigestScreen({required this.title, required this.firstDayIndex, required this.lastDayIndex});

  @override
  State<_CalendarDigestScreen> createState() => _CalendarDigestScreenState();
}

final class _CalendarDigestScreenState extends KekWidgetState<_CalendarDigestScreen> with ShakeToTweakMixin {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  Iterable<Mind> _minds = [];
  SettingsDataState? _settingsDataState;
  CalendarDayFeed _feed = CalendarDayFeed(minds: const [], indexer: null, includesMedia: false);

  CalendarSettings get _calendarSettings => _settingsDataState?.settings.calendar ?? const CalendarSettings();
  List<int> get _dayIndexes => [for (int day = widget.firstDayIndex; day <= widget.lastDayIndex; day++) day];

  @override
  String get shakeScreenId => ShakeScreenIds.calendar;

  @override
  void onShakeToTweak() => KekSheet.show(context: context, builder: (_) => const CalendarSettingsBottomSheet());

  @override
  void initState() {
    super.initState();
    final MindState mindState = context.read<MindBloc>().state;
    if (mindState is MindList) _minds = mindState.values;
    final SettingsState settingsState = context.read<SettingsBloc>().state;
    if (settingsState is SettingsDataState) _settingsDataState = settingsState;
    _rebuildFeed();

    subscribeToBloc<SettingsBloc>(
      onNewState: (state) {
        if (state is! SettingsDataState) return;
        _settingsDataState = state;
        _rebuildFeed();
      },
    )?.disposed(by: this);
    subscribeToBloc<MindBloc>(
      onNewState: (state) {
        if (state is! MindList) return;
        _minds = state.values;
        _rebuildFeed();
      },
    )?.disposed(by: this);
  }

  void _rebuildFeed() {
    final CalendarDayFeed feed = CalendarDayFeed(
      minds: _minds,
      indexer: context.read<GalleryIndexer>(),
      includesMedia: _calendarSettings.isMediaVisible,
      sortOrder: _calendarSettings.sortOrder,
      grouping: _calendarSettings.grouping,
      hiddenMediaIds: _settingsDataState?.settings.hiddenMediaIds ?? const {},
    );
    if (mounted) setState(() => _feed = feed);
  }

  @override
  Widget build(BuildContext context) {
    final int notesCount = _dayIndexes.expand(_feed.itemsOf).whereType<DayFeedMind>().length;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        centerTitle: true,
        onTitleLongPress: requestTweak,
        title: Text('${widget.title} · ${context.l10n.digestNotesCount(notesCount)}'),
        actions: [
          GlassBarAction(
            icon: Icons.play_arrow_rounded,
            tooltip: context.l10n.calendarPlayStories,
            onPressed: notesCount == 0 ? null : () => _playStories(_dayIndexes),
          ),
        ],
      ),
      body: _MindCollectionBody(
        onTapToDay: (dayIndex) => Navigator.of(
          context,
        ).push(SwipeablePageRoute(builder: (_) => MindDayCollectionScreen(initialDayIndex: dayIndex))),
        onOpenItem: (dayIndex, itemIndex) =>
            DayItemViewerScreen.show(context, items: _feed.itemsOf(dayIndex), initialIndex: itemIndex),
        onPlay: _playStories,
        feed: _feed,
        settings: _calendarSettings,
        onColumnCountChanged: (count) => sendEventToBloc<SettingsBloc>(
          SettingsUpdateCalendar(calendar: _calendarSettings.copyWith(columnCount: count)),
        ),
        showsWeekTitles: _settingsDataState?.settings.shouldShowTitles ?? true,
        todayIndex: DateUtils.getTodayIndex(),
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
        firstDayIndex: widget.firstDayIndex,
        dayCount: widget.lastDayIndex - widget.firstDayIndex + 1,
      ),
    );
  }

  void _playStories(List<int> dayIndexes) {
    final List<DayFeedItem> items = [for (final int dayIndex in dayIndexes) ..._feed.itemsOf(dayIndex)];
    if (items.isEmpty) return;
    DayItemViewerScreen.show(context, items: items, initialIndex: 0, autoplay: true);
  }
}
