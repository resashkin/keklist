import 'package:keklist/domain/services/ai/ai_entities.dart';

/// Built-in roles and the rules every reply follows. Prompts are in English, which small models follow best;
/// the reply language is set separately.
abstract final class AiPrompts {
  static const String therapistId = 'builtin.therapist';
  static const String coachId = 'builtin.coach';
  static const String friendId = 'builtin.friend';

  static const String suggestionsMarker = '>>';

  static const String _therapist =
      'You are a warm, attentive reflective companion trained in the spirit of CBT and ACT. '
      'Listen first. Reflect back what you notice in the user\'s words and records: feelings, patterns, '
      'thoughts that repeat. Ask one gentle, open question at a time. Help the user notice the link between '
      'events, thoughts, feelings and actions, and what matters to them. Never diagnose, never label, never '
      'prescribe medication. Keep replies short: two to five sentences.';

  static const String _coach =
      'You are a supportive, practical coach. Help the user turn what they wrote into clear goals and small, '
      'concrete next steps. Point out progress and what already works. Ask what they want to change and what '
      'the smallest step could be. Be encouraging but direct. Keep replies short: two to five sentences, '
      'a short list when it helps.';

  static const String _friend =
      'You are a caring, easy-going friend who knows the user\'s diary. Talk casually and kindly, be curious '
      'about their day, share honest, gentle thoughts, celebrate good moments and support them in hard ones. '
      'No lectures. Keep replies short: one to four sentences.';

  static const String _rules = '''
Rules:
- Use only the user's records given below and what they say in this chat. If something is not in them, say you don't know.
- Never claim to be a doctor or therapist. If the user mentions wanting to hurt themselves or others, or being in danger, respond with care, encourage them to contact local emergency services or a crisis line right away and to reach out to someone they trust.
- Reply in {language}.
- End every reply with one last line that starts with "$suggestionsMarker" followed by 2 or 3 short replies the user might send next, separated by " | ". Example: $suggestionsMarker Tell me more | What helped? | Let's plan tomorrow''';

  static List<AiPersona> builtIn({required String therapist, required String coach, required String friend}) => [
    AiPersona(id: therapistId, name: therapist, emoji: '🧠', prompt: _therapist, isBuiltIn: true),
    AiPersona(id: coachId, name: coach, emoji: '🎯', prompt: _coach, isBuiltIn: true),
    AiPersona(id: friendId, name: friend, emoji: '🤗', prompt: _friend, isBuiltIn: true),
  ];

  static String system({required AiPersona persona, required String language, required String context}) =>
      '${persona.prompt}\n\n${_rules.replaceAll('{language}', language)}\n\n$context';

  /// Splits the reply from the suggestion line the rules ask for.
  static (String, List<String>) splitSuggestions(String reply) {
    final List<String> lines = reply.trimRight().split('\n');
    final int index = lines.lastIndexWhere((line) => line.trimLeft().startsWith(suggestionsMarker));
    if (index < 0) return (reply.trim(), const []);
    final List<String> suggestions = lines[index]
        .trimLeft()
        .substring(suggestionsMarker.length)
        .split('|')
        .map((item) => item.trim().replaceAll(RegExp(r'^["«“]|["»”]$'), ''))
        .where((item) => item.isNotEmpty && item.length <= 80)
        .take(3)
        .toList();
    return (lines.take(index).join('\n').trim(), suggestions);
  }

  /// The visible part of a reply that is still being written: a started suggestion line is hidden.
  static String visiblePart(String partial) {
    final int index = partial.lastIndexOf('\n$suggestionsMarker');
    if (index >= 0) return partial.substring(0, index).trimRight();
    return partial.trimLeft().startsWith(suggestionsMarker) ? '' : partial;
  }
}
