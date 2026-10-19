import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/screens/settings/settings_layout.dart';

final class SettingsCustomizeBottomSheet extends StatelessWidget {
  static const double _rowIndent = 24.0;

  final List<SettingsSectionModel> sections;

  const SettingsCustomizeBottomSheet({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    return Material(
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
    void toggle(String id, bool isVisible) =>
        context.read<SettingsBloc>().add(SettingsUpdateItemHidden(id: id, isHidden: !isVisible));

    return ListView(
      shrinkWrap: true,
      controller: ModalScrollController.of(context),
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 8.0),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
          child: Text(context.l10n.customizeSettings, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
        ),
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
