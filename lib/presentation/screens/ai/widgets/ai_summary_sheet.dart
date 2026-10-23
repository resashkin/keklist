import 'package:keklist/domain/services/ai/ai_backend.dart';
import 'package:keklist/domain/services/ai/ai_entities.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';
import 'package:keklist/presentation/screens/ai/ai_screen.dart';
import 'package:keklist/presentation/screens/mind_day_collection/mind_day_collection_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

/// A day's whole summary, with a way to the day itself and to write the summary again.
final class AiSummarySheet extends StatelessWidget {
  const AiSummarySheet({super.key, required this.dayIndex});

  final int dayIndex;

  static Future<void> show(BuildContext context, {required int dayIndex}) => KekSheet.show<void>(
    context: context,
    builder: (_) => AiSummarySheet(dayIndex: dayIndex),
  );

  @override
  Widget build(BuildContext context) {
    final AiBackend backend = context.watch<AiBackend>();
    final AiDaySummary? summary = backend.summaries[dayIndex];
    final bool isRunning = backend.summarizingDays.contains(dayIndex);
    return KekSheetScaffold(
      title: AiDayLabel.of(context, dayIndex),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16.0,
          children: [
            if (isRunning)
              const LinearProgressIndicator()
            else
              SelectableText(summary?.text ?? context.l10n.aiSummarize, style: const TextStyle(height: 1.4)),
            Row(
              spacing: 8.0,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: backend.modelName == null || isRunning ? null : () => backend.summarizeDay(dayIndex),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(context.l10n.aiRegenerate),
                  ),
                ),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      final NavigatorState navigator = Navigator.of(context)..pop();
                      navigator.push(
                        SwipeablePageRoute<void>(builder: (_) => MindDayCollectionScreen(initialDayIndex: dayIndex)),
                      );
                    },
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(context.l10n.aiActionOpenDay),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
