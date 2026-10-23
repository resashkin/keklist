import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/haptics/tweak_haptics.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';
import 'package:material_ui/material_ui.dart';

/// Shake-to-tweak sheet of the mind creator: when it asks for emotions.
final class MindCreatorTweakSheet extends StatelessWidget {
  const MindCreatorTweakSheet({super.key});

  static Future<void> show(BuildContext context) =>
      KekSheet.show<void>(context: context, builder: (_) => const MindCreatorTweakSheet());

  @override
  Widget build(BuildContext context) {
    final SettingsState state = context.watch<SettingsBloc>().state;
    final MindEmotionsPrompt selected = state is SettingsDataState
        ? state.settings.mindEmotionsPrompt
        : MindEmotionsPrompt.afterSave;
    return KekSheetScaffold(
      title: context.l10n.creatorEmotionsTitle,
      child: RadioGroup<MindEmotionsPrompt>(
        groupValue: selected,
        onChanged: (prompt) {
          if (prompt == null) return;
          tweakChangeHaptic();
          context.read<SettingsBloc>().add(SettingsUpdateMindEmotionsPrompt(prompt: prompt));
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final MindEmotionsPrompt prompt in MindEmotionsPrompt.values)
              RadioListTile<MindEmotionsPrompt>(
                value: prompt,
                title: Text(switch (prompt) {
                  MindEmotionsPrompt.afterSave => context.l10n.creatorEmotionsAfterSave,
                  MindEmotionsPrompt.button => context.l10n.creatorEmotionsButton,
                  MindEmotionsPrompt.never => context.l10n.creatorEmotionsNever,
                }),
              ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
