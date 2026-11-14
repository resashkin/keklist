// ignore_for_file: avoid_print

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:keklist/domain/services/screenshots/screenshot_demo.dart';
import 'package:keklist/main.dart' as app;
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';
import 'package:keklist/presentation/screens/tabs_container/tabs_container_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Measures a sheet with a text field opening over the demo Today screen, with the keyboard sliding in either
/// together with the sheet (`autofocus: true`) or after it (`DeferredAutofocus`). The keyboard is simulated through
/// the view insets, so both runs see the same keyboard curve. See `documentation/DEFERRED_AUTOFOCUS.md`.
void main() {
  final IntegrationTestWidgetsFlutterBinding binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('sheet + keyboard: together vs deferred', (tester) async {
    expect(kScreenshotMode, isTrue, reason: 'build with --dart-define=KEKLIST_SCREENSHOTS=true');
    app.main();
    await _waitFor(tester, find.byType(TabsContainerScreen));
    await tester.pump(const Duration(seconds: 5));

    final Map<String, List<_Run>> runs = {'together': [], 'deferred': []};
    await _open(tester, deferKeyboard: false); // warm-up, not counted
    for (int i = 0; i < _repeats; i++) {
      runs['together']!.add(await _open(tester, deferKeyboard: false));
      runs['deferred']!.add(await _open(tester, deferKeyboard: true));
    }

    final Map<String, Object> report = {};
    for (final MapEntry<String, List<_Run>> entry in runs.entries) {
      final _Summary summary = _Summary(entry.value);
      report[entry.key] = summary.toJson();
      print('KEKLIST_PERF ${entry.key}: $summary');
    }
    final List<MapEntry<String, int>> outside = _outsideSheetByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    report['outside_sheet_rebuilds_while_keyboard_slides'] = {
      'total_per_open': outside.fold<int>(0, (sum, e) => sum + e.value) / _repeats,
      for (final MapEntry<String, int> e in outside.take(40)) e.key: e.value / _repeats,
    };
    binding.reportData = report;

    final _Summary together = _Summary(runs['together']!);
    final _Summary deferred = _Summary(runs['deferred']!);
    expect(deferred.rebuildsInOverlap, lessThanOrEqualTo(together.rebuildsInOverlap));
    final num outsideSheet = (report['outside_sheet_rebuilds_while_keyboard_slides']! as Map)['total_per_open'];
    expect(outsideSheet, lessThan(100), reason: 'the screen under a sheet must not rebuild while the keyboard moves');
  }, timeout: const Timeout(Duration(minutes: 5)));
}

const int _repeats = 5;
const double _keyboardHeight = 336.0;
const Duration _keyboardDuration = Duration(milliseconds: 300);
const Duration _routeDuration = Duration(milliseconds: 350);
const Duration _step = Duration(milliseconds: 16);

/// Rebuilds outside the sheet while only the keyboard moves, by widget type; these should be zero.
final Map<String, int> _outsideSheetByType = {};

bool _isInsideSheet(Element element) {
  if (element.widget is KekSheetScaffold) return true;
  bool inside = false;
  element.visitAncestorElements((ancestor) {
    inside = ancestor.widget is KekSheetScaffold;
    return !inside;
  });
  return inside;
}

final class _Run {
  final List<FrameTiming> frames;
  final int rebuilds;
  final int rebuildsInOverlap;

  _Run(this.frames, this.rebuilds, this.rebuildsInOverlap);
}

/// Opens the sheet, slides the simulated keyboard in, closes both and returns what the opening cost.
Future<_Run> _open(WidgetTester tester, {required bool deferKeyboard}) async {
  final List<FrameTiming> frames = [];
  void onTimings(List<FrameTiming> timings) => frames.addAll(timings);
  int rebuilds = 0;
  int rebuildsInOverlap = 0;
  bool routeAnimating = true;
  debugOnRebuildDirtyWidget = (element, _) {
    rebuilds++;
    if (routeAnimating) rebuildsInOverlap++;
    if (deferKeyboard && !routeAnimating && !_isInsideSheet(element)) {
      final String type = element.widget.runtimeType.toString();
      _outsideSheetByType[type] = (_outsideSheetByType[type] ?? 0) + 1;
    }
  };
  WidgetsBinding.instance.addTimingsCallback(onTimings);

  final BuildContext context = tester.element(find.byType(TabsContainerScreen));
  final Future<void> closed = KekSheet.show<void>(
    context: context,
    builder: (_) => const KekSheetScaffold(
      title: 'Note',
      child: Padding(padding: EdgeInsets.all(16), child: TextField(maxLines: 4)),
    ),
  );
  final Stopwatch clock = Stopwatch()..start();
  if (deferKeyboard) {
    await _pumpFor(tester, _routeDuration);
    routeAnimating = false;
    await _slideKeyboard(tester, clock: clock);
  } else {
    await _slideKeyboard(tester, clock: clock);
    await _pumpFor(tester, _routeDuration - _keyboardDuration);
    routeAnimating = false;
  }
  await _pumpFor(tester, const Duration(milliseconds: 200));
  // The engine hands frame timings over in batches about once a second.
  await tester.pump(const Duration(milliseconds: 1200));

  WidgetsBinding.instance.removeTimingsCallback(onTimings);
  debugOnRebuildDirtyWidget = null;

  Navigator.of(context).pop();
  tester.view.resetViewInsets();
  await closed;
  await tester.pump(const Duration(seconds: 1));
  return _Run(frames, rebuilds, rebuildsInOverlap);
}

/// Grows the bottom inset like the iOS keyboard (ease-out over [_keyboardDuration]), one step per frame.
Future<void> _slideKeyboard(WidgetTester tester, {required Stopwatch clock}) async {
  final Duration start = clock.elapsed;
  while (true) {
    final double t = ((clock.elapsed - start).inMicroseconds / _keyboardDuration.inMicroseconds).clamp(0.0, 1.0);
    final double logical = _keyboardHeight * Curves.easeOut.transform(t);
    tester.view.viewInsets = FakeViewPadding(bottom: logical * tester.view.devicePixelRatio);
    await tester.pump(_step);
    if (t >= 1.0) return;
  }
}

Future<void> _pumpFor(WidgetTester tester, Duration duration) async {
  final Stopwatch clock = Stopwatch()..start();
  while (clock.elapsed < duration) {
    await tester.pump(_step);
  }
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (int i = 0; i < 120 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
  expect(finder, findsWidgets);
}

final class _Summary {
  final List<_Run> runs;

  _Summary(this.runs);

  List<double> _ms(Duration Function(FrameTiming) of) => [
    for (final _Run run in runs)
      for (final FrameTiming f in run.frames) of(f).inMicroseconds / 1000,
  ]..sort();

  List<double> get _build => _ms((f) => f.buildDuration);
  List<double> get _raster => _ms((f) => f.rasterDuration);

  double _percentile(List<double> sorted, double p) => sorted.isEmpty ? 0 : sorted[((sorted.length - 1) * p).round()];

  int get frames => _build.length;
  int get slowFrames => [
    for (final _Run run in runs)
      for (final FrameTiming f in run.frames)
        if (f.buildDuration + f.rasterDuration > const Duration(microseconds: 16667)) f,
  ].length;
  double get rebuilds => runs.fold(0, (sum, run) => sum + run.rebuilds) / runs.length;
  double get rebuildsInOverlap => runs.fold(0, (sum, run) => sum + run.rebuildsInOverlap) / runs.length;

  Map<String, Object> toJson() => {
    'frames': frames,
    'slow_frames_over_16ms': slowFrames,
    'build_p50_ms': _percentile(_build, 0.5),
    'build_p90_ms': _percentile(_build, 0.9),
    'build_worst_ms': _build.isEmpty ? 0 : _build.last,
    'raster_p90_ms': _percentile(_raster, 0.9),
    'raster_worst_ms': _raster.isEmpty ? 0 : _raster.last,
    'widget_rebuilds_per_open': rebuilds,
    'widget_rebuilds_while_sheet_slides': rebuildsInOverlap,
  };

  @override
  String toString() => toJson().entries
      .map((e) => '${e.key}=${e.value is double ? (e.value as double).toStringAsFixed(1) : e.value}')
      .join(' ');
}
