import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/services/analytics/analytics.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/glass_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

/// The analytics switch, what is and is never sent, and a reset of the anonymous id.
final class AnalyticsSettingsScreen extends StatelessWidget {
  const AnalyticsSettingsScreen({super.key});

  static Future<void> show(BuildContext context) =>
      Navigator.of(context).push<void>(SwipeablePageRoute<void>(builder: (_) => const AnalyticsSettingsScreen()));

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isEnabled = context.select<SettingsBloc, bool>(
      (bloc) => switch (bloc.state) {
        SettingsDataState(:final settings) => settings.isAnalyticsEnabled,
        _ => true,
      },
    );
    final TextStyle? hint = theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor);
    final EdgeInsets padding = MediaQuery.paddingOf(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(centerTitle: true, title: Text(context.l10n.analytics)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.0, padding.top + kToolbarHeight + 16.0, 16.0, padding.bottom + 24.0),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile.adaptive(
              title: Text(context.l10n.analytics),
              value: isEnabled,
              onChanged: (value) => context.read<SettingsBloc>().add(SettingsSetAnalyticsEnabled(isEnabled: value)),
            ),
          ),
          const SizedBox(height: 12.0),
          Text(context.l10n.analyticsDescription, style: hint),
          if (!Analytics.isSupported) ...[
            const SizedBox(height: 8.0),
            Text(context.l10n.analyticsStoreBuildsOnly, style: hint),
          ],
          const SizedBox(height: 24.0),
          _Section(
            icon: Icons.check_circle_outline_rounded,
            title: context.l10n.analyticsSent,
            text: context.l10n.analyticsSentItems,
          ),
          const SizedBox(height: 16.0),
          _Section(
            icon: Icons.block_rounded,
            title: context.l10n.analyticsNeverSent,
            text: context.l10n.analyticsNeverSentItems,
          ),
          const SizedBox(height: 24.0),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.l10n.analyticsResetId),
            onPressed: () async {
              await Analytics.resetId();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.analyticsResetIdDone)));
            },
          ),
        ],
      ),
    );
  }
}

final class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _Section({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12.0,
      children: [
        Icon(icon, size: 22.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4.0,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              Text(text, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
