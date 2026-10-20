import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keklist/domain/services/emotions/day_emotion_summary.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/blocs/emotion_bloc/emotion_bloc.dart';

final class MindRowWidget extends StatelessWidget {
  final Iterable<Mind> minds;

  const MindRowWidget({super.key, required this.minds});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DayEmotionsText(minds: minds, style: const TextStyle(fontSize: 40.0)),
    );
  }
}

final class DayEmotionsText extends StatelessWidget {
  final Iterable<Mind> minds;
  final TextStyle style;

  const DayEmotionsText({super.key, required this.minds, required this.style});

  static String textOf(BuildContext context, Iterable<Mind> minds) {
    final EmotionState state = context.watch<EmotionBloc>().state;
    return DayEmotionSummary.of(minds, (id) => state is EmotionsList ? state.byId(id) : null).text;
  }

  @override
  Widget build(BuildContext context) => Text(textOf(context, minds), style: style, textAlign: TextAlign.center);
}
