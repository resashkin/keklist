import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';

final class DayFeedSettingsBottomSheet extends StatelessWidget {
  const DayFeedSettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (_, current) => current is SettingsDataState,
        builder: (context, state) {
          final DayFeedSettings settings =
              state is SettingsDataState ? state.settings.dayFeed : const DayFeedSettings();
          return _buildContent(context, settings);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, DayFeedSettings settings) {
    final ThemeData theme = Theme.of(context);
    void update(SettingsUpdateDayFeed event) => context.read<SettingsBloc>().add(event);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(context.l10n.dayFeedTileSettings, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
        ),
        _SegmentedRow<int>(
          title: context.l10n.dayFeedColumns,
          options: {for (final int count in DayFeedSettings.columnCountOptions) count: '$count'},
          selected: settings.columnCount,
          onChanged: (count) => update(SettingsUpdateDayFeed(columnCount: count)),
        ),
        _SegmentedRow<int>(
          title: context.l10n.dayFeedMindTileSize,
          options: {1: context.l10n.dayFeedMindTileSquare, 2: context.l10n.dayFeedMindTileWide},
          selected: settings.mindCellSpan,
          onChanged: (span) => update(SettingsUpdateDayFeed(mindCellSpan: span)),
        ),
        SwitchListTile(
          title: Text(context.l10n.dayFeedShowMindText),
          value: settings.isMindTextVisible,
          onChanged: (value) => update(SettingsUpdateDayFeed(isMindTextVisible: value)),
        ),
        SwitchListTile(
          title: Text(context.l10n.dayFeedShowAudioBadge),
          value: settings.isAudioBadgeVisible,
          onChanged: (value) => update(SettingsUpdateDayFeed(isAudioBadgeVisible: value)),
        ),
        const SafeArea(child: SizedBox(height: 8.0)),
      ],
    );
  }
}

final class _SegmentedRow<T> extends StatelessWidget {
  final String title;
  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;

  const _SegmentedRow({required this.title, required this.options, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(
        children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyLarge)),
          SegmentedButton<T>(
            showSelectedIcon: false,
            segments: options.entries
                .map((option) => ButtonSegment<T>(value: option.key, label: Text(option.value)))
                .toList(),
            selected: {selected},
            onSelectionChanged: (selection) => onChanged(selection.first),
          ),
        ],
      ),
    );
  }
}
