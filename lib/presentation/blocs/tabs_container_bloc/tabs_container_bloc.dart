import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/constants.dart';
import 'package:keklist/domain/services/analytics/analytics.dart';
import 'package:keklist/domain/repositories/tabs/models/tabs_settings.dart';
import 'package:keklist/domain/repositories/tabs/tabs_settings_repository.dart';
import 'package:keklist/domain/repositories/debug_menu/debug_menu_repository.dart';
import 'package:keklist/presentation/blocs/tabs_container_bloc/tabs_container_event.dart';
import 'package:keklist/presentation/blocs/tabs_container_bloc/tabs_container_state.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';

final class TabsContainerBloc extends Bloc<TabsContainerEvent, TabsContainerState> with DisposeBag {
  final TabsSettingsRepository _repository;
  final DebugMenuRepository _debugMenuRepository;

  TabsContainerBloc({
    required TabsSettingsRepository repository,
    required DebugMenuRepository debugMenuRepository,
  })  : _repository = repository,
        _debugMenuRepository = debugMenuRepository,
        super(
          TabsContainerState(
            selectedTabIndex: 0,
            selectedTabs: [],
            hiddenTabs: KeklistConstants.availableTabModels,
          ),
        ) {
    on<TabsContainerGetCurrentState>(_sendState);
    on<TabsContainerChangeSelectedTab>(_changeTab);
    on<TabsContainerSelectTab>(_selectTab);
    on<TabsContainerUnselectTab>(_unselectTab);
    on<TabsContainerReorderTabs>(_reorderTabs);
    _repository.stream.listen((data) => add(TabsContainerGetCurrentState())).disposed(by: this);
    _debugMenuRepository.developerModeStream.listen((_) => add(TabsContainerGetCurrentState())).disposed(by: this);
    _debugMenuRepository.stream.listen((_) => add(TabsContainerGetCurrentState())).disposed(by: this);
    Analytics.isAiChatFlagOn.addListener(_refresh);
  }

  @override
  Future<void> close() {
    Analytics.isAiChatFlagOn.removeListener(_refresh);
    cancelSubscriptions();
    return super.close();
  }

  void _refresh() => add(TabsContainerGetCurrentState());

  /// The Chat tab sits behind the `ai-chat` flag in PostHog; the debug menu can force it on.
  bool get _isAiChatOn =>
      Analytics.isAiChatFlagOn.value ||
      _debugMenuRepository.value.any((item) => item.type == DebugMenuType.forceAiChat && item.value);

  List<TabModel> get _availableTabModels {
    return KeklistConstants.availableTabModels
        .where((tab) => tab.type != TabType.debugMenu && (tab.type != TabType.ai || _isAiChatOn))
        .toList();
  }

  FutureOr<void> _sendState(
    TabsContainerGetCurrentState event,
    Emitter<TabsContainerState> emit,
  ) {
    final availableTabs = _availableTabModels;
    final selectedTabs = _repository.value.selectedTabModels
        .where((tab) => availableTabs.any((available) => available.type == tab.type))
        .toList();

    final TabsContainerState newState = TabsContainerState(
      selectedTabIndex: _getSelectedTabIndex(selectedTabs),
      selectedTabs: selectedTabs,
      hiddenTabs: _availableTabModels
          .where((tab) => !_repository.value.selectedTabModels.map((tab) => tab.type).contains(tab.type))
          .toList(),
    );
    emit(newState);
  }

  FutureOr<void> _changeTab(
    TabsContainerChangeSelectedTab event,
    Emitter<TabsContainerState> emit,
  ) {
    emit(
      TabsContainerState(
        selectedTabIndex: event.selectedIndex,
        selectedTabs: state.selectedTabs,
        hiddenTabs: _availableTabModels
            .where((tab) => !_repository.value.selectedTabModels.map((tab) => tab.type).contains(tab.type))
            .toList(),
      ),
    );
  }

  FutureOr<void> _selectTab(TabsContainerSelectTab event, Emitter<TabsContainerState> emit) {
    final TabModel selectedTabModel =
        KeklistConstants.availableTabModels.firstWhere((tabModel) => tabModel.type == event.tabType);
    _repository.update(tabModels: _repository.value.selectedTabModels + [selectedTabModel]);
  }

  FutureOr<void> _unselectTab(TabsContainerUnselectTab event, Emitter<TabsContainerState> emit) {
    final List<TabModel> updatedTabList =
        _repository.value.selectedTabModels.where((tabModel) => tabModel.type != event.tabType).toList();
    _repository.update(tabModels: updatedTabList);
  }

  FutureOr<void> _reorderTabs(TabsContainerReorderTabs event, Emitter<TabsContainerState> emit) {
    final List<TabModel> updatedTabs = List.of(_repository.value.selectedTabModels);
    final tab = updatedTabs.removeAt(event.oldIndex);
    updatedTabs.insert(event.newIndex, tab);
    _repository.update(tabModels: updatedTabs);
  }

  // Follows the selected tab when tabs appear or move, else clamps: a tab behind a flag can come and go.
  int _getSelectedTabIndex(List<TabModel> tabs) {
    final int tabCount = tabs.length;
    if (tabCount <= 0) return 0;
    final List<TabModel> previousTabs = state.selectedTabs;
    if (state.selectedTabIndex < previousTabs.length) {
      final TabType selectedType = previousTabs[state.selectedTabIndex].type;
      final int index = tabs.indexWhere((tab) => tab.type == selectedType);
      if (index >= 0) return index;
    }
    if (state.selectedTabIndex >= tabCount - 1) {
      return tabCount - 1;
    } else if (state.selectedTabIndex <= 0) {
      return 0;
    } else {
      return state.selectedTabIndex;
    }
  }
}
