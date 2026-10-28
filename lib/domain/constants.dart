import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:keklist/domain/repositories/tabs/models/tabs_settings.dart';
import 'package:keklist/domain/services/phone_web/phone_web_mode.dart';

final class Themes {
  static final ThemeData light = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: Colors.grey,
    ),
    cardTheme: const CardThemeData(color: Colors.white),
    iconTheme: const IconThemeData(color: Colors.black),
    textTheme: ThemeData().textTheme.apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
          decorationColor: Colors.black,
        ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.black),
      hintStyle: TextStyle(color: Color.fromARGB(255, 90, 77, 77)),
    ),
    cupertinoOverrideTheme: const CupertinoThemeData(
      textTheme: CupertinoTextThemeData(), // This is required for Dialog Inputs
    ),
    splashFactory: NoSplash.splashFactory, // Remove ripple effect on iOS
  );

  static final ThemeData dark = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      onPrimary: Colors.black,
      secondary: Colors.grey,
    ),
    cardTheme: const CardThemeData(color: Colors.black),
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: ThemeData().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
          decorationColor: Colors.white,
        ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.white),
      hintStyle: TextStyle(color: Colors.grey),
    ),
    cupertinoOverrideTheme: const CupertinoThemeData(
      textTheme: CupertinoTextThemeData(), // This is required for Dialog Inputs
    ),
    splashFactory: NoSplash.splashFactory, // Remove ripple effect on iOS
  );
}

final class LayoutConstants {
  static double mindSide = 100.0;
}

final class DateFormatters {
  static DateFormat fullDateFormat(Locale locale) => DateFormat('dd.MM.yyyy - EEEE', locale.languageCode);
  static DateFormat dayMonthAndYearFormat(Locale locale) => DateFormat('dd.MM.yyyy', locale.languageCode);
  static DateFormat dayMonthFormat(Locale locale) => DateFormat('d MMMM', locale.languageCode);
  static DateFormat weekDayFormat(Locale locale) => DateFormat('EEEE', locale.languageCode);

  /// Format weekday with proper capitalization (first letter uppercase)
  static String formatWeekday(DateTime date, Locale locale) {
    final formatter = weekDayFormat(locale);
    final weekday = formatter.format(date);
    return weekday.isNotEmpty ? '${weekday[0].toUpperCase()}${weekday.substring(1).toLowerCase()}' : weekday;
  }

  /// Format full date with proper weekday capitalization
  static String formatFullDate(DateTime date, Locale locale) {
    final formatter = fullDateFormat(locale);
    final fullDate = formatter.format(date);
    // Extract weekday part and capitalize it
    final parts = fullDate.split(' - ');
    if (parts.length == 2) {
      final weekday = parts[1];
      final capitalizedWeekday =
          weekday.isNotEmpty ? '${weekday[0].toUpperCase()}${weekday.substring(1).toLowerCase()}' : weekday;
      return '${parts[0]} - $capitalizedWeekday';
    }
    return fullDate;
  }
}

final class PlatformConstants {
  static String iosGroupId = 'group.kekable';
  static String iosMindDayWidgetName = 'MindDayWidget';
}

final class FlutterConstants {
  static ScrollPhysics mobileOverscrollPhysics =
      const BouncingScrollPhysics().applyTo(const AlwaysScrollableScrollPhysics());
}

enum SupportedPlatform { iOS, android, web }

final class KeklistConstants {
  static String demoAccountEmail = dotenv.get('DEMO_ACCOUNT_EMAIL');
  static String termsOfUseURL = 'https://resashkin.github.io/keklist-terms/';
  static String privacyURL = 'https://resashkin.github.io/keklist-privacy/';
  static String sourceCodeURL = 'https://github.com/resashkin/keklist_flutter';
  // The Telegram web build has no AI: models run on the phone.
  static List<TabModel> get availableTabModels => [
    TabModel(type: TabType.calendar),
    TabModel(type: TabType.insights),
    TabModel(type: TabType.settings),
    TabModel(type: TabType.today),
    if (!kIsWeb || kIsPhoneWeb) TabModel(type: TabType.ai),
  ];

  // Available list of Tabs that can be reached after first launch.
  static TabsSettings defaultTabSettings = TabsSettings(
    defaultSelectedTabIndex: 0,
    selectedTabModels: [
      TabModel(type: TabType.today),
      TabModel(type: TabType.calendar),
      TabModel(type: TabType.insights),
      TabModel(type: TabType.ai),
      TabModel(type: TabType.settings),
    ],
  );
}
