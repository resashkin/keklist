import 'package:keklist/domain/services/ai/ai_entities.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';
import 'package:material_ui/material_ui.dart';

/// A new session starts by choosing who the model plays; the role stays for the whole session.
final class AiPersonaPickerSheet extends StatelessWidget {
  const AiPersonaPickerSheet({super.key, required this.personas});

  final List<AiPersona> personas;

  static Future<AiPersona?> show(BuildContext context, {required List<AiPersona> personas}) => KekSheet.show<AiPersona>(
    context: context,
    builder: (_) => AiPersonaPickerSheet(personas: personas),
  );

  @override
  Widget build(BuildContext context) => KekSheetScaffold(
    title: context.l10n.aiChooseRole,
    child: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 16.0),
      children: [
        for (final AiPersona persona in personas)
          ListTile(
            leading: Text(persona.emoji, style: const TextStyle(fontSize: 28.0)),
            title: Text(persona.name),
            subtitle: persona.isBuiltIn ? null : Text(persona.prompt, maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () => Navigator.of(context).pop(persona),
          ),
      ],
    ),
  );
}
