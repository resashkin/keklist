import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';

final class AiContext {
  const AiContext({required this.text, required this.dayIndexes});

  final String text;

  /// Days quoted in full, newest first.
  final List<int> dayIndexes;
}

/// Picks the records a reply should see within a character budget: the latest days in full, the days that match
/// the message by words, dates or emotions.
/// See `documentation/AI_IMPLEMENTATION.md`.
final class AiContextBuilder {
  const AiContextBuilder({
    required this.minds,
    required this.emotions,
    required this.todayIndex,
    this.budgetChars = 6000,
    this.recentDays = 3,
  });

  final Iterable<Mind> minds;
  final Map<String, Emotion> emotions;
  final int todayIndex;
  final int budgetChars;
  final int recentDays;

  static const int _maxMatchedDays = 6;

  Map<int, List<Mind>> get _byDay {
    final Map<int, List<Mind>> days = {};
    for (final Mind mind in minds) {
      if (mind.plainNote.trim().isEmpty && mind.emotionIds.isEmpty) continue;
      days.putIfAbsent(mind.dayIndex, () => []).add(mind);
    }
    for (final List<Mind> day in days.values) {
      day.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    }
    return days;
  }

  AiContext build(String message) {
    final Map<int, List<Mind>> days = _byDay;
    final List<int> newestFirst = days.keys.where((day) => day <= todayIndex).toList()..sort((a, b) => b.compareTo(a));
    final List<int> picked = [
      ...newestFirst.take(recentDays),
      for (final int day in _matchedDays(message, days, newestFirst))
        if (!newestFirst.take(recentDays).contains(day)) day,
    ];

    final StringBuffer full = StringBuffer();
    final List<int> quoted = [];
    for (final int day in picked) {
      final String block = dayBlock(day, days[day]!);
      if (full.length + block.length > budgetChars && quoted.isNotEmpty) continue;
      full.write(block);
      quoted.add(day);
    }

    final StringBuffer text = StringBuffer()
      ..writeln('Today is ${dateLabel(todayIndex)}.')
      ..writeln(
        quoted.isEmpty ? 'The user has no diary records yet.' : "The user's diary records (time, emotions, text):",
      )
      ..write(full);
    quoted.sort((a, b) => b.compareTo(a));
    return AiContext(text: text.toString().trimRight(), dayIndexes: quoted);
  }

  /// One day as plain lines; reflections follow the record they belong to.
  String dayBlock(int day, List<Mind> dayMinds) {
    final StringBuffer block = StringBuffer('## ${dateLabel(day)}\n');
    final Iterable<Mind> roots = dayMinds.where((mind) => mind.rootId == null);
    for (final Mind mind in roots) {
      block.writeln('- ${_line(mind)}');
      for (final Mind reflection in dayMinds.where((item) => item.rootId == mind.id)) {
        block.writeln('  - reflection: ${_line(reflection)}');
      }
    }
    for (final Mind orphan in dayMinds.where(
      (mind) => mind.rootId != null && !roots.any((root) => root.id == mind.rootId),
    )) {
      block.writeln('- ${_line(orphan)}');
    }
    return block.toString();
  }

  String _line(Mind mind) {
    final String time = '${_two(mind.creationDate.hour)}:${_two(mind.creationDate.minute)}';
    final List<String> feelings = [
      if (mind.legacyEmoji case final String emoji when emoji.isNotEmpty) emoji,
      for (final String id in mind.emotionIds)
        if (emotions[id] case final Emotion emotion) '${emotion.emoji} ${emotion.title}',
    ];
    final String note = mind.plainNote.trim().replaceAll(RegExp(r'\s*\n\s*'), ' ');
    return [time, if (feelings.isNotEmpty) '[${feelings.join(', ')}]', note].where((part) => part.isNotEmpty).join(' ');
  }

  Iterable<int> _matchedDays(String message, Map<int, List<Mind>> days, List<int> newestFirst) {
    final Set<int> dated = _mentionedDays(message.toLowerCase()).where(days.containsKey).toSet();
    final List<String> stems = _stems(message);
    final Set<String> emotionIds = {
      for (final Emotion emotion in emotions.values)
        if (message.contains(emotion.emoji) ||
            (emotion.title.length >= 3 && message.toLowerCase().contains(emotion.title.toLowerCase())))
          emotion.id,
    };
    final List<(int, int)> scored = [];
    for (final int day in newestFirst) {
      int score = dated.contains(day) ? 100 : 0;
      for (final Mind mind in days[day]!) {
        final String note = mind.plainNote.toLowerCase();
        score += stems.where(note.contains).length * 3;
        score += mind.emotionIds.where(emotionIds.contains).length * 2;
        if (mind.legacyEmoji case final String emoji when emoji.isNotEmpty && message.contains(emoji)) score += 2;
      }
      if (score > 0) scored.add((day, score));
    }
    scored.sort((a, b) => b.$2 != a.$2 ? b.$2.compareTo(a.$2) : b.$1.compareTo(a.$1));
    return scored.take(_maxMatchedDays).map((item) => item.$1);
  }

  /// Word beginnings long enough to survive Russian and English endings.
  static List<String> _stems(String message) => {
    for (final String word in message.toLowerCase().split(RegExp(r'[^\p{L}\p{N}]+', unicode: true)))
      if (word.length >= 4 && !_stopWords.contains(word)) word.length > 6 ? word.substring(0, word.length - 2) : word,
  }.toList();

  Iterable<int> _mentionedDays(String message) sync* {
    if (RegExp(r'\b(today|сегодня)').hasMatch(message)) yield todayIndex;
    if (RegExp(r'(yesterday|вчера)').hasMatch(message)) yield todayIndex - 1;
    if (message.contains('позавчера') || message.contains('day before yesterday')) yield todayIndex - 2;
    for (final RegExpMatch match in RegExp(r'\b(\d{1,2})[./](\d{1,2})(?:[./](\d{2,4}))?\b').allMatches(message)) {
      final DateTime today = _calendarDate(todayIndex);
      final int day = int.parse(match[1]!), month = int.parse(match[2]!);
      final int year = switch (match[3]) {
        final String value => value.length == 2 ? 2000 + int.parse(value) : int.parse(value),
        null => today.year,
      };
      if (month < 1 || month > 12 || day < 1 || day > 31) continue;
      yield DateTime.utc(year, month, day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
    }
    for (final RegExpMatch match in RegExp(r'(\d+)\s*(days ago|дн\w* назад)').allMatches(message)) {
      yield todayIndex - int.parse(match[1]!);
    }
  }

  static DateTime _calendarDate(int dayIndex) =>
      DateTime.fromMillisecondsSinceEpoch(dayIndex * Duration.millisecondsPerDay, isUtc: true);

  static String dateLabel(int dayIndex) {
    final DateTime date = _calendarDate(dayIndex);
    return '${date.year}-${_two(date.month)}-${_two(date.day)} (${_weekdays[date.weekday - 1]})';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  static const List<String> _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static const Set<String> _stopWords = {
    'that',
    'this',
    'with',
    'what',
    'when',
    'have',
    'about',
    'there',
    'were',
    'your',
    'from',
    'they',
    'would',
    'это',
    'что',
    'как',
    'когда',
    'было',
    'была',
    'были',
    'меня',
    'мной',
    'тебя',
    'себя',
    'чтобы',
    'если',
    'тоже',
    'очень',
    'только',
    'есть',
    'того',
    'этот',
    'эта',
    'этом',
    'почему',
    'какие',
    'какой',
    'сейчас',
  };
}
