import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/blocs/emotion_bloc/emotion_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The emojis of a mind's tagged emotions in a row, or [placeholder] when it has none.
final class MindEmotionEmojis extends StatelessWidget {
  final Mind mind;
  final double fontSize;
  final int? maxCount;
  final Widget placeholder;

  const MindEmotionEmojis({
    super.key,
    required this.mind,
    required this.fontSize,
    this.maxCount,
    this.placeholder = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    if (mind.emotionIds.isEmpty) return placeholder;
    return BlocBuilder<EmotionBloc, EmotionState>(
      builder: (context, state) {
        if (state is! EmotionsList) return placeholder;
        final List<String> emojis = mind.emotionIds.map(state.byId).whereType<Emotion>().map((e) => e.emoji).toList();
        if (emojis.isEmpty) return placeholder;
        final Iterable<String> shown = maxCount == null ? emojis : emojis.take(maxCount!);
        return Text(shown.join(' '), maxLines: 1, overflow: TextOverflow.clip, style: TextStyle(fontSize: fontSize));
      },
    );
  }
}
