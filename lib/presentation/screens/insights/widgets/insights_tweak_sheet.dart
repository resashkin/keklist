import 'package:keklist/presentation/core/haptics/tweak_haptics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/screens/insights/insights_widget_id.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';

/// Shake-to-tweak sheet of the analytics screen: show/hide cards and drag to reorder.
final class InsightsTweakSheet extends StatelessWidget {
  const InsightsTweakSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (_, current) => current is SettingsDataState,
      builder: (context, state) {
        final InsightsSettings insights = state is SettingsDataState
            ? state.settings.insights
            : const InsightsSettings();
        return _buildContent(context, insights);
      },
    );
  }

  Widget _buildContent(BuildContext context, InsightsSettings insights) {
    final ThemeData theme = Theme.of(context);
    final List<InsightsWidgetId> order = InsightsWidgetId.ordered(insights.widgetOrder);
    void save(InsightsSettings updated) {
      tweakChangeHaptic();
      context.read<SettingsBloc>().add(SettingsUpdateInsights(insights: updated));
    }

    return KekSheetScaffold(
      title: context.l10n.insightsCustomize,
      leading: TextButton(
        onPressed: () => save(InsightsSettings(periodIndex: insights.periodIndex)),
        child: Text(context.l10n.insightsResetLayout),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
            child: Text(
              context.l10n.insightsCustomizeDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
          ),
          Flexible(
            child: ReorderableListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 8.0),
              itemCount: order.length,
              onReorderItem: (oldIndex, newIndex) {
                final List<InsightsWidgetId> updated = List.of(order);
                updated.insert(newIndex, updated.removeAt(oldIndex));
                save(insights.copyWith(widgetOrder: updated.map((id) => id.name).toList()));
              },
              itemBuilder: (context, index) {
                final InsightsWidgetId id = order[index];
                final bool isVisible = !insights.hiddenWidgetIds.contains(id.name);
                return CheckboxListTile(
                  key: ValueKey(id.name),
                  controlAffinity: ListTileControlAffinity.leading,
                  secondary: Icon(Icons.drag_handle, color: theme.hintColor),
                  title: Text(id.title(context)),
                  subtitle: Text(id.category.title(context), style: TextStyle(color: id.category.color)),
                  value: isVisible,
                  onChanged: (value) => save(
                    insights.copyWith(
                      hiddenWidgetIds: value ?? true
                          ? (insights.hiddenWidgetIds.toSet()..remove(id.name))
                          : {...insights.hiddenWidgetIds, id.name},
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
