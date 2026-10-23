import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/tabs/models/tabs_settings.dart';
import 'package:keklist/domain/services/ai/ai_backend.dart';
import 'package:keklist/domain/services/ai/ai_entities.dart';
import 'package:keklist/presentation/blocs/tabs_container_bloc/tabs_container_bloc.dart';
import 'package:keklist/presentation/blocs/tabs_container_bloc/tabs_container_state.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/glass_app_bar.dart';
import 'package:keklist/presentation/screens/ai/ai_chat_screen.dart';
import 'package:keklist/presentation/screens/ai/ai_format.dart';
import 'package:keklist/presentation/screens/ai/ai_models_screen.dart';
import 'package:keklist/presentation/screens/ai/widgets/ai_persona_picker_sheet.dart';
import 'package:keklist/presentation/screens/ai/widgets/ai_summary_sheet.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

/// The AI tab: summaries of recent days on top, then the previous sessions; a tap opens the chat.
final class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

final class _AiScreenState extends State<AiScreen> {
  static const String _modelPromptedKey = 'ai_model_prompted_v1';
  static const double _maxWidth = 700.0;

  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _visibilityChanged(context.read<TabsContainerBloc>().state);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AiFormat.configure(context, context.read<AiBackend>());
  }

  @override
  void dispose() {
    if (_isVisible) context.read<AiBackend>().setAutoSummaries(false);
    super.dispose();
  }

  void _visibilityChanged(TabsContainerState state) {
    final bool isVisible =
        state.selectedTabIndex < state.selectedTabs.length &&
        state.selectedTabs[state.selectedTabIndex].type == TabType.ai;
    if (isVisible == _isVisible) return;
    _isVisible = isVisible;
    final AiBackend backend = context.read<AiBackend>();
    backend.setAutoSummaries(isVisible);
    if (isVisible) _promptForModelOnce(backend);
  }

  /// The first visit without a model opens the catalog right away.
  Future<void> _promptForModelOnce(AiBackend backend) async {
    if (!backend.canManage || backend.modelName != null) return;
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(_modelPromptedKey) ?? false) return;
    await preferences.setBool(_modelPromptedKey, true);
    if (mounted) await AiModelsScreen.open(context);
  }

  Future<void> _newSession(AiBackend backend) async {
    final AiPersona? persona = await AiPersonaPickerSheet.show(context, personas: backend.personas);
    if (persona == null || !mounted) return;
    final String id = await backend.createSession(persona.id);
    if (mounted) await AiChatScreen.open(context, sessionId: id);
  }

  Future<void> _deleteSession(AiBackend backend, AiSession session) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.aiDeleteSession),
        content: session.title.isEmpty ? null : Text(session.title),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.cancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.delete)),
        ],
      ),
    );
    if (confirmed ?? false) await backend.deleteSession(session.id);
  }

  @override
  Widget build(BuildContext context) {
    final AiBackend backend = context.watch<AiBackend>();
    return BlocListener<TabsContainerBloc, TabsContainerState>(
      listener: (_, state) => _visibilityChanged(state),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: GlassAppBar(
          centerTitle: true,
          title: Text(context.l10n.aiTab),
          actions: [
            if (backend.canManage)
              GlassBarAction(
                icon: Icons.memory_rounded,
                tooltip: context.l10n.aiModels,
                onPressed: () => AiModelsScreen.open(context),
              ),
          ],
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: ListView(
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 64.0,
                bottom: MediaQuery.paddingOf(context).bottom + 120.0,
              ),
              children: [
                if (backend.modelName == null) _NoModelCard(canManage: backend.canManage),
                if (backend.summaryDays.isNotEmpty) ...[
                  _SectionTitle(context.l10n.aiDaySummaries),
                  _SummariesRow(backend: backend),
                ],
                _SectionTitle(
                  context.l10n.aiSessions,
                  action: backend.modelName == null
                      ? null
                      : FilledButton.tonalIcon(
                          onPressed: () => _newSession(backend),
                          icon: const Icon(Icons.add_comment_rounded, size: 18.0),
                          label: Text(context.l10n.aiNewSession),
                        ),
                ),
                if (backend.sessions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(context.l10n.aiNoSessions, style: TextStyle(color: Theme.of(context).hintColor)),
                  ),
                for (final AiSession session in backend.sessions)
                  _SessionTile(
                    session: session,
                    persona: backend.personaOf(session),
                    onTap: () => AiChatScreen.open(context, sessionId: session.id),
                    onDelete: () => _deleteSession(backend, session),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
                  child: Text(
                    '${context.l10n.aiPrivacyNote}\n${context.l10n.aiDisclaimer}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        ),
        ?action,
      ],
    ),
  );
}

final class _NoModelCard extends StatelessWidget {
  const _NoModelCard({required this.canManage});

  final bool canManage;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.0,
        children: [
          Text(context.l10n.aiNoModelTitle, style: Theme.of(context).textTheme.titleMedium),
          Text(canManage ? context.l10n.aiNoModelMessage : context.l10n.aiNoModelOnPhone),
          if (canManage)
            FilledButton.icon(
              onPressed: () => AiModelsScreen.open(context),
              icon: const Icon(Icons.download_rounded),
              label: Text(context.l10n.aiModels),
            ),
        ],
      ),
    ),
  );
}

final class _SummariesRow extends StatelessWidget {
  const _SummariesRow({required this.backend});

  final AiBackend backend;

  static const double _cardWidth = 220.0;
  static const double _height = 150.0;

  @override
  Widget build(BuildContext context) {
    final Map<int, AiDaySummary> summaries = backend.summaries;
    return SizedBox(
      height: _height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: backend.summaryDays.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12.0),
        itemBuilder: (context, index) {
          final int day = backend.summaryDays[index];
          final AiDaySummary? summary = summaries[day];
          final bool isStale = backend.staleSummaryDays.contains(day);
          final bool isRunning = backend.summarizingDays.contains(day);
          final ColorScheme colors = Theme.of(context).colorScheme;
          return SizedBox(
            width: _cardWidth,
            child: Material(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16.0),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  if (summary != null && !isStale) {
                    AiSummarySheet.show(context, dayIndex: day);
                  } else if (backend.modelName != null && !isRunning) {
                    backend.summarizeDay(day);
                  }
                },
                onLongPress: summary == null ? null : () => AiSummarySheet.show(context, dayIndex: day),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6.0,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AiDayLabel.of(context, day),
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (isRunning)
                            const SizedBox.square(dimension: 14.0, child: CircularProgressIndicator(strokeWidth: 2.0))
                          else if (isStale)
                            Icon(Icons.refresh_rounded, size: 16.0, color: colors.primary),
                        ],
                      ),
                      Expanded(
                        child: Text(
                          summary?.text ??
                              (backend.modelName == null ? context.l10n.aiNoModelTitle : context.l10n.aiSummarize),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: summary == null
                              ? TextStyle(color: Theme.of(context).hintColor)
                              : Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      if (isStale)
                        Text(
                          context.l10n.aiSummaryOutdated,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.primary),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

final class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session, required this.persona, required this.onTap, required this.onDelete});

  final AiSession session;
  final AiPersona persona;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final AiMessage? last = session.messages.lastOrNull;
    return Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.onErrorContainer),
      ),
      child: ListTile(
        leading: Text(persona.emoji, style: const TextStyle(fontSize: 28.0)),
        title: Text(session.title.isEmpty ? persona.name : session.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          last == null ? persona.name : last.text.replaceAll('\n', ' '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          MaterialLocalizations.of(context).formatShortMonthDay(session.updatedAt),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).hintColor),
        ),
        onTap: onTap,
      ),
    );
  }
}

/// "Today", "Yesterday" or a short date for a day index.
abstract final class AiDayLabel {
  static String of(BuildContext context, int dayIndex) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(dayIndex * Duration.millisecondsPerDay, isUtc: true);
    final DateTime today = DateTime.now();
    final int todayIndex =
        DateTime.utc(today.year, today.month, today.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
    if (dayIndex == todayIndex) return context.l10n.today;
    if (dayIndex == todayIndex - 1) return context.l10n.aiYesterday;
    return MaterialLocalizations.of(context).formatMediumDate(DateTime(date.year, date.month, date.day));
  }
}

/// Pushes a screen the way the rest of the app does.
Future<T?> pushAiRoute<T>(BuildContext context, WidgetBuilder builder) =>
    Navigator.of(context).push<T>(SwipeablePageRoute<T>(builder: builder));
