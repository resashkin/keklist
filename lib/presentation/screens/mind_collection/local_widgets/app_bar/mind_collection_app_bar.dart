part of '../../mind_collection_screen.dart';

final class _MindCollectionAppBar extends StatelessWidget {
  final VoidCallback onSearch;
  final VoidCallback onTitle;
  final VoidCallback onCalendar;
  final VoidCallback onTitleLongPress;
  final VoidCallback? onSettings;
  final VoidCallback? onInsights;

  const _MindCollectionAppBar({
    required this.onSearch,
    required this.onTitle,
    required this.onCalendar,
    required this.onTitleLongPress,
    required this.onSettings,
    required this.onInsights,
  });

  @override
  Widget build(BuildContext context) {
    return GlassAppBar(
      centerTitle: true,
      onTitleTap: onTitle,
      onTitleLongPress: onTitleLongPress,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8.0,
        children: [const Icon(Icons.calendar_view_week, size: 20.0), Text(context.l10n.calendar)],
      ),
      actions: [
        if (onInsights != null) GlassBarAction(icon: Icons.insights, onPressed: onInsights),
        if (onSettings != null) GlassBarAction(icon: Icons.settings, onPressed: onSettings),
        GlassBarAction(icon: Icons.calendar_month, onPressed: onCalendar),
        GlassBarAction(icon: Icons.search, onPressed: onSearch),
      ],
    );
  }
}
