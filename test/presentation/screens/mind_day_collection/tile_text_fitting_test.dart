import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/tile_text_fitting.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const TextStyle style = TextStyle(fontSize: 14.0, height: 1.2);

  test('keeps the max size when the text fits', () {
    final result = fitTileText(text: 'Hi', style: style, box: const Size(200, 200), minFontSize: 7, maxFontSize: 14);
    expect(result.fontSize, 14.0);
    expect(result.text, 'Hi');
  });

  test('shrinks until the longest word fits on one line', () {
    const String word = 'Supercalifragilistic';
    final result = fitTileText(text: word, style: style, box: const Size(200, 200), minFontSize: 7, maxFontSize: 14);
    expect(result.fontSize, lessThan(14.0));
    expect(result.text, word);
  });

  test('clips a word that does not fit even at the minimum size', () {
    final result = fitTileText(
      text: 'a Pneumonoultramicroscopicsilicovolcanoconiosis',
      style: style,
      box: const Size(40, 200),
      minFontSize: 7,
      maxFontSize: 14,
    );
    expect(result.fontSize, 7.0);
    expect(result.text, startsWith('a '));
    expect(result.text, endsWith('…'));
  });
}
