import 'package:keklist/presentation/core/widgets/column_count_row.dart';
import 'package:keklist/presentation/core/haptics/tweak_haptics.dart';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';

final class DayFeedSettingsBottomSheet extends StatelessWidget {
  final ValueChanged<bool> onWeatherToggled;
  final VoidCallback onWeatherLocation;
  final VoidCallback onMediaFolder;

  const DayFeedSettingsBottomSheet({
    super.key,
    required this.onWeatherToggled,
    required this.onWeatherLocation,
    required this.onMediaFolder,
  });

  @override
  Widget build(BuildContext context) {
    return KekSheetScaffold(
      title: context.l10n.dayFeedTileSettings,
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (_, current) => current is SettingsDataState,
        builder: (context, state) {
          final KeklistSettings? settings = state is SettingsDataState ? state.settings : null;
          return _buildContent(
            context,
            settings?.dayFeed ?? const DayFeedSettings(),
            isWeatherEnabled: settings?.isWeatherSourceEnabled ?? false,
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, DayFeedSettings settings, {required bool isWeatherEnabled}) {
    void update(SettingsUpdateDayFeed event) {
      tweakChangeHaptic();
      context.read<SettingsBloc>().add(event);
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColumnCountRow(
            title: context.l10n.dayFeedColumns,
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
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.cloud_outlined),
            title: Row(spacing: 6.0, children: [Text(context.l10n.sourcesWeather), const _ProBadge()]),
            subtitle: Text(context.l10n.sourcesWeatherSubtitle),
            value: isWeatherEnabled,
            onChanged: (value) {
              tweakChangeHaptic();
              onWeatherToggled(value);
            },
          ),
          if (isWeatherEnabled)
            ListTile(
              leading: const Icon(Icons.place_outlined),
              title: Text(context.l10n.weatherSettings),
              trailing: const Icon(Icons.chevron_right),
              onTap: onWeatherLocation,
            ),
          if (!kIsWeb && Platform.isAndroid)
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: Text(context.l10n.sourcesMediaFolder),
              subtitle: Text(context.l10n.sourcesMediaFolderSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: onMediaFolder,
            ),
          const SizedBox(height: 8.0),
        ],
      ),
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

final class _ProBadge extends StatelessWidget {
  static const Color _gold = Color(0xFFFFB800);

  const _ProBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
      decoration: BoxDecoration(
        border: Border.all(color: _gold, width: 1.2),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(fontSize: 9.0, fontWeight: FontWeight.bold, color: _gold, height: 1.2, letterSpacing: 0.5),
      ),
    );
  }
}
