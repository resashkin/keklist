import 'package:emojis/emoji.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/mind_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';

final class EmojiPickerScreen extends StatefulWidget {
  final ValueChanged<String> onSelect;

  const EmojiPickerScreen({super.key, required this.onSelect});

  static Future<void> show(BuildContext context, {required ValueChanged<String> onSelect}) => KekSheet.show(
    context: context,
    builder: (_) => EmojiPickerScreen(onSelect: onSelect),
  );

  @override
  State<EmojiPickerScreen> createState() => _EmojiPickerScreenState();
}

final class _EmojiPickerScreenState extends State<EmojiPickerScreen> {
  static final List<Emoji> _allEmojis = Emoji.all();

  final TextEditingController _textEditingController = TextEditingController();
  List<String> _visibleEmojis = _allEmojis.map((emoji) => emoji.char).toList();

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(() {
      final String query = _textEditingController.text.trim();
      setState(() {
        _visibleEmojis = _allEmojis
            .where((emoji) => query.isEmpty || emoji.keywords.join().contains(query))
            .map((emoji) => emoji.char)
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KekSheetScaffold(
      title: context.l10n.profileEmoji,
      heightFactor: 0.8,
      child: Column(
        children: [
          TextField(
            autofocus: true,
            controller: _textEditingController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(8),
              border: const UnderlineInputBorder(),
              hintText: context.l10n.searchYourEmoji,
            ),
          ),
          Flexible(
            child: LayoutBuilder(
              builder: (context, constraints) => GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (constraints.maxWidth / 80).ceil(),
                ),
                itemCount: _visibleEmojis.length,
                itemBuilder: (context, index) {
                  final String emoji = _visibleEmojis[index];
                  return MindWidget(item: emoji, onTap: () => _pickEmoji(emoji), isHighlighted: true);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickEmoji(String emoji) {
    Navigator.of(context).pop();
    widget.onSelect(emoji);
  }
}
