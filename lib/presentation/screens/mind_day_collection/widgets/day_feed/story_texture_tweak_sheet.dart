import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/haptics/tweak_haptics.dart';
import 'package:material_ui/material_ui.dart';

/// Shake sheet of stories and the viewer: how the emotion texture moves with the sound.
final class StoryTextureTweakSheet extends StatelessWidget {
  const StoryTextureTweakSheet({super.key});

  static Future<void> show(BuildContext context) =>
      showModalBottomSheet(context: context, showDragHandle: true, builder: (_) => const StoryTextureTweakSheet());

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (_, current) => current is SettingsDataState,
      builder: (context, state) {
        final StoryTextureAnimation selected = state is SettingsDataState
            ? state.settings.storyTextureAnimation
            : StoryTextureAnimation.pulse;
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.storyBackgroundTweak, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8.0),
              for (final StoryTextureAnimation animation in StoryTextureAnimation.values)
                ListTile(
                  leading: Icon(_iconOf(animation)),
                  title: Text(_titleOf(context, animation)),
                  trailing: animation == selected ? const Icon(Icons.check_rounded) : null,
                  onTap: () {
                    tweakChangeHaptic();
                    context.read<SettingsBloc>().add(SettingsUpdateStoryTextureAnimation(animation: animation));
                  },
                ),
              const SizedBox(height: 8.0),
            ],
          ),
        );
      },
    );
  }

  static String _titleOf(BuildContext context, StoryTextureAnimation animation) => switch (animation) {
    StoryTextureAnimation.off => context.l10n.storyAnimationOff,
    StoryTextureAnimation.pulse => context.l10n.storyAnimationPulse,
    StoryTextureAnimation.wave => context.l10n.storyAnimationWave,
    StoryTextureAnimation.equalizer => context.l10n.storyAnimationEqualizer,
    StoryTextureAnimation.drift => context.l10n.storyAnimationDrift,
    StoryTextureAnimation.glow => context.l10n.storyAnimationGlow,
  };

  static IconData _iconOf(StoryTextureAnimation animation) => switch (animation) {
    StoryTextureAnimation.off => Icons.block_rounded,
    StoryTextureAnimation.pulse => Icons.favorite_border_rounded,
    StoryTextureAnimation.wave => Icons.waves_rounded,
    StoryTextureAnimation.equalizer => Icons.equalizer_rounded,
    StoryTextureAnimation.drift => Icons.air_rounded,
    StoryTextureAnimation.glow => Icons.flare_rounded,
  };
}
