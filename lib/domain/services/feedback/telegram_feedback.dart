import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Sends feedback the user typed to the developer through a feedback-only Telegram bot.
/// Only the text, the app version and the platform go out, and only when the user taps Send.
abstract final class TelegramFeedback {
  static const int _maxLength = 4000;

  static String? get _token => dotenv.maybeGet('TELEGRAM_FEEDBACK_BOT_TOKEN');
  static String? get _chatId => dotenv.maybeGet('TELEGRAM_FEEDBACK_CHAT_ID');

  static bool get isConfigured => (_token?.isNotEmpty ?? false) && (_chatId?.isNotEmpty ?? false);

  static Future<bool> send(String text) async {
    final String? token = _token, chatId = _chatId;
    if (token == null || chatId == null) return false;
    final PackageInfo info = await PackageInfo.fromPlatform();
    final String body = text.substring(0, min(_maxLength, text.length));
    final String message =
        '💬 $body\n\n— keklist ${info.version} (${info.buildNumber}) · ${defaultTargetPlatform.name}';
    try {
      final http.Response response = await http
          .post(Uri.parse('https://api.telegram.org/bot$token/sendMessage'), body: {'chat_id': chatId, 'text': message})
          .timeout(const Duration(seconds: 15));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
