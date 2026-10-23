import 'package:keklist/presentation/core/widgets/glass_app_bar.dart';
import 'package:keklist/presentation/core/widgets/pinch_columns_detector.dart';
import 'dart:async';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:keklist/domain/repositories/tabs/models/tabs_settings.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/blocs/tabs_container_bloc/tabs_container_bloc.dart';
import 'package:keklist/presentation/blocs/tabs_container_bloc/tabs_container_event.dart';
import 'package:keklist/presentation/blocs/tabs_container_bloc/tabs_container_state.dart';
import 'package:keklist/presentation/blocs/lazy_onboarding_bloc/lazy_onboarding_bloc.dart';
import 'package:keklist/domain/services/constants/onboarding_constants.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/helpers/extensions/state_extensions.dart';
import 'package:keklist/presentation/core/helpers/platform_utils.dart';
import 'package:keklist/presentation/core/screen/kek_screen_state.dart';
import 'package:keklist/presentation/screens/actions/action_model.dart';
import 'package:keklist/presentation/screens/actions/actions_screen.dart';
import 'package:keklist/presentation/screens/digest/mind_universal_list_screen.dart';
import 'package:keklist/presentation/screens/insights/insights_screen.dart';
import 'package:keklist/presentation/screens/settings/settings_screen.dart';
import 'package:keklist/presentation/screens/web_page/web_page_screen.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/domain/constants.dart';
import 'package:keklist/presentation/core/helpers/bloc_utils.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart';
import 'package:keklist/presentation/screens/mind_day_collection/mind_day_collection_screen.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:material_ui/material_ui.dart' hide DateUtils;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:keklist/presentation/core/widgets/bool_widget.dart';
import 'package:keklist/domain/period.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/media_index/gallery_indexer.dart';
import 'package:keklist/presentation/core/shake/shake_to_tweak_mixin.dart';
import 'package:keklist/presentation/screens/mind_collection/calendar_day_feed.dart';
import 'package:keklist/presentation/screens/mind_collection/local_widgets/calendar_day_header.dart';
import 'package:keklist/presentation/screens/mind_collection/local_widgets/calendar_settings_bottom_sheet.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_grid.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_layout.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_item_viewer_screen.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_stories_screen.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';
part 'local_widgets/app_bar/mind_collection_app_bar.dart';
part 'local_widgets/body/mind_collection_body.dart';

final class MindCollectionScreen extends StatefulWidget {
  const MindCollectionScreen({super.key});

  @override
  State<MindCollectionScreen> createState() => _MindCollectionScreenState();
}

final class _MindCollectionScreenState extends KekWidgetState<MindCollectionScreen> with ShakeToTweakMixin {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  Iterable<Mind> _minds = [];
  CalendarDayFeed _feed = CalendarDayFeed(minds: const [], indexer: null, includesMedia: false);
  SettingsDataState? _settingsDataState;
  bool _isSettingsVisible = true;
  bool _isInsightsVisible = true;
  final bool _isDemoMode = false;
  bool _hasShownOnboardingDialog = false;

  bool get _shouldShowTitles => _settingsDataState?.settings.shouldShowTitles ?? true;
  CalendarSettings get _calendarSettings => _settingsDataState?.settings.calendar ?? const CalendarSettings();
  GalleryIndexer get _indexer => context.read<GalleryIndexer>();

  @override
  String get shakeScreenId => ShakeScreenIds.calendar;

  @override
  void onShakeToTweak() => KekSheet.show(context: context, builder: (_) => const CalendarSettingsBottomSheet());

  // NOTE: Payments.
  // final PaymentService _payementService = PaymentService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jumpToNow();

      subscribeToBloc<SettingsBloc>(
        onNewState: (state) {
          switch (state) {
            case SettingsDataState settingsDataState:
              setState(() => _settingsDataState = settingsDataState);
              _rebuildFeed();
            case SettingsShowWhatsNew _:
              _showWhatsNew();
              sendEventToBloc<SettingsBloc>(SettingsWhatsNewShown());
          }
        },
      )?.disposed(by: this);

      subscribeToBloc<MindBloc>(
        onNewState: (state) async {
          if (state is MindList) {
            _minds = state.values;
            _rebuildFeed();
            if (DeviceUtils.safeGetPlatform() == SupportedPlatform.iOS) {
              sendEventToBloc<MindBloc>(MindUpdateMobileWidgets());
            }

            // Automatically delete onboarding minds after first real mind is created
            if (!_hasShownOnboardingDialog) {
              final realMinds = state.values
                  .where((m) => !OnboardingConstants.isOnboardingMind(m.id, m.rootId))
                  .toList();

              final onboardingMinds = state.values
                  .where((m) => OnboardingConstants.isOnboardingMind(m.id, m.rootId))
                  .toList();

              if (realMinds.length == 1 && onboardingMinds.isNotEmpty) {
                _hasShownOnboardingDialog = true;
                // Automatically delete onboarding minds and mark as seen
                sendEventToBloc<LazyOnboardingBloc>(LazyOnboardingDelete());
                sendEventToBloc<LazyOnboardingBloc>(LazyOnboardingMarkAsSeen());
              }
            }
          }
        },
      )?.disposed(by: this);

      // Lazy onboarding check
      subscribeToBloc<LazyOnboardingBloc>(
        onNewState: (state) {
          if (state is LazyOnboardingNeeded && state.shouldShow) {
            sendEventToBloc<LazyOnboardingBloc>(LazyOnboardingCreate(context: context));
            sendEventToBloc<LazyOnboardingBloc>(LazyOnboardingMarkAsSeen());
          }
        },
      )?.disposed(by: this);
      sendEventToBloc<LazyOnboardingBloc>(LazyOnboardingCheck());

      // Auth removed - no authentication required

      subscribeToBloc<TabsContainerBloc>(
        onNewState: (state) {
          if (state is TabsContainerState) {
            setState(() {
              _isInsightsVisible = !state.selectedTabs.map((tab) => tab.type).contains(TabType.insights);
              _isSettingsVisible = !state.selectedTabs.map((tab) => tab.type).contains(TabType.settings);
            });
          }
        },
      )?.disposed(by: this);

      _indexer.progress
          .where((progress) => progress.status == GalleryIndexStatus.ready)
          .listen((_) => _rebuildFeed())
          .disposed(by: this);

      // Auth removed - no authentication required
      sendEventToBloc<SettingsBloc>(SettingsGet());
      sendEventToBloc<MindBloc>(MindGetList());
      sendEventToBloc<TabsContainerBloc>(TabsContainerGetCurrentState());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: BoolWidget(
          condition: !_isDemoMode,
          falseChild: const SizedBox.shrink(),
          trueChild: _MindCollectionAppBar(
            onTitle: () => _scrollToNow(),
            onCalendar: () => _showCalendarActions(),
            onSettings: _isSettingsVisible ? (() => _showSettings()) : null,
            onInsights: _isInsightsVisible ? (() => _showInsights()) : null,
            onTitleLongPress: requestTweak,
          ),
        ),
      ),
      body: Stack(
        children: [
          _MindCollectionBody(
            onTapToDay: (dayIndex) => _showDayCollectionScreen(groupDayIndex: dayIndex),
            onOpenItem: _openDayItem,
            onPlay: _playStories,
            feed: _feed,
            settings: _calendarSettings,
            onColumnCountChanged: (count) => sendEventToBloc<SettingsBloc>(
              SettingsUpdateCalendar(calendar: _calendarSettings.copyWith(columnCount: count)),
            ),
            showsWeekTitles: _shouldShowTitles,
            todayIndex: _getNowDayIndex(),
            itemScrollController: _itemScrollController,
            itemPositionsListener: _itemPositionsListener,
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: MediaQuery.paddingOf(context).bottom + 12.0,
            child: Center(
              child: _CurrentWeekBubble(
                itemPositionsListener: _itemPositionsListener,
                todayIndex: _getNowDayIndex(),
                onTap: _scrollToNow,
              ),
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  Future<void> _showWhatsNew() {
    return showCupertinoModalBottomSheet(
      context: context,
      builder: (builder) {
        return WebPageScreen(title: 'Whats new?', initialUri: Uri.parse(KeklistConstants.whatsNewURL));
      },
    );
  }

  void _showDayCollectionScreen({required int groupDayIndex}) {
    Navigator.of(
      context,
    ).push(SwipeablePageRoute(builder: (context) => MindDayCollectionScreen(initialDayIndex: groupDayIndex)));
  }

  void _rebuildFeed() {
    if (!mounted) return;
    final CalendarDayFeed feed = CalendarDayFeed(
      minds: _minds,
      indexer: _indexer,
      includesMedia: _calendarSettings.isMediaVisible,
    );
    setState(() => _feed = feed);
  }

  void _jumpToNow() {
    if (_isDemoMode || !_itemScrollController.isAttached) {
      return;
    }
    _itemScrollController.jumpTo(index: _getNowDayIndex(), alignment: _belowBarAlignment);
  }

  Future<void> _scrollToNow() => _scrollToDayIndex(_getNowDayIndex());

  /// Scroll targets land just below the floating bar instead of under it.
  double get _belowBarAlignment {
    final MediaQueryData media = MediaQuery.of(context);
    return ((media.padding.top + kToolbarHeight) / media.size.height).clamp(0.0, 0.5);
  }

  Future<void> _scrollToDayIndex(int dayIndex) => _itemScrollController.scrollTo(
    index: dayIndex,
    alignment: _belowBarAlignment,
    duration: const Duration(milliseconds: 200),
  );

  void _openDayItem(int dayIndex, int initialIndex) =>
      DayItemViewerScreen.show(context, items: _feed.itemsOf(dayIndex), initialIndex: initialIndex);

  void _playStories(List<int> dayIndexes) {
    final List<DayFeedItem> items = [for (final int dayIndex in dayIndexes) ..._feed.itemsOf(dayIndex)];
    if (items.isEmpty) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        fullscreenDialog: true,
        pageBuilder: (_, _, _) => DayStoriesScreen(items: items, initialIndex: 0),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  int _getNowDayIndex() => DateUtils.getDayIndex(from: DateTime.now());

  // void _enableDemoMode() {
  //   if (_isDemoMode) {
  //     return;
  //   }

  //   setState(() => _isDemoMode = true);
  // }

  // void _disableDemoMode() {
  //   if (!_isDemoMode) {
  //     return;
  //   }

  //   setState(() => _isDemoMode = false);
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     _jumpToNow();
  //   });
  // }

  Future<void> _showDateSwitcher() async {
    final List<DateTime?>? dates = await showCalendarDatePicker2Dialog(
      context: context,
      value: [],
      config: CalendarDatePicker2WithActionButtonsConfig(firstDayOfWeek: 1),
      dialogSize: const Size(325, 400),
      borderRadius: BorderRadius.circular(15),
    );

    if (dates == null || dates.isEmpty) {
      return;
    }

    final int dayIndex = DateUtils.getDayIndex(from: dates.first!);
    _scrollToDayIndex(dayIndex);
  }

  Future<(int startDateIndex, int endDateIndex)?> _showPeriodPicker() async {
    final List<DateTime?>? dates = await showCalendarDatePicker2Dialog(
      context: context,
      value: [],
      config: CalendarDatePicker2WithActionButtonsConfig(
        firstDayOfWeek: 1,
        calendarType: CalendarDatePicker2Type.range,
      ),
      dialogSize: const Size(325, 400),
      borderRadius: BorderRadius.circular(15),
    );

    if (dates == null || dates.length < 2) {
      return null;
    }

    final int startDayIndex = DateUtils.getDayIndex(from: dates[0]!);
    final int endDayIndex = DateUtils.getDayIndex(from: dates[1]!);

    return (startDayIndex, endDayIndex);
  }

  void _showCalendarActions() {
    KekSheet.show(
      context: context,
      builder: (context) => ActionsScreen(
        actions: [
          (ActionModel.goToDate(context), () => _showDateSwitcher()),
          (ActionModel.showDigest(context), () => _showDigestPeriodOptions()),
        ],
      ),
    );
  }

  void _showDigestPeriodOptions() {
    KekSheet.show(
      context: context,
      builder: (context) => ActionsScreen(
        actions: [
          ...PeriodType.values.map(
            (periodType) => (
              ActionModel.custom(icon: _getPeriodIcon(periodType), title: periodType.localizedTitle(context)),
              () async {
                final List<Mind> periodMinds = periodType.filterMinds(_minds.toList());
                if (periodMinds.isNotEmpty) {
                  _showDigestForPeriod(periodType, periodMinds);
                }
              },
            ),
          ),
          (
            ActionModel.custom(icon: const Icon(Icons.date_range), title: context.l10n.selectPeriod),
            () async => _showDigestForCustomPeriod(),
          ),
        ],
      ),
    );
  }

  Icon _getPeriodIcon(PeriodType periodType) {
    switch (periodType) {
      case PeriodType.today:
        return const Icon(Icons.today);
      case PeriodType.yesterday:
        return const Icon(Icons.history);
      case PeriodType.thisWeek:
        return const Icon(Icons.view_week_rounded);
      case PeriodType.lastTwoWeeks:
        return const Icon(Icons.calendar_view_week);
      case PeriodType.thisMonth:
        return const Icon(Icons.calendar_view_month);
      case PeriodType.thisYear:
        return const Icon(Icons.calendar_today);
    }
  }

  void _showDigestForPeriod(PeriodType periodType, List<Mind> periodMinds) {
    if (mountedContext == null) {
      return;
    }

    Navigator.push(
      mountedContext!,
      SwipeablePageRoute(
        builder: (context) {
          return MindUniversalListScreen(
            allMinds: _minds,
            filterFunction: (mind) => periodType.filterMinds([mind]).isNotEmpty,
            title: '${periodType.localizedTitle(context)} (${periodMinds.length} ${context.l10n.minds})',
            emptyStateMessage: '${context.l10n.noMindsForPeriod} ${periodType.localizedTitle(context).toLowerCase()}',
            onSelectMind: (mind) => _showMindInfo(mind),
          );
        },
      ),
    );
  }

  void _showDigestForCustomPeriod() async {
    final (int startDayIndex, int endDayIndex)? period = await _showPeriodPicker();
    if (period == null) {
      return;
    }
    _showDigest(startDayIndex: period.$1, endDayIndex: period.$2);
  }

  void _showDigest({required int startDayIndex, required int endDayIndex}) async {
    if (mountedContext == null) {
      return;
    }

    Navigator.push(
      mountedContext!,
      SwipeablePageRoute(
        builder: (context) {
          bool filterFunction(mind) => mind.dayIndex >= startDayIndex && mind.dayIndex <= endDayIndex;
          return MindUniversalListScreen(
            allMinds: _minds,
            filterFunction: filterFunction,
            title: '${context.l10n.digest} (${_minds.where(filterFunction).length} ${context.l10n.minds})',
            emptyStateMessage: context.l10n.noMindsInSelectedPeriod,
            onSelectMind: (mind) => _showMindInfo(mind),
          );
        },
      ),
    );
  }

  // void _showUserProfile() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => const UserProfileScreen(),
  //     ),
  //   );
  // }

  void _showSettings() {
    Navigator.push(context, SwipeablePageRoute(builder: (context) => const SettingsScreen()));
  }

  void _showInsights() {
    Navigator.push(context, SwipeablePageRoute(builder: (context) => const InsightsScreen()));
  }

  void _showMindInfo(Mind mind) => DayItemViewerScreen.showMind(context, mind);
}
