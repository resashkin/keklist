import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/haptics/tweak_haptics.dart';
import 'package:material_ui/material_ui.dart';

/// The two motion tweaks shared by the day and calendar sheets: how tile emojis move and how a pinch resizes grids.
final class TileMotionTweaks extends StatelessWidget {
  final KeklistSettings? settings;

  const TileMotionTweaks({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    void update(SettingsUpdateTileMotion event) {
      tweakChangeHaptic();
      context.read<SettingsBloc>().add(event);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Choice<TileEmojiMotion>(
          title: context.l10n.tileEmojiMotion,
          options: {
            TileEmojiMotion.drift: context.l10n.tileEmojiMotionDrift,
            TileEmojiMotion.float: context.l10n.tileEmojiMotionFloat,
            TileEmojiMotion.still: context.l10n.tileEmojiMotionStill,
          },
          selected: settings?.tileEmojiMotion ?? TileEmojiMotion.drift,
          onChanged: (motion) => update(SettingsUpdateTileMotion(emojiMotion: motion)),
        ),
        _Choice<GridResizeAnimation>(
          title: context.l10n.gridResizeAnimation,
          options: {
            GridResizeAnimation.fly: context.l10n.gridResizeFly,
            GridResizeAnimation.zoom: context.l10n.gridResizeZoom,
            GridResizeAnimation.crossfade: context.l10n.gridResizeCrossfade,
          },
          selected: settings?.gridResizeAnimation ?? GridResizeAnimation.fly,
          onChanged: (animation) => update(SettingsUpdateTileMotion(resizeAnimation: animation)),
        ),
      ],
    );
  }
}

final class _Choice<T> extends StatelessWidget {
  final String title;
  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;

  const _Choice({required this.title, required this.options, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8.0,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyLarge),
        SegmentedButton<T>(
          showSelectedIcon: false,
          segments: [
            for (final MapEntry<T, String> option in options.entries)
              ButtonSegment<T>(value: option.key, label: Text(option.value)),
          ],
          selected: {selected},
          onSelectionChanged: (selection) => onChanged(selection.first),
        ),
      ],
    ),
  );
}
