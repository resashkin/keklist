import 'package:keklist/domain/services/feedback/telegram_feedback.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:material_ui/material_ui.dart';

/// A full-screen text field like the mind creator; Send delivers it to the developer's Telegram, see
/// [TelegramFeedback].
final class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  static Future<void> show(BuildContext context) => Navigator.of(
    context,
  ).push<void>(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => const FeedbackScreen()));

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

final class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final String text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSending = true);
    final bool isSent = await TelegramFeedback.send(text);
    if (!mounted) return;
    setState(() => _isSending = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(isSent ? context.l10n.feedbackSent : context.l10n.feedbackFailed)));
    if (isSent) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(context.l10n.leaveFeedback),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        actions: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) => _isSending
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: SizedBox.square(dimension: 20.0, child: CircularProgressIndicator(strokeWidth: 2.0)),
                  )
                : TextButton(
                    onPressed: value.text.trim().isEmpty ? null : _send,
                    child: Text(context.l10n.feedbackSend, style: const TextStyle(fontSize: 16.0)),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: TextField(
                controller: _controller,
                autofocus: true,
                enabled: !_isSending,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                maxLength: 4000,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 20.0),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(12.0),
                  border: InputBorder.none,
                  counterText: '',
                  hintText: context.l10n.feedbackHint,
                ),
              ),
            ),
          ),
          // Sits right above the keyboard.
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 12.0),
            child: Text(
              context.l10n.feedbackPrivacy,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
          ),
        ],
      ),
    );
  }
}
