import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:keklist/domain/hive_constants.dart';
import 'package:keklist/domain/repositories/mind/object/mind_object.dart';
import 'package:keklist/domain/repositories/mind/mind_hive_repository.dart';
import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:keklist/domain/services/entities/mind.dart';

void main() {
  late Directory tempDir;
  late MindRepository repository;

  setUpAll(() async {
    // Use an isolated temp dir so boxes never land in the project root.
    tempDir = Directory.systemTemp.createTempSync('hive_mind_repo_benchmark');
    Hive.init(tempDir.path);
    Hive.registerAdapter<MindObject>(MindObjectAdapter());
    repository = MindHiveRepository(box: await Hive.openBox<MindObject>(HiveConstants.mindBoxName));
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('stores and reads back 10000 minds', () async {
    final List<Mind> minds = List.generate(
      10000,
      (index) => Mind(
        id: index.toString(),
        note: 'Hahahahahahaasdgasjdglashdglsdhglskdfhglsdkfjhgsldkfahaha',
        legacyEmoji: ' ',
        dayIndex: 0,
        sortIndex: 5,
        creationDate: DateTime.now(),
        rootId: null,
      ),
      growable: false,
    );

    final Stopwatch stopwatch = Stopwatch()..start();
    await repository.createMinds(minds: minds);
    await repository.updateMinds(minds: minds);
    final Iterable<Mind> obtained = await repository.obtainMinds();
    stopwatch.stop();

    expect(obtained.length, minds.length);
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 30)));
  });
}
