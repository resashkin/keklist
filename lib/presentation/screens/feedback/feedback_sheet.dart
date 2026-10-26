import 'package:keklist/domain/services/feedback/telegram_feedback.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';
import 'package:material_ui/material_ui.dart';

/// A text field and Send: the message goes to the developer's Telegram, see [TelegramFeedback].
final class FeedbackSheet extends StatefulWidget {
  const FeedbackSheet({super.key});

  static Future<void> show(BuildContext context) =>
      KekSheet.show<void>(context: context, builder: (_) => const FeedbackSheet());

  @override
  State<FeedbackSheet> createState() => _FeedbackSheetState();
}

final class _FeedbackSheetState extends State<FeedbackSheet> {
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
    return KekSheetScaffold(
      title: context.l10n.leaveFeedback,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12.0,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              enabled: !_isSending,
              minLines: 4,
              maxLines: 12,
              maxLength: 4000,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: context.l10n.feedbackHint,
                counterText: '',
              ),
            ),
            Text(context.l10n.feedbackPrivacy, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) => SizedBox(
                height: 50.0,
                child: FilledButton(
                  onPressed: _isSending || value.text.trim().isEmpty ? null : _send,
                  child: _isSending
                      ? const SizedBox.square(dimension: 20.0, child: CircularProgressIndicator(strokeWidth: 2.0))
                      : Text(context.l10n.feedbackSend),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
