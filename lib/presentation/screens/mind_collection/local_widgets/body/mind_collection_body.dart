part of '../../mind_collection_screen.dart';

final class _MindCollectionBody extends StatelessWidget {
  final ValueChanged<int> onTapToDay;
  final void Function(int dayIndex, int itemIndex) onOpenItem;
  final ValueChanged<List<int>> onPlay;
  final CalendarDayFeed feed;
  final CalendarSettings settings;
  final ValueChanged<int> onColumnCountChanged;
  final bool showsWeekTitles;
  final int todayIndex;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;

  const _MindCollectionBody({
    required this.onTapToDay,
    required this.onOpenItem,
    required this.onPlay,
    required this.feed,
    required this.settings,
    required this.onColumnCountChanged,
    required this.showsWeekTitles,
    required this.todayIndex,
    required this.itemScrollController,
    required this.itemPositionsListener,
  });

  static const int _allDaysCount = 99999999999;

  @override
  Widget build(BuildContext context) {
    return PinchColumnsDetector(
      columnCount: settings.columnCount,
      onChanged: onColumnCountChanged,
      builder: (_, isPinching) => ScrollablePositionedList.builder(
          physics: isPinching ? const NeverScrollableScrollPhysics() : null,
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top + 8.0,
          bottom: MediaQuery.paddingOf(context).bottom + 96.0,
        ),
        itemCount: _allDaysCount,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        itemBuilder: (context, dayIndex) => _buildDay(context, dayIndex),
      ),
    );
  }

  static const int _daysInWeek = 7;

  Widget _buildDay(BuildContext context, int dayIndex) {
    final DateTime date = DateUtils.getDateFromDayIndex(dayIndex);
    final int weekNumber = _getWeekNumber(date);
    final bool startsWeek = weekNumber != _getWeekNumber(DateUtils.getDateFromDayIndex(dayIndex - 1));
    final List<DayFeedItem> items = feed.itemsOf(dayIndex);
    final List<int> weekDays = [for (int offset = 0; offset < _daysInWeek; offset++) dayIndex + offset];
    final bool hasWeekItems = weekDays.any((day) => feed.itemsOf(day).isNotEmpty);

    final Widget day = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        CalendarDayPill(
          date: date,
          isToday: dayIndex == todayIndex,
          items: items,
          onTap: () => onTapToDay(dayIndex),
          onPlay: items.isEmpty ? null : () => onPlay([dayIndex]),
        ),
        if (items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2.0, bottom: 8.0),
            child: DayFeedGrid(
              sections: feed.sectionsOf(dayIndex),
              columnCount: settings.columnCount,
              isMindTextVisible: settings.isMindTextVisible,
              onOpenItem: (itemIndex) => onOpenItem(dayIndex, itemIndex),
            ),
          ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DayFeedLayout.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showsWeekTitles && startsWeek)
            CalendarWeekHeader(weekNumber: weekNumber, onPlay: hasWeekItems ? () => onPlay(weekDays) : null),
          _DayFrame(isToday: dayIndex == todayIndex, child: day),
        ],
      ),
    );
  }

  // FIXME: to not show week number in start of each year.
  int _getWeekNumber(DateTime date) {
    final DateTime firstDayOfYear = DateTime(date.year, 1, 1);
    final int dayOfYear = date.difference(firstDayOfYear).inDays;
    final int weekdayOfFirstDay = firstDayOfYear.weekday;
    return ((dayOfYear + weekdayOfFirstDay) / 7).ceil();
  }
}

/// A rounded frame around a whole day, its pill and grid: faint for every day, accented and tinted for today.
final class _DayFrame extends StatelessWidget {
  final bool isToday;
  final Widget child;

  const _DayFrame({required this.isToday, required this.child});

  static const double _radius = 22.0;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: isToday ? colors.primary.withValues(alpha: 0.05) : null,
        borderRadius: BorderRadius.circular(_radius),
        border: isToday
            ? Border.all(color: colors.primary, width: 2.0)
            : Border.all(color: colors.onSurface.withValues(alpha: 0.14)),
      ),
      child: child,
    );
  }
}

/// "To current week": shown while the current week is scrolled out of view, the arrow points to it.
final class _CurrentWeekBubble extends StatelessWidget {
  final ItemPositionsListener itemPositionsListener;
  final int todayIndex;
  final VoidCallback onTap;

  const _CurrentWeekBubble({required this.itemPositionsListener, required this.todayIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final int weekStart = todayIndex - (DateUtils.getDateFromDayIndex(todayIndex).weekday - DateTime.monday);
    final int weekEnd = weekStart + DateTime.daysPerWeek - 1;
    return ValueListenableBuilder<Iterable<ItemPosition>>(
      valueListenable: itemPositionsListener.itemPositions,
      builder: (context, positions, _) {
        final List<int> visible = positions
            .where((position) => position.itemTrailingEdge > 0.0 && position.itemLeadingEdge < 1.0)
            .map((position) => position.index)
            .toList();
        final bool isWeekVisible = visible.isEmpty || visible.any((index) => index >= weekStart && index <= weekEnd);
        final bool isWeekBelow = visible.isNotEmpty && visible.every((index) => index < weekStart);
        return IgnorePointer(
          ignoring: isWeekVisible,
          child: AnimatedSlide(
            offset: isWeekVisible ? const Offset(0.0, 0.6) : Offset.zero,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              opacity: isWeekVisible ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 180),
              child: GestureDetector(
                onTap: onTap,
                child: GlassBubble(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 6.0,
                    children: [
                      Icon(isWeekBelow ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, size: 18.0),
                      Text(
                        context.l10n.calendarToCurrentWeek,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
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
