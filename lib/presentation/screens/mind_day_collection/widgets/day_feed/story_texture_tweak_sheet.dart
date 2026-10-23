import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/extensions/story_settings_extension.dart';
import 'package:keklist/presentation/core/haptics/tweak_haptics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';

/// Shake sheet of stories and the viewer: date header lines, how the emotion texture moves with the sound,
/// the spectrum around circles and how strongly both react.
final class StoryTextureTweakSheet extends StatelessWidget {
  const StoryTextureTweakSheet({super.key});

  static Future<void> show(BuildContext context) =>
      KekSheet.show(context: context, builder: (_) => const StoryTextureTweakSheet());

  @override
  Widget build(BuildContext context) {
    final StorySettings story = context.watchStorySettings();
    void update(StorySettings value) {
      tweakChangeHaptic();
      context.read<SettingsBloc>().add(SettingsUpdateStory(story: value));
    }

    return KekSheetScaffold(
      title: context.l10n.storyBackgroundTweak,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionTitle(context.l10n.storyDateLines),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SegmentedButton<StoryDateLayout>(
                showSelectedIcon: false,
                segments: [
                  for (final StoryDateLayout layout in StoryDateLayout.values)
                    ButtonSegment(value: layout, label: Text('${layout.index + 1}')),
                ],
                selected: {story.dateLayout},
                onSelectionChanged: (selection) => update(story.copyWith(dateLayout: selection.first)),
              ),
            ),
            _SectionTitle(context.l10n.storyTextureTitle),
            for (final StoryTextureAnimation animation in StoryTextureAnimation.values)
              ListTile(
                leading: Icon(_iconOf(animation)),
                title: Text(_titleOf(context, animation)),
                trailing: animation == story.textureAnimation ? const Icon(Icons.check_rounded) : null,
                onTap: () => update(story.copyWith(textureAnimation: animation)),
              ),
            SwitchListTile(
              secondary: const Icon(Icons.graphic_eq_rounded),
              title: Text(context.l10n.storySpectrum),
              value: story.isSpectrumVisible,
              onChanged: (value) => update(story.copyWith(isSpectrumVisible: value)),
            ),
            _SectionTitle('${context.l10n.storySensitivity} · ${story.sensitivity.toStringAsFixed(1)}×'),
            Slider(
              value: story.sensitivity,
              min: StorySettings.minSensitivity,
              max: StorySettings.maxSensitivity,
              divisions: ((StorySettings.maxSensitivity - StorySettings.minSensitivity) * 10).round(),
              onChanged: (value) => update(story.copyWith(sensitivity: value)),
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
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

final class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
    child: Text(title, style: Theme.of(context).textTheme.titleSmall),
  );
}
