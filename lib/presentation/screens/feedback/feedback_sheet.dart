import 'package:keklist/domain/services/feedback/telegram_feedback.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/glass_capsule_button.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';
import 'package:material_ui/material_ui.dart';

/// A sheet with a text field that grows with the text; Send delivers it to the developer's Telegram, see
/// [TelegramFeedback].
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
    return KekSheetScaffold(
      title: context.l10n.leaveFeedback,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: TextField(
                controller: _controller,
                autofocus: true,
                enabled: !_isSending,
                keyboardType: TextInputType.multiline,
                minLines: 5,
                maxLines: null,
                maxLength: 4000,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 20.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 12.0),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) => GlassCapsuleButton(
                  height: 48.0,
                  onTap: _isSending || value.text.trim().isEmpty ? null : _send,
                  child: _isSending
                      ? const SizedBox.square(dimension: 20.0, child: CircularProgressIndicator(strokeWidth: 2.0))
                      : Text(context.l10n.feedbackSend, style: const TextStyle(fontSize: 16.0)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
