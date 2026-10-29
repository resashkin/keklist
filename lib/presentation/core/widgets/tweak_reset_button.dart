import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/haptics/tweak_haptics.dart';
import 'package:material_ui/material_ui.dart';

/// "Reset" in a tweak menu's header; shown only while [isChanged] says that menu differs from its defaults.
final class TweakResetButton extends StatelessWidget {
  final bool Function(KeklistSettings settings) isChanged;
  final KeklistSettings Function(KeklistSettings settings) reset;

  const TweakResetButton({super.key, required this.isChanged, required this.reset});

  @override
  Widget build(BuildContext context) {
    final SettingsState state = context.watch<SettingsBloc>().state;
    if (state is! SettingsDataState || !isChanged(state.settings)) return const SizedBox.shrink();
    return TextButton(
      onPressed: () {
        tweakChangeHaptic();
        context.read<SettingsBloc>().add(SettingsResetTweaks(reset: reset));
      },
      child: Text(context.l10n.tweakReset),
    );
  }
}
