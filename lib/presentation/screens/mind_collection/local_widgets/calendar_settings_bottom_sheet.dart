import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:material_ui/material_ui.dart';

/// Shake sheet of the calendar: grid columns and what the day grids show.
final class CalendarSettingsBottomSheet extends StatelessWidget {
  const CalendarSettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (_, current) => current is SettingsDataState,
        builder: (context, state) {
          final KeklistSettings? settings = state is SettingsDataState ? state.settings : null;
          return _buildContent(
            context,
            settings?.calendar ?? const CalendarSettings(),
            showsWeekTitles: settings?.shouldShowTitles ?? true,
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CalendarSettings calendar, {required bool showsWeekTitles}) {
    final ThemeData theme = Theme.of(context);
    void update(CalendarSettings value) => context.read<SettingsBloc>().add(SettingsUpdateCalendar(calendar: value));

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(context.l10n.calendarSettings, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Row(
              children: [
                Expanded(child: Text(context.l10n.dayFeedColumns, style: theme.textTheme.bodyLarge)),
                SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: [
                    for (final int count in DayFeedSettings.columnCountOptions)
                      ButtonSegment<int>(value: count, label: Text('$count')),
                  ],
                  selected: {calendar.columnCount},
                  onSelectionChanged: (selection) => update(calendar.copyWith(columnCount: selection.first)),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: Text(context.l10n.dayFeedShowMindText),
            value: calendar.isMindTextVisible,
            onChanged: (value) => update(calendar.copyWith(isMindTextVisible: value)),
          ),
          SwitchListTile(
            title: Text(context.l10n.calendarShowMedia),
            value: calendar.isMediaVisible,
            onChanged: (value) => update(calendar.copyWith(isMediaVisible: value)),
          ),
          SwitchListTile(
            title: Text(context.l10n.calendarWeekTitles),
            value: showsWeekTitles,
            onChanged: (value) => context.read<SettingsBloc>().add(SettingsUpdateShouldShowTitlesMode(value: value)),
          ),
          SwitchListTile(
            title: Text(context.l10n.calendarHideEmptyDays),
            value: calendar.hidesEmptyDays,
            onChanged: (value) => update(calendar.copyWith(hidesEmptyDays: value)),
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }
}
