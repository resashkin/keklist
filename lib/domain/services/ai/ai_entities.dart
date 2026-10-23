import 'package:equatable/equatable.dart';

/// Who the model plays in a session: one of the built-in roles or one the user wrote.
final class AiPersona with EquatableMixin {
  const AiPersona({
    required this.id,
    required this.name,
    required this.emoji,
    required this.prompt,
    this.isBuiltIn = false,
  });

  final String id;
  final String name;
  final String emoji;
  final String prompt;
  final bool isBuiltIn;

  AiPersona copyWith({String? id, String? name, String? emoji, String? prompt, bool? isBuiltIn}) => AiPersona(
    id: id ?? this.id,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    prompt: prompt ?? this.prompt,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'emoji': emoji, 'prompt': prompt, 'isBuiltIn': isBuiltIn};

  factory AiPersona.fromJson(Map<String, dynamic> json) => AiPersona(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    emoji: json['emoji'] as String? ?? '💬',
    prompt: json['prompt'] as String? ?? '',
    isBuiltIn: json['isBuiltIn'] as bool? ?? false,
  );

  @override
  List<Object?> get props => [id, name, emoji, prompt, isBuiltIn];
}

enum AiRole { user, assistant }

final class AiMessage with EquatableMixin {
  const AiMessage({
    required this.role,
    required this.text,
    required this.createdAt,
    this.suggestions = const [],
    this.dayIndexes = const [],
  });

  final AiRole role;
  final String text;
  final DateTime createdAt;

  /// Replies the model offers the user as chips.
  final List<String> suggestions;

  /// Days whose records the reply was based on, newest first.
  final List<int> dayIndexes;

  Map<String, dynamic> toJson() => {
    'role': role.name,
    'text': text,
    'createdAt': createdAt.millisecondsSinceEpoch,
    if (suggestions.isNotEmpty) 'suggestions': suggestions,
    if (dayIndexes.isNotEmpty) 'dayIndexes': dayIndexes,
  };

  factory AiMessage.fromJson(Map<String, dynamic> json) => AiMessage(
    role: AiRole.values.asNameMap()[json['role']] ?? AiRole.user,
    text: json['text'] as String? ?? '',
    createdAt: DateTime.fromMillisecondsSinceEpoch((json['createdAt'] as num?)?.toInt() ?? 0),
    suggestions: (json['suggestions'] as List<dynamic>? ?? const []).cast<String>(),
    dayIndexes: (json['dayIndexes'] as List<dynamic>? ?? const []).cast<int>(),
  );

  @override
  List<Object?> get props => [role, text, createdAt, suggestions, dayIndexes];
}

final class AiSession with EquatableMixin {
  const AiSession({
    required this.id,
    required this.personaId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
  });

  final String id;
  final String personaId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AiMessage> messages;

  AiSession copyWith({String? title, DateTime? updatedAt, List<AiMessage>? messages}) => AiSession(
    id: id,
    personaId: personaId,
    title: title ?? this.title,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    messages: messages ?? this.messages,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'personaId': personaId,
    'title': title,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
    'messages': [for (final AiMessage message in messages) message.toJson()],
  };

  factory AiSession.fromJson(Map<String, dynamic> json) => AiSession(
    id: json['id'] as String,
    personaId: json['personaId'] as String? ?? '',
    title: json['title'] as String? ?? '',
    createdAt: DateTime.fromMillisecondsSinceEpoch((json['createdAt'] as num?)?.toInt() ?? 0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch((json['updatedAt'] as num?)?.toInt() ?? 0),
    messages: [
      for (final Object? message in json['messages'] as List<dynamic>? ?? const [])
        AiMessage.fromJson(message as Map<String, dynamic>),
    ],
  );

  @override
  List<Object?> get props => [id, personaId, title, createdAt, updatedAt, messages];
}
