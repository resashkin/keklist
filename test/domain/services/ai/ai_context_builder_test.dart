import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/services/ai/ai_context_builder.dart';
import 'package:keklist/domain/services/ai/ai_entities.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';

void main() {
  const int today = 20000;

  Mind mind(String id, int day, String note, {List<String> emotions = const [], String? rootId}) => Mind(
    id: id,
    note: note,
    dayIndex: day,
    creationDate: DateTime(2024, 10, 1, 9, 30),
    sortIndex: 0,
    rootId: rootId,
    emotionIds: emotions,
  );

  final Emotion calm = Emotion(
    id: 'calm',
    title: 'Calm',
    emoji: '😌',
    parentId: null,
    isArchived: false,
    orderIndex: 0,
    creationDate: DateTime(2024),
  );

  AiContextBuilder builder(List<Mind> minds, {Map<int, AiDaySummary> summaries = const {}, int budget = 6000}) =>
      AiContextBuilder(
        minds: minds,
        emotions: {calm.id: calm},
        summaries: summaries,
        todayIndex: today,
        budgetChars: budget,
      );

  test('quotes the latest days in full, newest first', () {
    final AiContext context = builder([
      mind('a', today, 'Coffee with Anna'),
      mind('b', today - 1, 'Long walk'),
      mind('c', today - 2, 'Read a book'),
      mind('d', today - 10, 'Old day'),
    ]).build('hello');
    expect(context.dayIndexes, [today, today - 1, today - 2]);
    expect(context.text, contains('Coffee with Anna'));
    expect(context.text, isNot(contains('Old day')));
  });

  test('adds older days that match words of the message', () {
    final AiContext context = builder([
      mind('a', today, 'Nothing special'),
      mind('b', today - 1, 'Nothing'),
      mind('c', today - 2, 'Nothing'),
      mind('d', today - 30, 'Argued with my manager about the project'),
    ]).build('Why do I keep arguing with my manager?');
    expect(context.dayIndexes, contains(today - 30));
    expect(context.text, contains('manager about the project'));
  });

  test('adds days by emotion and by "yesterday"', () {
    final AiContext context = AiContextBuilder(
      minds: [
        mind('a', today, 'x'),
        mind('b', today - 1, 'y'),
        mind('c', today - 2, 'z'),
        mind('d', today - 40, 'Lake', emotions: ['calm']),
      ],
      emotions: {calm.id: calm},
      summaries: const {},
      todayIndex: today,
      recentDays: 1,
    ).build('When was I 😌? And yesterday?');
    expect(context.dayIndexes, containsAll([today, today - 1, today - 40]));
    expect(context.text, contains('😌 Calm'));
  });

  test('puts reflections under their record', () {
    final String block = builder(const []).dayBlock(today, [
      mind('root', today, 'Main thought'),
      mind('child', today, 'Second look', rootId: 'root'),
    ]);
    expect(block, contains('- 09:30 Main thought\n  - reflection: 09:30 Second look'));
  });

  test('uses summaries for older days and respects the budget', () {
    final AiContext context = builder(
      [
        mind('a', today, 'Today ' * 20),
        mind('b', today - 5, 'Five days ago ' * 10),
      ],
      summaries: {
        today - 5: AiDaySummary(dayIndex: today - 5, text: 'A quiet day.', sourceHash: '', createdAt: DateTime(2024)),
      },
      budget: 200,
    ).build('hi');
    expect(context.dayIndexes, [today]);
    expect(context.text, contains('A quiet day.'));
  });

  test('says when there are no records', () {
    expect(builder(const []).build('hi').text, contains('no diary records'));
  });
}
