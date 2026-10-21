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
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: true,
      actions: _makeAppBarActions(),
      title: GestureDetector(
        onTap: onTitle,
        onLongPress: onTitleLongPress,
        child: Row(children: [
          const Icon(Icons.calendar_view_week),
          const Gap(8.0),
          Text(context.l10n.calendar),
        ]),
      ),
    );
  }

  List<Widget>? _makeAppBarActions() => [
        if (onInsights != null) ...{
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: onInsights,
          ),
        },
        if (onSettings != null) ...{
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: onSettings,
          ),
        },
        IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: onCalendar,
        ),
        IconButton(icon: const Icon(Icons.search), onPressed: onSearch),
      ];
}
