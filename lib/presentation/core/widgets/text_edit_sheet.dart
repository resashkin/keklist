import 'package:flutter/services.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';
import 'package:material_ui/material_ui.dart';

/// Edits an existing text in a sheet; resolves to the new text, or null when closed without saving.
final class TextEditSheet extends StatefulWidget {
  final String initialText;

  const TextEditSheet({super.key, required this.initialText});

  static Future<String?> show(BuildContext context, {required String initialText}) =>
      KekSheet.show<String>(context: context, builder: (_) => TextEditSheet(initialText: initialText));

  @override
  State<TextEditSheet> createState() => _TextEditSheetState();
}

final class _TextEditSheetState extends State<TextEditSheet> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialText)
    ..selection = TextSelection.collapsed(offset: widget.initialText.length);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return KekSheetScaffold(
      title: context.l10n.edit,
      child: Focus(
        // Cmd/Ctrl+Enter saves on a desktop; the field itself keeps plain Enter for new lines.
        onKeyEvent: (_, event) {
          final HardwareKeyboard keyboard = HardwareKeyboard.instance;
          if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.enter) return KeyEventResult.ignored;
          if (!keyboard.isMetaPressed && !keyboard.isControlPressed) return KeyEventResult.ignored;
          _save();
          return KeyEventResult.handled;
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16.0,
            children: [
              TextField(
                controller: _controller,
                autofocus: true,
                minLines: 3,
                maxLines: 12,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              FilledButton(onPressed: _save, child: Text(context.l10n.save)),
            ],
          ),
        ),
      ),
    );
  }
}
