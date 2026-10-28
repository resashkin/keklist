import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/services/ai/ai_backend.dart';
import 'package:keklist/domain/services/ai/ai_entities.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart';
import 'package:keklist/presentation/core/widgets/glass_app_bar.dart';
import 'package:keklist/presentation/screens/ai/ai_models_screen.dart';
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

  void _followReveal() {
    if (!_scroll.hasClients || _scroll.position.extentAfter > 80.0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
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
                    for (final (int index, AiMessage message) in session.messages.indexed)
                      message.role == AiRole.user
                          ? _Bubble(key: ValueKey<int>(index), message: message)
                          : _ReplyBubble(key: ValueKey<int>(index), text: message.text, onGrow: _followReveal),
                    if (streaming != null)
                      _ReplyBubble(
                        key: ValueKey<int>(session.messages.length),
                        text: streaming.text,
                        isWriting: true,
                        onGrow: _followReveal,
                      ),
                    if (backend.lastError != null && streaming == null && lastReply == null)
                      _ErrorNote(error: backend.lastError!, canManage: backend.canManage),
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
  const _Bubble({super.key, required this.message});

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

/// A failed reply; a model that doesn't fit in memory gets a way to pick another one.
final class _ErrorNote extends StatelessWidget {
  const _ErrorNote({required this.error, required this.canManage});

  final String error;
  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.error;
    if (error != AiBackend.modelDoesNotFit) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(error, style: TextStyle(color: color)),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.0,
        children: [
          Text(context.l10n.aiModelDoesNotFit, style: TextStyle(color: color)),
          if (canManage)
            OutlinedButton.icon(
              onPressed: () => AiModelsScreen.open(context),
              icon: const Icon(Icons.memory_rounded, size: 18.0),
              label: Text(context.l10n.aiChooseAnotherModel),
            ),
        ],
      ),
    );
  }
}

/// An answer shown word by word as it is written; the same bubble keeps revealing after it was saved.
final class _ReplyBubble extends StatefulWidget {
  const _ReplyBubble({super.key, required this.text, required this.onGrow, this.isWriting = false});

  final String text;
  final bool isWriting;
  final VoidCallback onGrow;

  @override
  State<_ReplyBubble> createState() => _ReplyBubbleState();
}

final class _ReplyBubbleState extends State<_ReplyBubble> {
  static const Duration _wordPace = Duration(milliseconds: 30);
  static const int _comfortableBacklog = 8;

  late int _shown = widget.isWriting ? 0 : widget.text.length;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _revealIfBehind();
  }

  @override
  void didUpdateWidget(_ReplyBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    _shown = _shown.clamp(0, widget.text.length);
    _revealIfBehind();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _revealIfBehind() {
    if (_shown >= widget.text.length || _timer != null) return;
    _timer = Timer.periodic(_wordPace, (_) => _revealNext());
  }

  void _revealNext() {
    final String text = widget.text;
    final int backlog = _wordsIn(text.substring(_shown));
    final int step = backlog <= _comfortableBacklog ? 1 : (backlog / _comfortableBacklog).ceil();
    int next = _shown;
    for (int word = 0; word < step && next < text.length; word++) {
      next = _endOfWord(text, next);
    }
    setState(() => _shown = next);
    widget.onGrow();
    if (_shown >= text.length) {
      _timer?.cancel();
      _timer = null;
    }
  }

  static int _wordsIn(String text) => RegExp(r'\S+').allMatches(text).length;

  static int _endOfWord(String text, int from) {
    int index = from;
    while (index < text.length && text[index].trim().isEmpty) {
      index++;
    }
    while (index < text.length && text[index].trim().isNotEmpty) {
      index++;
    }
    return index;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isDone = !widget.isWriting && _shown >= widget.text.length;
    const TextStyle style = TextStyle(height: 1.35);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        decoration: BoxDecoration(color: colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(18.0)),
        child: switch ((_shown, isDone)) {
          (0, _) when widget.isWriting => _TypingDots(color: Theme.of(context).hintColor),
          (_, true) => SelectableText(widget.text, style: style.copyWith(color: colors.onSurface)),
          _ => Text(widget.text.substring(0, _shown), style: style.copyWith(color: colors.onSurface)),
        },
      ),
    );
  }
}

/// Three dots bouncing in turn while the model hasn't written anything yet.
final class _TypingDots extends StatefulWidget {
  const _TypingDots({required this.color});

  final Color color;

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

final class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 20.0,
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5.0,
        children: [
          for (int dot = 0; dot < 3; dot++)
            Transform.translate(
              offset: Offset(0.0, -5.0 * _bounce((_controller.value - dot * 0.15) % 1.0)),
              child: Container(
                width: 7.0,
                height: 7.0,
                decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    ),
  );

  static double _bounce(double phase) => phase < 0.4 ? math.sin(phase / 0.4 * math.pi) : 0.0;
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
