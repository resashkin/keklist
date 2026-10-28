import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_switcher.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late List<String> steps;

  Future<void> pumpArea(WidgetTester tester) async {
    steps = [];
    await tester.pumpWidget(
      MaterialApp(
        home: _Host(onPrevious: () => steps.add('previous'), onNext: () => steps.add('next')),
      ),
    );
  }

  testWidgets('swiping left opens the next day', (tester) async {
    await pumpArea(tester);
    await tester.fling(find.byType(DaySwipeArea), const Offset(-200, 0), 800);
    expect(steps, ['next']);
  });

  testWidgets('swiping right opens the previous day', (tester) async {
    await pumpArea(tester);
    await tester.fling(find.byType(DaySwipeArea), const Offset(200, 0), 800);
    expect(steps, ['previous']);
  });

  testWidgets('a short slow drag keeps the day', (tester) async {
    await pumpArea(tester);
    await tester.timedDrag(find.byType(DaySwipeArea), const Offset(-30, 0), const Duration(seconds: 1));
    expect(steps, isEmpty);
  });

  testWidgets('a two-finger drag keeps the day', (tester) async {
    await pumpArea(tester);
    final TestGesture first = await tester.startGesture(const Offset(400, 300), pointer: 1);
    final TestGesture second = await tester.startGesture(const Offset(400, 400), pointer: 2);
    for (int i = 0; i < 10; i++) {
      await first.moveBy(const Offset(-30, 0));
      await second.moveBy(const Offset(-30, 0));
    }
    await first.up();
    await second.up();
    expect(steps, isEmpty);
  });
}

final class _Host extends StatefulWidget {
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _Host({required this.onPrevious, required this.onNext});

  @override
  State<_Host> createState() => _HostState();
}

final class _HostState extends State<_Host> with SingleTickerProviderStateMixin {
  late final DaySlideController _controller = DaySlideController(vsync: this);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DaySwipeArea(
    controller: _controller,
    onPrevious: widget.onPrevious,
    onNext: widget.onNext,
    child: const ColoredBox(color: Colors.white, child: SizedBox.expand()),
  );
}
