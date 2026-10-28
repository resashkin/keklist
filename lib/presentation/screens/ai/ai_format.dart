import 'package:keklist/domain/services/ai/ai_backend.dart';
import 'package:keklist/domain/services/ai/ai_prompts.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:material_ui/material_ui.dart';

abstract final class AiFormat {
  static String size(int bytes) {
    if (bytes >= 1 << 30) return '${(bytes / (1 << 30)).toStringAsFixed(1)} GB';
    if (bytes >= 1 << 20) return '${(bytes / (1 << 20)).round()} MB';
    return '${(bytes / 1024).round()} KB';
  }

  static String count(int value) => value >= 1000000
      ? '${(value / 1000000).toStringAsFixed(1)}M'
      : value >= 1000
      ? '${(value / 1000).toStringAsFixed(1)}K'
      : '$value';

  /// The reply language, named in English for the prompt.
  static String languageOf(Locale locale) => switch (locale.languageCode) {
    'ru' => 'Russian',
    'es' => 'Spanish',
    'it' => 'Italian',
    'de' => 'German',
    'ja' => 'Japanese',
    'kk' => 'Kazakh',
    'ky' => 'Kyrgyz',
    'uz' => 'Uzbek',
    'zh' => 'Chinese',
    'sr' => locale.scriptCode == 'Latn' ? 'Serbian (Latin script)' : 'Serbian (Cyrillic script)',
    _ => 'English',
  };

  /// Tells the backend the app's language and the localized names of the built-in roles.
  static void configure(BuildContext context, AiBackend backend) => backend.configure(
    language: languageOf(Localizations.localeOf(context)),
    builtInNames: {
      AiPrompts.therapistId: context.l10n.aiRoleTherapist,
      AiPrompts.coachId: context.l10n.aiRoleCoach,
      AiPrompts.friendId: context.l10n.aiRoleFriend,
    },
  );
}

/// A model's name with small labels after it; weak models get a warning one.
final class AiNameWithBadges extends StatelessWidget {
  const AiNameWithBadges({super.key, required this.name, this.isWeak = false, this.badges = const [], this.maxLines = 1});

  final String name;
  final bool isWeak;
  final List<String> badges;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    Widget badge(String text, Color background, Color foreground) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(8.0)),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground)),
    );
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(name, maxLines: maxLines, overflow: TextOverflow.ellipsis),
        for (final String text in badges) badge(text, colors.primaryContainer, colors.onPrimaryContainer),
        if (isWeak) badge(context.l10n.aiLowQuality, colors.errorContainer, colors.onErrorContainer),
      ],
    );
  }
}
