import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/services/ai/ai_backend.dart';
import 'package:keklist/domain/services/ai/ai_entities.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart';
import 'package:keklist/presentation/core/widgets/glass_app_bar.dart';
import 'package:keklist/presentation/screens/ai/ai_screen.dart';
import 'package:keklist/presentation/screens/mind_day_collection/mind_day_collection_screen.dart';
import 'package:material_ui/material_ui.dart' hide DateUtils;
import 'package:provider/provider.dart';

/// One session: the conversation, the reply being written, and chips with suggested replies and app actions.
final class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key, required this.sessionId});

  final String sessionId;

  static Future<void> open(BuildContext context, {required String sessionId}) =>
      pushAiRoute(context, (_) => AiChatScreen(sessionId: sessionId));

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

final class _AiChatScreenState extends State<AiChatScreen> {
  static const double _maxWidth = 760.0;

  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _inputFocus = FocusNode();
  int _shownLength = 0;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _send(AiBackend backend, String text) {
    if (text.trim().isEmpty || backend.streaming != null || backend.modelName == null) return;
    _input.clear();
    backend.send(widget.sessionId, text);
  }

  void _saveAsMind(String text) {
    context.read<MindBloc>().add(
      MindCreate(dayIndex: DateUtils.getTodayIndex(), mindContent: [MindNoteText(text)], rootId: null),
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.aiSavedAsMind)));
  }

  void _openDay(int dayIndex) => pushAiRoute<void>(context, (_) => MindDayCollectionScreen(initialDayIndex: dayIndex));

  void _keepAtBottom(int length) {
    if (length == _shownLength) return;
    _shownLength = length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AiBackend backend = context.watch<AiBackend>();
    final AiSession? session = backend.session(widget.sessionId);
    if (session == null) {
      return Scaffold(appBar: GlassAppBar(title: Text(context.l10n.aiTab)));
    }
    final AiPersona persona = backend.personaOf(session);
    final AiStreamingReply? streaming = backend.streaming?.sessionId == session.id ? backend.streaming : null;
    final bool isBusy = backend.streaming != null;
    final AiMessage? lastReply = session.messages.lastOrNull?.role == AiRole.assistant ? session.messages.last : null;
    _keepAtBottom(session.messages.length * 100000 + (streaming?.text.length ?? -1));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(centerTitle: true, title: Text('${persona.emoji} ${persona.name}')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: EdgeInsets.fromLTRB(12.0, MediaQuery.paddingOf(context).top + 64.0, 12.0, 12.0),
                  children: [
                    if (session.messages.isEmpty) _Starters(onSend: (text) => _send(backend, text), enabled: !isBusy),
                    for (final AiMessage message in session.messages) _Bubble(message: message),
                    if (streaming != null) _StreamingBubble(text: streaming.text),
                    if (backend.lastError != null && streaming == null && lastReply == null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(backend.lastError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ),
                    if (lastReply != null && !isBusy)
                      _ReplyChips(
                        reply: lastReply,
                        onSend: (text) => _send(backend, text),
                        onSave: () => _saveAsMind(lastReply.text),
                        onOpenDay: _openDay,
                      ),
                  ],
                ),
              ),
              _InputBar(
                controller: _input,
                focusNode: _inputFocus,
                hasModel: backend.modelName != null,
                isWriting: streaming != null,
                isBusy: isBusy,
                onSend: () => _send(backend, _input.text),
                onStop: backend.stop,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final AiMessage message;

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.role == AiRole.user;
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: isUser ? colors.primaryContainer : colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18.0),
          ),
          child: SelectableText(
            message.text,
            style: TextStyle(color: isUser ? colors.onPrimaryContainer : colors.onSurface, height: 1.35),
          ),
        ),
      ),
    );
  }
}

final class _StreamingBubble extends StatelessWidget {
  const _StreamingBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        decoration: BoxDecoration(color: colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(18.0)),
        child: text.isEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8.0,
                children: [
                  const SizedBox.square(dimension: 14.0, child: CircularProgressIndicator(strokeWidth: 2.0)),
                  Text(context.l10n.aiThinking, style: TextStyle(color: Theme.of(context).hintColor)),
                ],
              )
            : Text(text, style: const TextStyle(height: 1.35)),
      ),
    );
  }
}

final class _Starters extends StatelessWidget {
  const _Starters({required this.onSend, required this.enabled});

  final ValueChanged<String> onSend;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        for (final String text in [context.l10n.aiStarterWeek, context.l10n.aiStarterWorry, context.l10n.aiStarterJoy])
          ActionChip(label: Text(text), onPressed: enabled ? () => onSend(text) : null),
      ],
    ),
  );
}

final class _ReplyChips extends StatelessWidget {
  const _ReplyChips({required this.reply, required this.onSend, required this.onSave, required this.onOpenDay});

  final AiMessage reply;
  final ValueChanged<String> onSend;
  final VoidCallback onSave;
  final ValueChanged<int> onOpenDay;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: [
          for (final String suggestion in reply.suggestions)
            ActionChip(label: Text(suggestion), onPressed: () => onSend(suggestion)),
          ActionChip(
            avatar: Icon(Icons.bookmark_add_outlined, size: 18.0, color: colors.primary),
            label: Text(context.l10n.aiActionSaveAsMind),
            onPressed: onSave,
          ),
          if (reply.dayIndexes.firstOrNull case final int day)
            ActionChip(
              avatar: Icon(Icons.calendar_today_outlined, size: 18.0, color: colors.primary),
              label: Text('${context.l10n.aiActionOpenDay} · ${AiDayLabel.of(context, day)}'),
              onPressed: () => onOpenDay(day),
            ),
          ActionChip(
            avatar: Icon(Icons.view_week_outlined, size: 18.0, color: colors.primary),
            label: Text(context.l10n.aiActionWeekSummary),
            onPressed: () => onSend(context.l10n.aiWeekSummaryPrompt),
          ),
        ],
      ),
    );
  }
}

final class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.hasModel,
    required this.isWriting,
    required this.isBusy,
    required this.onSend,
    required this.onStop,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasModel;
  final bool isWriting;
  final bool isBusy;
  final VoidCallback onSend;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 4.0, 8.0, 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Focus(
              // Enter sends on a desktop; Shift+Enter makes a new line.
              onKeyEvent: (_, event) {
                final bool isEnter = event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter;
                if (!isEnter || HardwareKeyboard.instance.isShiftPressed) return KeyEventResult.ignored;
                if (isBusy || !hasModel) return KeyEventResult.handled;
                onSend();
                return KeyEventResult.handled;
              },
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: hasModel,
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: hasModel ? context.l10n.aiMessageHint : context.l10n.aiNoModelTitle,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24.0), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4.0),
          isWriting
              ? IconButton.filledTonal(
                  tooltip: context.l10n.aiStop,
                  onPressed: onStop,
                  icon: const Icon(Icons.stop_rounded),
                )
              : IconButton.filled(
                  onPressed: hasModel && !isBusy ? onSend : null,
                  color: Theme.of(context).colorScheme.onPrimary,
                  icon: const Icon(Icons.arrow_upward_rounded),
                ),
        ],
      ),
    ),
  );
}
