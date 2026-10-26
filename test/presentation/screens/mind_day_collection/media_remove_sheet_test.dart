import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/l10n/app_localizations.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/media_remove_sheet.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<MediaRemoval?> pick(WidgetTester tester, String choice) async {
    MediaRemoval? result;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await MediaRemoveSheet.show(context, isVideo: false),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Remove photo'), findsOneWidget);
    await tester.tap(find.text(choice));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('hide keeps the photo in the gallery', (tester) async {
    expect(await pick(tester, 'Hide'), MediaRemoval.hide);
  });

  testWidgets('delete from gallery is the other choice', (tester) async {
    expect(await pick(tester, 'Delete from gallery'), MediaRemoval.deleteFromGallery);
  });
}
