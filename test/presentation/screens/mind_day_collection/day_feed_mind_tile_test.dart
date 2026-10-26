import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_tiles.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, MindReflections reflections, {double size = 120.0}) => tester.pumpWidget(
  MaterialApp(
    home: Center(
      child: SizedBox.square(
        dimension: size,
        child: DayFeedMindTile(
          item: DayFeedMind(
            mind: Mind(
              id: 'mind',
              note: 'A note',
              legacyEmoji: '🙂',
              dayIndex: 10,
              creationDate: DateTime(2026, 1, 1, 12),
              sortIndex: 0,
              rootId: null,
            ),
            reflections: reflections,
          ),
          isTextVisible: true,
          size: size,
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('shows an icon with a count for each kind of reflection', (tester) async {
    await _pump(tester, const MindReflections(comments: 1, audios: 2));

    expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
    expect(find.byIcon(Icons.videocam_outlined), findsNothing);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('shows no badge without reflections or on tiny tiles', (tester) async {
    await _pump(tester, const MindReflections());
    expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsNothing);

    await _pump(tester, const MindReflections(comments: 3), size: 40.0);
    expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsNothing);
  });
}
