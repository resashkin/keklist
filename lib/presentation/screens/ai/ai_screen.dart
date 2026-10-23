import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/tabs/models/tabs_settings.dart';
import 'package:keklist/domain/services/ai/ai_backend.dart';
import 'package:keklist/domain/services/ai/ai_entities.dart';
import 'package:keklist/presentation/blocs/tabs_container_bloc/tabs_container_bloc.dart';
import 'package:keklist/presentation/blocs/tabs_container_bloc/tabs_container_state.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/glass_app_bar.dart';
import 'package:keklist/presentation/core/widgets/kek_floating_button.dart';
import 'package:keklist/presentation/screens/ai/ai_chat_screen.dart';
import 'package:keklist/presentation/screens/ai/ai_format.dart';
import 'package:keklist/presentation/screens/ai/ai_models_screen.dart';
import 'package:keklist/presentation/screens/ai/widgets/ai_persona_picker_sheet.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

/// The chat tab: previous sessions; a tap opens the chat, the floating button starts a new one.
final class AiScreen extends StatefulWidget {
  const AiScreen({super.key, this.fabBottomOffset = 0.0});

  final double fabBottomOffset;

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

  void _visibilityChanged(TabsContainerState state) {
    final bool isVisible =
        state.selectedTabIndex < state.selectedTabs.length &&
        state.selectedTabs[state.selectedTabIndex].type == TabType.ai;
    if (isVisible == _isVisible) return;
    _isVisible = isVisible;
    if (isVisible) _promptForModelOnce(context.read<AiBackend>());
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: backend.modelName == null
            ? null
            : Padding(
                padding: EdgeInsets.only(bottom: widget.fabBottomOffset),
                child: KekFloatingButton(
                  onPressed: () => _newSession(backend),
                  label: context.l10n.aiNewSession,
                  fallbackIcon: Icons.add_comment_rounded,
                  sfSymbol: 'plus.bubble',
                ),
              ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.paddingOf(context).top + 64.0),
                if (backend.modelName == null) _NoModelCard(canManage: backend.canManage),
                Expanded(
                  child: backend.sessions.isEmpty
                      ? const _NoSessions()
                      : ListView(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.paddingOf(context).bottom + widget.fabBottomOffset + 96.0,
                          ),
                          children: [
                            for (final AiSession session in backend.sessions)
                              _SessionTile(
                                session: session,
                                persona: backend.personaOf(session),
                                onTap: () => AiChatScreen.open(context, sessionId: session.id),
                                onDelete: () => _deleteSession(backend, session),
                              ),
                          ],
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

/// Centered while there are no sessions, with the reminder that this isn't a medical service.
final class _NoSessions extends StatelessWidget {
  const _NoSessions();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8.0,
          children: [
            Icon(Icons.forum_outlined, size: 48.0, color: theme.hintColor),
            Text(context.l10n.aiNoSessions, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            Text(
              context.l10n.aiNoSessionsHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            ),
            const SizedBox(height: 8.0),
            Text(
              context.l10n.aiDisclaimer,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor.withValues(alpha: 0.7)),
            ),
          ],
        ),
      ),
    );
  }
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
