import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/blocs/emotion_bloc/emotion_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// A mind's emotion emojis repeated as a faint, tilted pattern that fills its parent.
final class MindEmotionTexture extends StatelessWidget {
  final Mind mind;
  final double emojiSize;
  final double opacity;

  const MindEmotionTexture({super.key, required this.mind, required this.emojiSize, this.opacity = 0.2});

  @override
  Widget build(BuildContext context) {
    if (mind.emotionIds.isEmpty) return const SizedBox.shrink();
    return BlocBuilder<EmotionBloc, EmotionState>(
      builder: (context, state) {
        if (state is! EmotionsList) return const SizedBox.shrink();
        final List<String> emojis = mind.emotionIds.map(state.byId).whereType<Emotion>().map((e) => e.emoji).toList();
        if (emojis.isEmpty) return const SizedBox.shrink();
        return IgnorePointer(
          child: ExcludeSemantics(
            child: Opacity(
              // Light backgrounds make the pattern louder than the text on top of it.
              opacity: Theme.of(context).brightness == Brightness.light ? opacity * 0.5 : opacity,
              child: LayoutBuilder(builder: (context, constraints) => _buildPattern(emojis, constraints.biggest)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPattern(List<String> emojis, Size size) {
    final double step = emojiSize * 1.6;
    // The rotated pattern must still cover the corners, so it is laid out over the diagonal.
    final double side = math.sqrt(size.width * size.width + size.height * size.height);
    final int count = (side / step).ceil() + 1;
    int index = 0;
    return OverflowBox(
      maxWidth: side,
      maxHeight: side,
      child: Transform.rotate(
        angle: -math.pi / 12,
        child: SizedBox.square(
          dimension: side,
          child: Stack(
            children: [
              for (int row = 0; row < count; row++)
                for (int column = 0; column < count; column++)
                  Positioned(
                    left: column * step + (row.isOdd ? step / 2 : 0) - step / 2,
                    top: row * step - step / 2,
                    child: Text(
                      emojis[index++ % emojis.length],
                      style: TextStyle(fontSize: emojiSize, height: 1.0),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
