// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/repositories/tabs/models/tabs_settings.dart';
import 'package:keklist/domain/services/screenshots/screenshot_demo.dart';
import 'package:keklist/main.dart' as app;
import 'package:keklist/presentation/blocs/tabs_container_bloc/tabs_container_bloc.dart';
import 'package:keklist/presentation/blocs/tabs_container_bloc/tabs_container_event.dart';
import 'package:keklist/presentation/blocs/tabs_container_bloc/tabs_container_state.dart';
import 'package:keklist/presentation/screens/emotions/emotion_editor_sheet.dart';
import 'package:keklist/presentation/screens/emotions/emotion_marking_sheet.dart';
import 'package:keklist/presentation/screens/mind_creator/mind_creator_screen.dart';
import 'package:keklist/presentation/screens/mind_day_collection/mind_day_collection_screen.dart';
import 'package:keklist/presentation/screens/tabs_container/tabs_container_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Walks the demo data scene by scene. For each scene it prints `KEKLIST_SNAP:<scene>` and holds still while
/// `screenshots/capture.sh` takes the device screenshot. Run only through that script.
void main() {
  final IntegrationTestWidgetsFlutterBinding binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('store screenshots', (tester) async {
    expect(kScreenshotMode, isTrue, reason: 'build with --dart-define=KEKLIST_SCREENSHOTS=true');
    await tester.runAsync(_waitForDemoMedia);
    app.main();
    await _waitFor(tester, find.byType(TabsContainerScreen));
    await _wait(tester, 8); // the gallery index reads the photo library

    await _openTab(tester, TabType.today);
    await _snap(tester, 'day');

    final MindDayCollectionScreenState today = tester.state(find.byType(MindDayCollectionScreen));
    today.showMindCreator();
    await _wait(tester, 2);
    await tester.enterText(find.byType(TextField).last, 'Dinner with Anna. We planned the trip to Lisbon in May');
    await _snap(tester, 'typing');
    Navigator.of(tester.element(find.byType(MindCreatorScreen))).pop();
    await _wait(tester, 1);

    final BuildContext context = tester.element(find.byType(TabsContainerScreen));
    EmotionMarkingSheet.show(
      context: context,
      initialSelectedIds: {'calm', 'grateful', 'hopeful'},
      onSelectionChanged: (_) {},
    );
    await _snap(tester, 'emotions');
    EmotionEditorSheet.show(context: tester.element(find.byType(EmotionMarkingSheet)));
    await _wait(tester, 2);
    await tester.enterText(
      find.descendant(of: find.byType(EmotionEditorSheet), matching: find.byType(TextField)),
      'Peaceful',
    );
    await _snap(tester, 'new_emotion');
    Navigator.of(context).pop();
    await _wait(tester, 1);
    Navigator.of(context).pop();
    await _wait(tester, 1);

    await _openTab(tester, TabType.insights);
    await _snap(tester, 'insights');

    await _openTab(tester, TabType.today);
    await _goBackDays(tester, kDemoVoiceDayOffset);
    await _snap(tester, 'voice');

    await _goBackDays(tester, kDemoTripDayOffset - kDemoVoiceDayOffset);
    await _snap(tester, 'gallery');

    await _openTab(tester, TabType.calendar);
    // The calendar opens on today with the empty days ahead below; show the days behind instead.
    await tester.drag(find.byType(Scrollable).hitTestable().first, const Offset(0, 700));
    await _snap(tester, 'calendar');

    await _openTab(tester, TabType.settings);
    await _snap(tester, 'privacy');
  }, timeout: const Timeout(Duration(minutes: 10)));
}

/// capture.sh copies the voice note and round video into the app's documents once the app is installed.
Future<void> _waitForDemoMedia() async {
  const AppFileRepository files = AppFileRepository();
  for (int i = 0; i < 120; i++) {
    final bool ready =
        await File(await files.resolveAbsolutePath(kDemoAudioPath)).exists() &&
        await File(await files.resolveAbsolutePath(kDemoVideoPath)).exists();
    if (ready) return;
    print('KEKLIST_WAIT_MEDIA');
    await Future<void>.delayed(const Duration(seconds: 1));
  }
  print('KEKLIST_NO_MEDIA');
}

Future<void> _wait(WidgetTester tester, int seconds) => tester.pump(Duration(seconds: seconds));

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (int i = 0; i < 120 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
  expect(finder, findsWidgets);
}

Future<void> _snap(WidgetTester tester, String scene) async {
  await _wait(tester, 3);
  print('KEKLIST_SNAP:$scene');
  await _wait(tester, 4);
}

Future<void> _openTab(WidgetTester tester, TabType type) async {
  final TabsContainerBloc bloc = tester.element(find.byType(TabsContainerScreen)).read<TabsContainerBloc>();
  final TabsContainerState state = bloc.state;
  final int index = state.selectedTabs.indexWhere((tab) => tab.type == type);
  expect(index, isNonNegative, reason: '$type tab is hidden');
  bloc.add(TabsContainerChangeSelectedTab(selectedIndex: index));
  await _wait(tester, 2);
}

Future<void> _goBackDays(WidgetTester tester, int days) async {
  final MindDayCollectionScreenState day = tester.state(find.byType(MindDayCollectionScreen));
  for (int i = 0; i < days; i++) {
    day.goToPreviousDay();
    await _wait(tester, 1);
  }
}
