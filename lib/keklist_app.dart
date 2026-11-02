import 'package:material_ui/material_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart' as cupertino_ui;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:keklist/domain/repositories/settings/keklist_theme_mode.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/domain/constants.dart';
import 'package:keklist/presentation/core/helpers/bloc_utils.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';
import 'package:keklist/presentation/core/screen/kek_screen_state.dart';
import 'package:keklist/presentation/screens/tabs_container/tabs_container_screen.dart';
import 'package:keklist/l10n/app_localizations.dart';
import 'package:keklist/domain/services/language_manager.dart';
import 'package:keklist/native/ios/interface_style_channel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/debug_menu/debug_menu_repository.dart';
import 'package:keklist/presentation/blocs/debug_menu_bloc/debug_menu_bloc.dart';
import 'package:keklist/presentation/core/widgets/touch_indicators.dart';

final class KeklistApp extends StatefulWidget {
  const KeklistApp({super.key});

  @override
  State<KeklistApp> createState() => KeklistAppState();
}

final class KeklistAppState extends KekWidgetState<KeklistApp> {
  KeklistThemeMode _themePreference = KeklistThemeMode.system;
  SupportedLanguage _currentLanguage = SupportedLanguage.english;

  @override
  void initState() {
    super.initState();

    subscribeToBloc<SettingsBloc>(
      onNewState: (state) {
        if (state is SettingsDataState) {
          setState(() {
            _themePreference = state.settings.themePreference;
            _currentLanguage = state.settings.language;
          });
        }
      },
    )?.disposed(by: this);
  }

  static final TransitionBuilder _easyLoadingBuilder = EasyLoading.init();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'keklist',
      home: const TabsContainerScreen(),
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: switch (_themePreference) {
        KeklistThemeMode.light => ThemeMode.light,
        KeklistThemeMode.dark => ThemeMode.dark,
        KeklistThemeMode.system => ThemeMode.system,
      },
      locale: _currentLanguage.locale,
      // material_ui and cupertino_ui ship their own localization types, separate from flutter_localizations'.
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        GlobalMaterialLocalizations.delegate,
        cupertino_ui.GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        InterfaceStyleChannel.sync(Theme.of(context).brightness);
        return BlocBuilder<DebugMenuBloc, DebugMenuState>(
          buildWhen: (_, current) => current is DebugMenuDataState,
          builder: (context, state) => TouchIndicators(
            isEnabled: state is DebugMenuDataState &&
                state.debugMenuItems.any((item) => item.type == DebugMenuType.showTouches && item.value),
            child: _easyLoadingBuilder(context, child),
          ),
        );
      },
    );
  }
}
