import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/services/ai/ai_prompts.dart';

void main() {
  group('splitSuggestions', () {
    test('takes the last marker line as chips', () {
      final (String text, List<String> chips) = AiPrompts.splitSuggestions(
        'That sounds hard.\nWhat helped?\n>> Tell me more | "What helped?" | Plan tomorrow\n',
      );
      expect(text, 'That sounds hard.\nWhat helped?');
      expect(chips, ['Tell me more', 'What helped?', 'Plan tomorrow']);
    });

    test('keeps the reply whole without a marker', () {
      final (String text, List<String> chips) = AiPrompts.splitSuggestions('Just text. ');
      expect(text, 'Just text.');
      expect(chips, isEmpty);
    });

    test('keeps at most three short chips', () {
      final (_, List<String> chips) = AiPrompts.splitSuggestions('Hi\n>> a | b | c | d | ${'x' * 100}');
      expect(chips, ['a', 'b', 'c']);
    });
  });

  test('visiblePart hides a suggestion line being written', () {
    expect(AiPrompts.visiblePart('Hello there\n>> Tell'), 'Hello there');
    expect(AiPrompts.visiblePart('>> Tell'), '');
    expect(AiPrompts.visiblePart('Hello'), 'Hello');
  });

  test('system prompt names the reply language and the context', () {
    final String prompt = AiPrompts.system(
      persona: AiPrompts.builtIn(therapist: 'T', coach: 'C', friend: 'F').first,
      language: 'Russian',
      context: 'CONTEXT',
    );
    expect(prompt, contains('Reply in Russian.'));
    expect(prompt, endsWith('CONTEXT'));
  });
}
