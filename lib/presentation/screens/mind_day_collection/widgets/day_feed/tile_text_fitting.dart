import 'package:material_ui/material_ui.dart';

const String _kEllipsis = '…';

/// The largest font size at which [text] fits [box] without breaking any word, stepping down by [step].
/// When nothing fits at [minFontSize], words wider than the box are cut with "…" so they never wrap mid-word.
({double fontSize, String text}) fitTileText({
  required String text,
  required TextStyle style,
  required Size box,
  required double minFontSize,
  required double maxFontSize,
  TextScaler textScaler = TextScaler.noScaling,
  TextAlign textAlign = TextAlign.center,
  double step = 0.5,
}) {
  final List<String> words = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
  for (double size = maxFontSize; size >= minFontSize; size -= step) {
    final TextStyle sized = style.copyWith(fontSize: size);
    final bool wordsFit = words.every((word) => _widthOf(word, sized, textScaler) <= box.width);
    if (wordsFit && _heightOf(text, sized, textScaler, box.width, textAlign) <= box.height) {
      return (fontSize: size, text: text);
    }
  }
  final TextStyle smallest = style.copyWith(fontSize: minFontSize);
  final String clipped = text.replaceAllMapped(
    RegExp(r'\S+'),
    (match) => _clipWord(match.group(0)!, smallest, textScaler, box.width),
  );
  return (fontSize: minFontSize, text: clipped);
}

String _clipWord(String word, TextStyle style, TextScaler textScaler, double maxWidth) {
  if (_widthOf(word, style, textScaler) <= maxWidth) return word;
  final List<String> characters = word.characters.toList();
  for (int length = characters.length - 1; length > 0; length--) {
    final String candidate = '${characters.take(length).join()}$_kEllipsis';
    if (_widthOf(candidate, style, textScaler) <= maxWidth) return candidate;
  }
  return _kEllipsis;
}

double _widthOf(String text, TextStyle style, TextScaler textScaler) {
  final TextPainter painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textScaler: textScaler,
    maxLines: 1,
  )..layout();
  final double width = painter.width;
  painter.dispose();
  return width;
}

double _heightOf(String text, TextStyle style, TextScaler textScaler, double maxWidth, TextAlign textAlign) {
  final TextPainter painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textAlign: textAlign,
    textScaler: textScaler,
  )..layout(maxWidth: maxWidth);
  final double height = painter.height;
  painter.dispose();
  return height;
}
