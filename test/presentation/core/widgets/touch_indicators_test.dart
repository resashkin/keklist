import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/presentation/core/widgets/touch_indicators.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Finder dots() => find.byWidgetPredicate(
    (widget) =>
        widget is Container &&
        widget.decoration is BoxDecoration &&
        (widget.decoration! as BoxDecoration).shape == BoxShape.circle,
  );

  Future<void> pumpIndicators(WidgetTester tester, {required bool isEnabled}) => tester.pumpWidget(
    TouchIndicators(
      isEnabled: isEnabled,
      child: const ColoredBox(color: Color(0xFF000000)),
    ),
  );

  testWidgets('shows a dot per finger and fades it out on release', (tester) async {
    await pumpIndicators(tester, isEnabled: true);
    final TestGesture first = await tester.startGesture(const Offset(100, 100), pointer: 1);
    final TestGesture second = await tester.startGesture(const Offset(200, 200), pointer: 2);
    await tester.pump();
    expect(dots(), findsNWidgets(2));

    await first.up();
    await tester.pump();
    await tester.pump(TouchIndicators.fadeDuration * 2);
    expect(dots(), findsOneWidget);

    await second.up();
    await tester.pumpAndSettle();
    expect(dots(), findsNothing);
  });

  testWidgets('touches still reach the child', (tester) async {
    int taps = 0;
    await tester.pumpWidget(
      TouchIndicators(
        isEnabled: true,
        child: GestureDetector(
          onTap: () => taps++,
          child: const ColoredBox(color: Color(0xFF000000)),
        ),
      ),
    );
    await tester.tapAt(const Offset(50, 50));
    expect(taps, 1);
  });

  testWidgets('draws nothing while disabled', (tester) async {
    await pumpIndicators(tester, isEnabled: false);
    await tester.startGesture(const Offset(100, 100));
    await tester.pump();
    expect(dots(), findsNothing);
  });

  testWidgets('switching keeps the state below', (tester) async {
    final GlobalKey<State<StatefulWidget>> key = GlobalKey();
    Widget build(bool isEnabled) => TouchIndicators(
      isEnabled: isEnabled,
      child: StatefulBuilder(key: key, builder: (_, _) => const SizedBox()),
    );
    await tester.pumpWidget(build(false));
    final State<StatefulWidget> state = key.currentState!;
    await tester.pumpWidget(build(true));
    expect(key.currentState, same(state));
  });
}
