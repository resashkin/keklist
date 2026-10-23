import 'package:material_ui/material_ui.dart' hide DateUtils;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/tabs/models/tabs_settings.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/blocs/tabs_container_bloc/tabs_container_bloc.dart';
import 'package:keklist/presentation/blocs/tabs_container_bloc/tabs_container_event.dart';
import 'package:keklist/presentation/blocs/tabs_container_bloc/tabs_container_state.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';
import 'package:keklist/presentation/core/helpers/bloc_utils.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart';
import 'package:keklist/presentation/core/helpers/interface_style_utils.dart';
import 'package:keklist/presentation/core/widgets/bool_widget.dart';
import 'package:keklist/presentation/core/widgets/bottom_navigation_bar.dart';
import 'package:keklist/presentation/screens/insights/insights_screen.dart';
import 'package:keklist/presentation/screens/mind_collection/mind_collection_screen.dart';
import 'package:keklist/presentation/screens/mind_day_collection/mind_day_collection_screen.dart';
import 'package:keklist/presentation/screens/settings/settings_screen.dart';

/// Wider screens get the tabs as a rail on the left, like a desktop app.
const double _kRailMinWidth = 800.0;
const double _kContentMaxWidth = 840.0;

final class TabsContainerScreen extends StatefulWidget {
  const TabsContainerScreen({super.key});

  @override
  State<TabsContainerScreen> createState() => _TabsContainerScreenState();
}

final class _TabsContainerScreenState extends State<TabsContainerScreen> with DisposeBag {
  int _selectedTabIndex = 0;
  final List<BottomNavigationBarItem> _items = [];
  final List<Widget> _bodyWidgets = [];
  List<TabType> _tabTypes = [];
  bool _useLiquidGlass = false;
  bool _isWide = false;
  final GlobalKey<MindDayCollectionScreenState> _todayKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    subscribeToBloc<TabsContainerBloc>(
      onNewState: (state) async {
        if (state is TabsContainerState) {
          setState(() {
            _selectedTabIndex = state.selectedTabIndex;
            final Iterable<BottomNavigationBarItem> items = state.selectedTabs.map(
              (item) => BottomNavigationBarItem(icon: item.type.materialIcon, label: item.type.localizedLabel(context)),
            );
            _items
              ..clear()
              ..addAll(items);

            _tabTypes = state.selectedTabs.map((item) => item.type).toList();
            final Iterable<Widget> bodyWidgets = _tabTypes.map(_bodyWidgetByType);
            _bodyWidgets
              ..clear()
              ..addAll(bodyWidgets);
          });
        }
      },
    )?.disposed(by: this);
    sendEventToBloc<TabsContainerBloc>(TabsContainerGetCurrentState());

    _useLiquidGlass = _readUseLiquidGlass(context.read<SettingsBloc>().state);
    subscribeToBloc<SettingsBloc>(
      onNewState: (state) {
        final bool next = _readUseLiquidGlass(state);
        if (next != _useLiquidGlass) {
          setState(() {
            _useLiquidGlass = next;
            // Rebuild cached body children so the Today tab's fabBottomOffset tracks the new value.
            final Iterable<Widget> bodyWidgets = _tabTypes.map(_bodyWidgetByType);
            _bodyWidgets
              ..clear()
              ..addAll(bodyWidgets);
          });
        }
      },
    )?.disposed(by: this);
  }

  bool _readUseLiquidGlass(SettingsState state) {
    if (state is! SettingsDataState) return _useLiquidGlass;
    return resolveUseLiquidGlass(state.settings.interfaceStyle);
  }

  @override
  void dispose() {
    super.dispose();

    cancelSubscriptions();
  }

  bool get _isTabBarVisible => _items.length >= 2;

  @override
  Widget build(BuildContext context) {
    final bool isWide = _isTabBarVisible && MediaQuery.sizeOf(context).width >= _kRailMinWidth;
    if (isWide != _isWide) {
      _isWide = isWide;
      // The Today FAB offset depends on whether a bottom bar overlaps the body.
      _bodyWidgets
        ..clear()
        ..addAll(_tabTypes.map(_bodyWidgetByType));
    }
    // On wide screens the content stays a readable column instead of stretching edge to edge.
    final Widget body = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kContentMaxWidth),
        child: IndexedStack(index: _selectedTabIndex, children: _bodyWidgets),
      ),
    );
    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              right: false,
              child: NavigationRail(
                selectedIndex: _selectedTabIndex,
                onDestinationSelected: _onTap,
                labelType: NavigationRailLabelType.all,
                destinations: [
                  for (final BottomNavigationBarItem item in _items)
                    NavigationRailDestination(icon: item.icon, label: Text(item.label ?? '')),
                ],
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: body),
          ],
        ),
      );
    }
    return Scaffold(
      extendBody: _useLiquidGlass,
      body: body,
      bottomNavigationBar: BoolWidget(
        condition: _isTabBarVisible,
        trueChild: AdaptiveBottomNavigationBar(
          items: List.of(_isTabBarVisible ? _items : _getFakeItems()),
          tabTypes: _tabTypes,
          useLiquidGlass: _useLiquidGlass,
          selectedIndex: _selectedTabIndex,
          onTap: _onTap,
        ),
        falseChild: SizedBox.shrink(),
      ),
    );
  }

  void _onTap(int tabIndex) {
    if (tabIndex == _selectedTabIndex && tabIndex < _tabTypes.length && _tabTypes[tabIndex] == TabType.today) {
      _todayKey.currentState?.goToToday();
    } else {
      sendEventToBloc<TabsContainerBloc>(TabsContainerChangeSelectedTab(selectedIndex: tabIndex));
    }
  }

  List<BottomNavigationBarItem> _getFakeItems() => [
    BottomNavigationBarItem(icon: TabType.calendar.materialIcon, label: TabType.calendar.localizedLabel(context)),
    BottomNavigationBarItem(icon: TabType.settings.materialIcon, label: TabType.settings.localizedLabel(context)),
  ];

  Widget _bodyWidgetByType(TabType type) {
    switch (type) {
      case TabType.calendar:
        return MindCollectionScreen();
      case TabType.insights:
        return InsightsScreen();
      case TabType.settings:
        return SettingsScreen();
      case TabType.today:
        return MindDayCollectionScreen(
          key: _todayKey,
          initialDayIndex: DateUtils.getTodayIndex(),
          // Only lift the FAB above the translucent Liquid Glass nav bar, which
          // overlaps the body via `extendBody`. In Material mode the solid nav
          // bar already reserves its space, so the extra offset would leave a
          // strange gap under the FAB.
          fabBottomOffset: _useLiquidGlass && _isTabBarVisible && !_isWide ? kBottomNavigationBarHeight + 48.0 : 0.0,
        );
      case TabType.debugMenu:
        return const SizedBox.shrink();
    }
  }
}
