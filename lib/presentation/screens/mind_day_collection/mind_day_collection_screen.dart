import 'package:keklist/presentation/core/widgets/glass_app_bar.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_item_viewer_screen.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_layout.dart';
import 'package:keklist/presentation/core/widgets/pinch_columns_detector.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart' hide DateUtils;
import 'package:keklist/presentation/core/screen/kek_screen_state.dart';
import 'package:keklist/presentation/core/shake/shake_to_tweak_mixin.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_switcher.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/screens/mind_creator/mind_creator_screen.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/domain/constants.dart';
import 'package:keklist/presentation/core/helpers/bloc_utils.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';
import 'package:keklist/presentation/core/helpers/mind_utils.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart';
import 'package:keklist/presentation/core/widgets/kek_floating_button.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/domain/repositories/weather/weather_repository.dart';
import 'package:keklist/presentation/cubits/weather/weather_cubit.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/media_folder_settings_bottom_sheet/media_folder_settings_bottom_sheet.dart';
import 'package:keklist/domain/services/weather/weather_api_service.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/weather_settings_bottom_sheet/weather_settings_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/presentation/blocs/membership_bloc/membership_bloc.dart';
import 'package:keklist/presentation/screens/paywall/paywall_bottom_sheet.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_cubit.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_settings_bottom_sheet.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_sliver.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_tile_menu.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_weather_backdrop.dart';
import 'package:keklist/domain/services/media_index/gallery_indexer.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';
import 'package:keklist/presentation/core/haptics/tweak_haptics.dart';

const double _kFloatingButtonClearance = 96.0;

final class MindDayCollectionScreen extends StatefulWidget {
  final int initialDayIndex;

  /// Extra bottom offset for the floating "Create" button so it clears an
  /// overlaying tab bar. Pass the tab bar height when hosted inside the tab
  /// container; leave 0 for standalone (pushed) usage with no tab bar.
  final double fabBottomOffset;

  const MindDayCollectionScreen({super.key, required this.initialDayIndex, this.fabBottomOffset = 0.0});

  @override
  // ignore: no_logic_in_create_state
  State<MindDayCollectionScreen> createState() => MindDayCollectionScreenState(dayIndex: initialDayIndex);
}

final class MindDayCollectionScreenState extends KekWidgetState<MindDayCollectionScreen> with ShakeToTweakMixin, SingleTickerProviderStateMixin {
  int dayIndex;
  final List<Mind> allMinds = [];

  final ScrollController _scrollController = ScrollController();
  late final DaySlideController _daySlide = DaySlideController(vsync: this);

  bool _hasReceivedSettings = false;
  bool _isWeatherSourceEnabled = false;
  double? _weatherLatitude;
  double? _weatherLongitude;
  String? _mediaFolderPath;
  bool _isMediaFolderRecursive = false;
  WeatherCubit? _weatherCubit;
  bool _pendingWeatherEnable = false;
  late final DayFeedCubit _dayFeedCubit = DayFeedCubit(galleryIndexer: context.read<GalleryIndexer>());
  DayFeedSettings _dayFeedSettings = const DayFeedSettings();

  MindDayCollectionScreenState({required this.dayIndex});

  @override
  void initState() {
    super.initState();

    _weatherCubit = WeatherCubit(
      repository: context.read<WeatherRepository>(),
      apiService: WeatherApiService(),
    );

    DayFeedTileMenu.mediaDeleted.listen((_) => _reloadDayFeedMedia(dayIndex)).disposed(by: this);
    context
        .read<GalleryIndexer>()
        .progress
        .skip(1)
        .where((progress) => progress.status == GalleryIndexStatus.ready)
        .listen((_) => _reloadDayFeedMedia(dayIndex, keepsShownMedia: true))
        .disposed(by: this);

    subscribeToBloc<MindBloc>(
      onNewState: (state) async {
        if (state is MindList) {
          setState(() {
            allMinds
              ..clear()
              ..addAll(state.values.sortedBySortIndex());
          });
          _dayFeedCubit.setMinds(dayIndex: dayIndex, allMinds: allMinds);
        }
      },
    )?.disposed(by: this);

    subscribeToBloc<SettingsBloc>(
      onNewState: (state) {
        if (state is SettingsDataState) {
          setState(() {
            _dayFeedSettings = state.settings.dayFeed;
          });
          _dayFeedCubit.setHiddenMediaIds(state.settings.hiddenMediaIds);
          final bool weatherEnabled = state.settings.isWeatherSourceEnabled;
          final double? lat = state.settings.weatherLatitude;
          final double? lon = state.settings.weatherLongitude;
          if (weatherEnabled != _isWeatherSourceEnabled || lat != _weatherLatitude || lon != _weatherLongitude) {
            setState(() {
              _isWeatherSourceEnabled = weatherEnabled;
              _weatherLatitude = lat;
              _weatherLongitude = lon;
            });
            if (weatherEnabled && lat != null && lon != null) {
              _weatherCubit?.loadForDay(dayIndex: dayIndex, latitude: lat, longitude: lon);
            }
          }
          final String? folderPath = state.settings.mediaFolderPath;
          final bool folderRecursive = state.settings.isMediaFolderRecursive;
          final bool isFirstSettings = !_hasReceivedSettings;
          if (isFirstSettings || folderPath != _mediaFolderPath || folderRecursive != _isMediaFolderRecursive) {
            _hasReceivedSettings = true;
            _mediaFolderPath = folderPath;
            _isMediaFolderRecursive = folderRecursive;
            _reloadDayFeedMedia(dayIndex);
          }
        }
      },
    )?.disposed(by: this);

    subscribeToBloc<MembershipBloc>(
      onNewState: (state) {
        if (state is MembershipDataState && state.isPro && _pendingWeatherEnable) {
          _pendingWeatherEnable = false;
          sendEventToBloc<SettingsBloc>(const SettingsToggleWeatherSource(isEnabled: true));
        }
      },
    )?.disposed(by: this);

    sendEventToBloc<MindBloc>(MindGetList());
    sendEventToBloc<SettingsBloc>(SettingsGet());
  }

  @override
  String get shakeScreenId => ShakeScreenIds.day;

  @override
  void onShakeToTweak() => _showDayFeedSettings();

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final DateTime dayDate = DateUtils.getDateFromDayIndex(dayIndex);
    final String formattedDay = DateFormatters.dayMonthFormat(locale).format(dayDate);
    final String yearSuffix = dayDate.year == DateTime.now().year ? '' : ' ${dayDate.year}';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: BlocBuilder<DayFeedCubit, DayFeedState>(
          bloc: _dayFeedCubit,
          builder: (context, state) => GlassAppBar(
            centerTitle: true,
            onTitleTap: () async {
              final int? selectedDayIndex = await _showDateSwitcherToNewDay();
              if (selectedDayIndex == null) return;
              _slideToDay(selectedDayIndex);
            },
            onTitleLongPress: requestTweak,
            titlePadding: const EdgeInsets.symmetric(horizontal: 2.0),
            title: DaySwitcherTitle(
              dayIndex: dayIndex,
              onPrevious: () => _slideToDay(dayIndex - 1),
              onNext: () => _slideToDay(dayIndex + 1),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$formattedDay$yearSuffix',
                    style: const TextStyle(fontSize: 14.0, fontWeight: .w600, height: 1.0),
                  ),
                  Text(
                    DateFormatters.formatWeekday(dayDate, locale),
                    style: const TextStyle(fontSize: 11.0, fontWeight: .w400, height: 1.1),
                  ),
                ],
              ),
            ),
            actions: [
              if (state.items.isNotEmpty)
                GlassBarAction(
                  icon: Icons.play_arrow_rounded,
                  tooltip: context.l10n.calendarPlayStories,
                  onPressed: () => _openDayStories(state, 0),
                ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingButtons(),
      body: Stack(
        children: [
          _buildWeatherBackdrop(),
          DaySwipeArea(
            controller: _daySlide,
            onPrevious: () => _slideToDay(dayIndex - 1),
            onNext: () => _slideToDay(dayIndex + 1),
            child: _buildDayFeedBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherBackdrop() {
    if (!_isWeatherSourceEnabled || _weatherCubit == null) return const SizedBox.shrink();
    return Positioned(
      right: 16.0,
      bottom: _kFloatingButtonClearance + widget.fabBottomOffset + MediaQuery.paddingOf(context).bottom,
      child: BlocBuilder<WeatherCubit, WeatherState>(
        bloc: _weatherCubit,
        builder: (context, state) =>
            state is WeatherLoaded ? DayWeatherBackdrop(data: state.data) : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.fabBottomOffset),
      child: KekFloatingButton(
        onPressed: () => _showMindCreator(),
        label: context.l10n.create,
        fallbackIcon: Icons.add,
        sfSymbol: 'plus',
      ),
    );
  }

  Widget _buildDayFeedBody() {
    return PinchColumnsDetector(
      columnCount: _dayFeedSettings.columnCount,
      onChanged: (count) => sendEventToBloc<SettingsBloc>(SettingsUpdateDayFeed(columnCount: count)),
      builder: (_, isPinching) => _buildDayFeedScrollView(isPinching: isPinching),
    );
  }

  Widget _buildDayFeedScrollView({required bool isPinching}) {
    return CustomScrollView(
      physics: isPinching ? const NeverScrollableScrollPhysics() : FlutterConstants.mobileOverscrollPhysics,
      controller: _scrollController,
      slivers: [
        BlocBuilder<DayFeedCubit, DayFeedState>(
          bloc: _dayFeedCubit,
          builder: (context, state) => DayFeedSliver(
            state: state,
            settings: _dayFeedSettings,
            onOpenItem: (index) => DayItemViewerScreen.show(
              context,
              items: _arrangedItems(state),
              initialIndex: index,
            ),
            onResolveMediaIssue: (issue) => _resolveDayFeedMediaIssue(issue),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.only(
            bottom: _kFloatingButtonClearance + widget.fabBottomOffset + MediaQuery.paddingOf(context).bottom,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    cancelSubscriptions();
    _weatherCubit?.close();
    _dayFeedCubit.close();
    _daySlide.dispose();
    super.dispose();
  }

  Future<int?> _showDateSwitcherToNewDay() async {
    final List<DateTime?>? dates = await showCalendarDatePicker2Dialog(
      context: context,
      value: [DateUtils.getDateFromDayIndex(this.dayIndex)],
      config: CalendarDatePicker2WithActionButtonsConfig(firstDayOfWeek: 1),
      dialogSize: const Size(325, 400),
      borderRadius: BorderRadius.circular(15),
    );

    final DateTime? selectedDateTime = dates?.firstOrNull;
    if (selectedDateTime == null) {
      return null;
    }

    final int dayIndex = DateUtils.getDayIndex(from: selectedDateTime);
    return dayIndex;
  }

  void _showMediaFolderSettings() {
    KekSheet.show(
      context: context,
      builder: (_) => MediaFolderSettingsBottomSheet(
        initialFolderPath: _mediaFolderPath,
        isRecursive: _isMediaFolderRecursive,
        onFolderPicked: (path) {
          sendEventToBloc<SettingsBloc>(SettingsUpdateMediaFolderSource(folderPath: path));
        },
        onRecursiveChanged: (value) {
          sendEventToBloc<SettingsBloc>(SettingsUpdateMediaFolderSource(isRecursive: value));
        },
      ),
    );
  }

  Future<void> _onWeatherToggled(bool enabled) async {
    if (!enabled) {
      sendEventToBloc<SettingsBloc>(const SettingsToggleWeatherSource(isEnabled: false));
      return;
    }
    final membershipState = context.read<MembershipBloc>().state;
    final bool isPro = membershipState is MembershipDataState && membershipState.isPro;
    if (isPro) {
      sendEventToBloc<SettingsBloc>(const SettingsToggleWeatherSource(isEnabled: true));
    } else {
      _pendingWeatherEnable = true;
      final purchased = await PaywallBottomSheet.show(context);
      if (purchased) sendEventToBloc<MembershipBloc>(const MembershipRefreshEvent());
    }
  }

  void _showWeatherSettings() {
    KekSheet.show(
      context: context,
      builder: (_) => WeatherSettingsBottomSheet(
        initialLatitude: _weatherLatitude,
        initialLongitude: _weatherLongitude,
        weatherApiService: WeatherApiService(),
        onSave: (lat, lon) {
          sendEventToBloc<SettingsBloc>(SettingsUpdateWeatherLocation(latitude: lat, longitude: lon));
        },
      ),
    );
  }

  void goToToday() => _slideToDay(DateUtils.getTodayIndex());

  // The day slides out towards where it is in time and the new one slides in from the other side.
  Future<void> _slideToDay(int newDayIndex) async {
    if (newDayIndex == dayIndex || _daySlide.isSliding) return;
    tweakChangeHaptic();
    await _daySlide.slide(forward: newDayIndex > dayIndex, onSwap: () => _switchToDayIndex(newDayIndex));
  }

  void _switchToDayIndex(int dayIndex) {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    setState(() {
      this.dayIndex = dayIndex;
    });
    _reloadWeather(dayIndex);
    _reloadDayFeed(dayIndex);
  }

  void _reloadWeather(int dayIndex) {
    if (_isWeatherSourceEnabled && _weatherLatitude != null && _weatherLongitude != null) {
      _weatherCubit?.loadForDay(dayIndex: dayIndex, latitude: _weatherLatitude!, longitude: _weatherLongitude!);
    }
  }

  void _reloadDayFeed(int dayIndex) {
    _dayFeedCubit.setMinds(dayIndex: dayIndex, allMinds: allMinds);
    _reloadDayFeedMedia(dayIndex);
  }

  void _reloadDayFeedMedia(int dayIndex, {bool requestPhotoAccess = false, bool keepsShownMedia = false}) {
    _dayFeedCubit.loadMedia(
      dayIndex: dayIndex,
      folderPath: _mediaFolderPath,
      isFolderRecursive: _isMediaFolderRecursive,
      requestPhotoAccess: requestPhotoAccess,
      keepsShownMedia: keepsShownMedia,
    );
  }

  void _showDayFeedSettings() {
    KekSheet.show(
      context: context,
      builder: (_) => DayFeedSettingsBottomSheet(
        onWeatherToggled: _onWeatherToggled,
        onWeatherLocation: _showWeatherSettings,
        onMediaFolder: _showMediaFolderSettings,
      ),
    );
  }

  Future<void> _resolveDayFeedMediaIssue(DayFeedMediaIssue issue) async {
    switch (issue) {
      case DayFeedMediaIssue.photoAccessDenied:
        await _dayFeedCubit.loadMedia(
          dayIndex: dayIndex,
          folderPath: _mediaFolderPath,
          isFolderRecursive: _isMediaFolderRecursive,
          requestPhotoAccess: true,
        );
        if (_dayFeedCubit.state.mediaIssue == DayFeedMediaIssue.photoAccessDenied) PhotoManager.openSetting();
      case DayFeedMediaIssue.folderNotChosen:
        _showMediaFolderSettings();
    }
  }

  void _openDayStories(DayFeedState state, int initialIndex) =>
      DayItemViewerScreen.show(context, items: _arrangedItems(state), initialIndex: initialIndex, autoplay: true);

  List<DayFeedItem> _arrangedItems(DayFeedState state) => DayFeedLayout.arrangedItems(
    state.items,
    sortOrder: _dayFeedSettings.sortOrder,
    grouping: _dayFeedSettings.grouping,
  );

  void _showMindCreator() {
    // Pushed as a full-screen route (not a bottom sheet) so a stray swipe can't
    // dismiss it; fullscreenDialog disables the iOS back-swipe — close/save only.
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) {
          return MindCreatorScreen(
            onDone: (String text, List<String> emotionIds) {
              final String normalizedText = text.trim();
              final MindNoteContent content = normalizedText.isEmpty
                  ? MindNoteContent.empty()
                  : MindNoteContent.parse(normalizedText);
              final MindCreate event = MindCreate(
                dayIndex: dayIndex,
                mindContent: content.pieces,
                rootId: null,
                emotionIds: emotionIds,
              );
              sendEventToBloc<MindBloc>(event);
            },
          );
        },
      ),
    );
  }
}
