import 'package:keklist/domain/services/ai/ai_backend.dart';
import 'package:keklist/domain/services/ai/ai_entities.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/glass_app_bar.dart';
import 'package:keklist/presentation/core/widgets/settings/settings_section.dart';
import 'package:keklist/presentation/screens/ai/ai_format.dart';
import 'package:keklist/presentation/screens/ai/ai_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

/// Built-in roles can be read and duplicated; own roles can be written, changed and deleted.
final class AiPersonasScreen extends StatefulWidget {
  const AiPersonasScreen({super.key});

  static Future<void> open(BuildContext context) => pushAiRoute<void>(context, (_) => const AiPersonasScreen());

  @override
  State<AiPersonasScreen> createState() => _AiPersonasScreenState();
}

final class _AiPersonasScreenState extends State<AiPersonasScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AiFormat.configure(context, context.read<AiBackend>());
  }

  @override
  Widget build(BuildContext context) {
    final AiBackend backend = context.watch<AiBackend>();
    final List<AiPersona> builtIn = backend.personas.where((persona) => persona.isBuiltIn).toList();
    final List<AiPersona> own = backend.personas.where((persona) => !persona.isBuiltIn).toList();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(centerTitle: true, title: Text(context.l10n.aiRoles)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'ai_new_role',
        onPressed: () => AiPersonaEditorScreen.open(
          context,
          persona: const AiPersona(id: '', name: '', emoji: '💬', prompt: ''),
        ),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.aiNewRole),
      ),
      body: SettingsListView(
        children: [
          const SizedBox(height: 56.0),
          SettingsSectionHeader(context.l10n.aiBuiltInRole.toUpperCase()),
          SettingsSectionCard(children: [for (final AiPersona persona in builtIn) _PersonaTile(persona: persona)]),
          if (own.isNotEmpty) ...[
            SettingsSectionHeader(context.l10n.aiOwnRoles.toUpperCase()),
            SettingsSectionCard(children: [for (final AiPersona persona in own) _PersonaTile(persona: persona)]),
          ],
          const SizedBox(height: 80.0),
        ],
      ),
    );
  }
}

final class _PersonaTile extends StatelessWidget {
  const _PersonaTile({required this.persona});

  final AiPersona persona;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Text(persona.emoji, style: const TextStyle(fontSize: 26.0)),
    title: Text(persona.name),
    subtitle: Text(persona.prompt, maxLines: 2, overflow: TextOverflow.ellipsis),
    trailing: settingsNavTrailing(context),
    onTap: () => AiPersonaEditorScreen.open(context, persona: persona),
  );
}

/// Name, emoji and prompt of a role. A built-in role opens read-only with a way to duplicate it.
final class AiPersonaEditorScreen extends StatefulWidget {
  const AiPersonaEditorScreen({super.key, required this.persona});

  final AiPersona persona;

  static Future<void> open(BuildContext context, {required AiPersona persona}) =>
      pushAiRoute<void>(context, (_) => AiPersonaEditorScreen(persona: persona));

  @override
  State<AiPersonaEditorScreen> createState() => _AiPersonaEditorScreenState();
}

final class _AiPersonaEditorScreenState extends State<AiPersonaEditorScreen> {
  static const double _maxWidth = 700.0;

  late final TextEditingController _name = TextEditingController(text: widget.persona.name);
  late final TextEditingController _emoji = TextEditingController(text: widget.persona.emoji);
  late final TextEditingController _prompt = TextEditingController(text: widget.persona.prompt);

  bool get _isReadOnly => widget.persona.isBuiltIn;

  @override
  void dispose() {
    _name.dispose();
    _emoji.dispose();
    _prompt.dispose();
    super.dispose();
  }

  bool get _canSave => _name.text.trim().isNotEmpty && _prompt.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!_canSave) return;
    final String emoji = _emoji.text.trim();
    await context.read<AiBackend>().savePersona(
      widget.persona.copyWith(
        name: _name.text.trim(),
        emoji: emoji.isEmpty ? '💬' : emoji.characters.first,
        prompt: _prompt.text.trim(),
        isBuiltIn: false,
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  void _duplicate() => Navigator.of(context).pushReplacement(
    SwipeablePageRoute<void>(
      builder: (_) => AiPersonaEditorScreen(
        persona: widget.persona.copyWith(id: '', name: '${widget.persona.name} 2', isBuiltIn: false),
      ),
    ),
  );

  Future<void> _delete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.aiDeleteRole),
        content: Text(widget.persona.name),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.cancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.delete)),
        ],
      ),
    );
    if (!(confirmed ?? false) || !mounted) return;
    await context.read<AiBackend>().deletePersona(widget.persona.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool isNew = widget.persona.id.isEmpty;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        centerTitle: true,
        title: Text(isNew ? context.l10n.aiNewRole : widget.persona.name),
        actions: [
          if (!_isReadOnly && !isNew)
            GlassBarAction(icon: Icons.delete_outline_rounded, tooltip: context.l10n.delete, onPressed: _delete),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              16.0,
              MediaQuery.paddingOf(context).top + 72.0,
              16.0,
              MediaQuery.paddingOf(context).bottom + 24.0,
            ),
            children: [
              if (_isReadOnly)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(context.l10n.aiReadOnlyRole, style: TextStyle(color: Theme.of(context).hintColor)),
                ),
              Row(
                spacing: 12.0,
                children: [
                  SizedBox(
                    width: 72.0,
                    child: TextField(
                      controller: _emoji,
                      readOnly: _isReadOnly,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24.0),
                      decoration: InputDecoration(
                        labelText: context.l10n.aiRoleEmoji,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _name,
                      readOnly: _isReadOnly,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: context.l10n.aiRoleName,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _prompt,
                readOnly: _isReadOnly,
                minLines: 6,
                maxLines: 16,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: context.l10n.aiRolePrompt,
                  hintText: context.l10n.aiRolePromptHint,
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              if (_isReadOnly)
                FilledButton.icon(
                  onPressed: _duplicate,
                  icon: const Icon(Icons.copy_rounded),
                  label: Text(context.l10n.aiDuplicate),
                )
              else
                FilledButton(onPressed: _canSave ? _save : null, child: Text(context.l10n.save)),
            ],
          ),
        ),
      ),
    );
  }
}
