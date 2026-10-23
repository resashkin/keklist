import 'package:keklist/presentation/core/haptics/tweak_haptics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/screens/settings/settings_layout.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';

final class SettingsCustomizeBottomSheet extends StatelessWidget {
  static const double _rowIndent = 24.0;

  final List<SettingsSectionModel> sections;

  const SettingsCustomizeBottomSheet({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    return KekSheetScaffold(
      title: context.l10n.customizeSettings,
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (_, current) => current is SettingsDataState,
        builder: (context, state) {
          final Set<String> hiddenIds = state is SettingsDataState ? state.settings.hiddenSettingsItemIds : {};
          return _buildContent(context, hiddenIds);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Set<String> hiddenIds) {
    final ThemeData theme = Theme.of(context);
    void toggle(String id, bool isVisible) {
      tweakChangeHaptic();
      context.read<SettingsBloc>().add(SettingsUpdateItemHidden(id: id, isHidden: !isVisible));
    }

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 8.0),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
          child: Text(
            context.l10n.customizeSettingsDescription,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            textAlign: TextAlign.center,
          ),
        ),
        for (final SettingsSectionModel section in sections) ...[
          CheckboxListTile(
            title: Text(section.title, style: theme.textTheme.titleSmall),
            value: !hiddenIds.contains(section.id),
            onChanged: (value) => toggle(section.id, value ?? true),
          ),
          for (final SettingsRowModel row in section.rows)
            CheckboxListTile(
              contentPadding: const EdgeInsetsDirectional.only(start: _rowIndent, end: 16.0),
              enabled: !hiddenIds.contains(section.id),
              secondary: row.leading,
              title: Text(row.title),
              value: !hiddenIds.contains(row.id),
              onChanged: (value) => toggle(row.id, value ?? true),
            ),
        ],
      ],
    );
  }
}
