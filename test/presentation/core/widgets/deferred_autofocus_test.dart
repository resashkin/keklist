import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/presentation/core/widgets/deferred_autofocus.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('focuses the field only after the sheet finished opening', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              builder: (_) => DeferredAutofocus(builder: (_, focusNode) => TextField(focusNode: focusNode)),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    EditableTextState field() => tester.state<EditableTextState>(find.byType(EditableText));
    expect(field().widget.focusNode.hasFocus, isFalse);

    await tester.pumpAndSettle();
    expect(field().widget.focusNode.hasFocus, isTrue);
  });

  testWidgets('focuses right away when the route is already open', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: DeferredAutofocus(builder: (_, focusNode) => TextField(focusNode: focusNode))),
      ),
    );
    await tester.pump();
    expect(tester.state<EditableTextState>(find.byType(EditableText)).widget.focusNode.hasFocus, isTrue);
  });
}
