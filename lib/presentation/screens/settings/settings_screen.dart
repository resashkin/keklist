import 'package:keklist/presentation/core/widgets/glass_app_bar.dart';
import 'dart:async';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:keklist/domain/constants.dart';
import 'package:keklist/domain/services/media_index/gallery_indexer.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/domain/services/export_import/models/import_result.dart';
import 'package:keklist/presentation/blocs/emotion_bloc/emotion_bloc.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/blocs/membership_bloc/membership_bloc.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/helpers/bloc_utils.dart';
import 'package:keklist/presentation/core/helpers/platform_utils.dart';
import 'package:keklist/presentation/core/screen/kek_screen_state.dart';
import 'package:keklist/presentation/screens/actions/action_model.dart';
import 'package:keklist/presentation/screens/actions/actions_screen.dart';
import 'package:keklist/presentation/screens/appearance_settings/appearance_settings_screen.dart';
import 'package:keklist/presentation/screens/debug_menu/debug_menu_screen.dart';
import 'package:keklist/presentation/screens/language_picker/language_picker_screen.dart';
import 'package:keklist/presentation/core/shake/shake_to_tweak_mixin.dart';
import 'package:keklist/presentation/screens/settings/settings_layout.dart';
import 'package:keklist/presentation/screens/settings/widgets/web_version_rows.dart';
import 'package:keklist/domain/services/web_server/keklist_web_server.dart';
import 'package:keklist/domain/services/phone_web/phone_web_mode.dart';
import 'package:keklist/presentation/screens/settings/widgets/gallery_index_tile.dart';
import 'package:keklist/presentation/screens/settings/widgets/password_input_bottom_sheet.dart';
import 'package:keklist/presentation/screens/settings/widgets/settings_customize_bottom_sheet.dart';
import 'package:keklist/presentation/screens/tabs_settings/tabs_settings_screen.dart';
import 'package:keklist/presentation/screens/web_page/web_page_screen.dart';
import 'package:keklist/presentation/screens/paywall/paywall_bottom_sheet.dart';
import 'package:keklist/presentation/core/widgets/settings/settings_section.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';

// TODO: move methods from MindBloc to SettingsBloc

final class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

final class SettingsScreenState extends KekWidgetState<SettingsScreen> with ShakeToTweakMixin {
  //bool _isSensitiveContentShowed = false;
  String? translateLanguageCode;
  int _appBarTapCount = 0;
  bool _isDebugMenuVisible = false;
  bool _isPro = false;
  DateTime? _proNextRenewalDate;
  String? _proPriceString;
  Set<String> _hiddenItemIds = {};

  @override
  void initState() {
    super.initState();

    subscribeToBloc<SettingsBloc>(
      onNewState: (state) {
        switch (state) {
          case SettingsDataState state:
            setState(() {
              _isDebugMenuVisible = state.settings.isDebugMenuVisible;
              _hiddenItemIds = state.settings.hiddenSettingsItemIds;
            });
            break;
          case SettingsShowMessage state:
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(state.title),
                content: Text(state.message),
                actions: [TextButton(child: const Text('OK'), onPressed: () => Navigator.of(context).pop())],
              ),
            );
          case SettingsLoadingState state:
            if (state.isLoading) {
              EasyLoading.show();
            } else {
              EasyLoading.dismiss();
            }
            break;
          case SettingsExportSuccess _:
            // Success - no alert needed, metadata was shown in password sheet
            break;
          case SettingsExportError state:
            _showErrorMessage(context.l10n.exportError, state.message);
            break;
          case SettingsImportSuccess state:
            _showSuccessMessage(
              context.l10n.importSuccess,
              '${context.l10n.mindsImported}: ${state.mindsCount}\n'
              '${context.l10n.audioFilesImported}: ${state.audioFilesCount}',
            );
            break;
          case SettingsImportError state:
            // For invalid password error, show retry dialog
            if (state.error == ImportError.invalidPassword) {
              _handleInvalidPasswordError();
            } else {
              _showErrorMessage(context.l10n.importError, state.message);
            }
            break;
        }
      },
    )?.disposed(by: this);
    subscribeToBloc<MembershipBloc>(
      onNewState: (state) {
        if (state is MembershipDataState) {
          setState(() {
            _isPro = state.isPro;
            _proNextRenewalDate = state.nextRenewalDate;
            _proPriceString = state.priceString;
          });
        }
      },
    )?.disposed(by: this);
    sendEventToBloc<MembershipBloc>(const MembershipGetEvent());
    sendEventToBloc<SettingsBloc>(SettingsGet());
  }

  @override
  String get shakeScreenId => ShakeScreenIds.settings;

  @override
  void onShakeToTweak() {
    KekSheet.show(
      context: context,
      builder: (_) => SettingsCustomizeBottomSheet(sections: _buildSections(context)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        centerTitle: true,
        onTitleTap: _handleAppBarTap,
        onTitleLongPress: requestTweak,
        title: Text(context.l10n.settings),
      ),
      body: StreamBuilder<GalleryIndexProgress>(
        stream: context.read<GalleryIndexer>().progress,
        builder: (context, snapshot) => SettingsListView(
          children: [
            for (final SettingsSectionModel section in _buildSections(
              context,
              isIndexing: snapshot.data?.status == GalleryIndexStatus.indexing,
            ).visibleExcept(_hiddenItemIds)) ...[
              SettingsSectionHeader(section.title.toUpperCase()),
              SettingsSectionCard(children: [for (final SettingsRowModel row in section.rows) row.tile]),
            ],
          ],
        ),
      ),
    );
  }

  /// Running jobs get their own section on top while they run; it is never customizable.
  List<SettingsSectionModel> _buildSections(BuildContext context, {bool isIndexing = false}) => [
    if (isIndexing)
      SettingsSectionModel(
        id: SettingsItemIds.activeTasksSection,
        title: context.l10n.activeTasks,
        rows: [_galleryIndexRow(context)],
      ),
    // Export, import and wiping belong to the phone that owns the data.
    if (!kIsPhoneWeb)
      SettingsSectionModel(
        id: SettingsItemIds.userDataSection,
        title: context.l10n.userData,
        rows: [
          _navigationRow(
            id: SettingsItemIds.exportData,
            title: context.l10n.exportData,
            leading: const Icon(Icons.upload, color: Colors.redAccent),
            hasChevron: false,
            onTap: () => _handleExport(),
          ),
          _navigationRow(
            id: SettingsItemIds.importData,
            title: context.l10n.importData,
            leading: const Icon(Icons.download, color: Colors.greenAccent),
            hasChevron: false,
            onTap: () => _handleImport(),
          ),
          if (!isIndexing && GalleryIndexTile.isAvailable(context)) _galleryIndexRow(context),
        ],
      ),
    // Only the phone serves the web version.
    if (!kIsWeb)
      SettingsSectionModel(
        id: SettingsItemIds.webVersionSection,
        title: context.l10n.webVersion,
        rows: webVersionRows(context, context.watch<KeklistWebServer>()),
      ),
    SettingsSectionModel(
      id: SettingsItemIds.applicationSection,
      title: 'Application', // TODO: localize
      rows: [
        if (!_isPro)
          _navigationRow(
            id: SettingsItemIds.pro,
            title: 'keklist PRO',
            leading: const Icon(Icons.handshake, color: Colors.yellowAccent),
            onTap: () => _openPaywall(),
          ),
        _navigationRow(
          id: SettingsItemIds.releaseNotes,
          title: context.l10n.releaseNotes,
          leading: const Icon(Icons.new_releases, color: Color.fromARGB(255, 191, 188, 191)),
          onTap: () => _showWhatsNew(),
        ),
        _navigationRow(
          id: SettingsItemIds.devBlog,
          title: 'Dev Blog [Telegram] [RU]', // TODO: move to feedback settings (new screen)
          leading: const Icon(Icons.newspaper, color: Colors.blue),
          onTap: () => _openAppNews(),
        ),
        _navigationRow(
          id: SettingsItemIds.suggestFeature,
          title: context.l10n.suggestFeature,
          leading: const Icon(Icons.handyman, color: Colors.green),
          onTap: () => _openSuggestFeature(),
        ),
        _navigationRow(
          id: SettingsItemIds.emailUs,
          title: context.l10n.emailUs,
          leading: const Icon(Icons.feedback, color: Colors.blueGrey),
          onTap: () async => await _openEmailFeedbackForm(),
        ),
        if (_isPro && !kIsPhoneWeb)
          SettingsRowModel(id: SettingsItemIds.proStatus, title: 'keklist PRO', tile: _buildProFooterTile(context)),
      ],
    ),
    SettingsSectionModel(
      id: SettingsItemIds.appearanceSection,
      title: context.l10n.appearance,
      rows: [
        _navigationRow(
          id: SettingsItemIds.language,
          title: context.l10n.language,
          leading: const Icon(Icons.language),
          onTap: () => _showLanguagePicker(),
        ),
        _navigationRow(
          id: SettingsItemIds.appearance,
          title: context.l10n.appearance,
          leading: const Icon(Icons.brightness_medium, color: Colors.grey),
          onTap: () => _showAppearanceSettings(),
        ),
        _navigationRow(
          id: SettingsItemIds.tabsSettings,
          title: context.l10n.tabsSettings,
          leading: const Icon(Icons.dashboard, color: Colors.blue),
          onTap: () => _showTabsSettings(),
        ),
        if (_isDebugMenuVisible)
          _navigationRow(
            id: SettingsItemIds.debugMenu,
            title: context.l10n.debugMenu,
            leading: const Icon(Icons.bug_report, color: Colors.orange),
            onTap: () => _showDebugMenu(),
          ),
      ],
    ),
    SettingsSectionModel(
      id: SettingsItemIds.aboutSection,
      title: context.l10n.about,
      rows: [
        _navigationRow(
          id: SettingsItemIds.sourceCode,
          title: context.l10n.sourceCode,
          leading: const Icon(Icons.code, color: Colors.yellow),
          onTap: () async => await _openSourceCode(),
        ),
        _navigationRow(
          id: SettingsItemIds.termsOfUse,
          title: context.l10n.termsOfUse,
          leading: const Icon(Icons.verified_user, color: Colors.grey),
          onTap: () => _openTermsOfUse(),
        ),
        _navigationRow(
          id: SettingsItemIds.privacyPolicy,
          title: context.l10n.privacyPolicy,
          leading: const Icon(Icons.privacy_tip, color: Colors.grey),
          onTap: () => _openPrivacyPolicy(),
        ),
        _navigationRow(
          id: SettingsItemIds.licenses,
          title: context.l10n.licenses,
          leading: const Icon(Icons.description_outlined, color: Colors.grey),
          onTap: () => showLicensePage(context: context),
        ),
      ],
    ),
    if (!kIsPhoneWeb)
      SettingsSectionModel(
        id: SettingsItemIds.dangerZoneSection,
        title: context.l10n.dangerZone,
        rows: [
          _navigationRow(
            id: SettingsItemIds.clearOnDeviceData,
            title: context.l10n.clearOnDeviceData,
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            hasChevron: false,
            onTap: () async => await _clearCache(),
          ),
        ],
      ),
  ];

  SettingsRowModel _galleryIndexRow(BuildContext context) => SettingsRowModel(
    id: SettingsItemIds.galleryIndex,
    title: context.l10n.galleryIndex,
    tile: const GalleryIndexTile(),
  );

  SettingsRowModel _navigationRow({
    required String id,
    required String title,
    required Widget leading,
    required VoidCallback onTap,
    bool hasChevron = true,
  }) => SettingsRowModel(
    id: id,
    title: title,
    leading: leading,
    tile: ListTile(
      title: Text(title),
      leading: leading,
      trailing: hasChevron ? settingsNavTrailing(context) : null,
      onTap: onTap,
    ),
  );

  Widget _buildProFooterTile(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final String dateStr = _proNextRenewalDate != null
        ? DateFormatters.dayMonthAndYearFormat(locale).format(_proNextRenewalDate!)
        : '—';
    final String priceStr = _proPriceString ?? '—';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      child: Text(
        context.l10n.proUserFooter(priceStr, dateStr),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
      ),
    );
  }

  void _showLanguagePicker() {
    Navigator.of(context).push(SwipeablePageRoute(builder: (context) => const LanguagePickerScreen()));
  }

  Future<void> _openEmailFeedbackForm() async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: KeklistConstants.feedbackEmail,
      query: 'subject=Feedback about keklist',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openSourceCode() async {
    final Uri uri = Uri.parse(KeklistConstants.sourceCodeURL);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openSuggestFeature() async {
    final Uri uri = Uri.parse(KeklistConstants.featureSuggestionsURL);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final Uri uri = Uri.parse(KeklistConstants.privacyURL);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openTermsOfUse() async {
    final Uri uri = Uri.parse(KeklistConstants.termsOfUseURL);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openAppNews() async {
    final Uri uri = Uri.parse(KeklistConstants.newsTelegramChannelURL);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openPaywall() async {
    final purchased = await PaywallBottomSheet.show(context);
    if (purchased) sendEventToBloc<MembershipBloc>(const MembershipRefreshEvent());
  }

  void _showAppearanceSettings() {
    Navigator.of(
      context,
    ).push<void>(SwipeablePageRoute<void>(builder: (BuildContext context) => const AppearanceSettingsScreen()));
  }

  // void _switchShowTitles(bool value) {
  //   sendEventToBloc<SettingsBloc>(SettingsUpdateShouldShowTitlesMode(value: value));
  // }

  void _showWhatsNew() {
    Navigator.of(context).push<void>(
      SwipeablePageRoute<void>(
        builder: (BuildContext context) =>
            WebPageScreen(title: context.l10n.whatsNew, initialUri: Uri.parse(KeklistConstants.whatsNewURL)),
      ),
    );
  }

  void _showTabsSettings() {
    Navigator.of(
      context,
    ).push<void>(SwipeablePageRoute<void>(builder: (BuildContext context) => const TabsSettingsScreen()));
  }

  void _showDebugMenu() {
    Navigator.of(
      context,
    ).push<void>(SwipeablePageRoute<void>(builder: (BuildContext context) => const DebugMenuScreen()));
  }

  void _handleAppBarTap() {
    if (_isDebugMenuVisible) return; // Already visible, no need to count

    setState(() {
      _appBarTapCount++;
    });

    if (_appBarTapCount >= 10) {
      sendEventToBloc<SettingsBloc>(const SettingsEnableDebugMenu());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Debug menu enabled'), duration: Duration(seconds: 2)));

      setState(() {
        _appBarTapCount = 0;
      });
    }
  }

  Future<void> _clearCache() async {
    final OkCancelResult result = await showOkCancelAlertDialog(
      context: context,
      title: context.l10n.areYouSure,
      message: context.l10n.clearOfflineDataWarning,
      cancelLabel: context.l10n.cancel,
      okLabel: context.l10n.clearCache,
      isDestructiveAction: true,
    );
    switch (result) {
      case OkCancelResult.ok:
        sendEventToBloc<MindBloc>(MindClearCache());
        break;
      case OkCancelResult.cancel:
        break;
    }
  }

  Future<void> _handleExport() async {
    // Calculate export metadata
    final mindBloc = context.read<MindBloc>();
    final mindState = mindBloc.state;

    final minds = switch (mindState) {
      MindList list => list.values,
      MindSearching searching => searching.allValues,
      _ => <Mind>[],
    };

    final mindsCount = minds.length;

    // Count unique audio files
    final audioFiles = <String>{};
    for (final mind in minds) {
      final noteContent = MindNoteContent.parse(mind.note);
      audioFiles.addAll(noteContent.mediaFilePaths);
    }
    final audioFilesCount = audioFiles.length;

    final emotionState = context.read<EmotionBloc>().state;
    final emotionsCount = emotionState is EmotionsList ? emotionState.emotions.length : 0;

    // Show password input bottom sheet with metadata
    final password = await PasswordInputBottomSheet.show(
      context: context,
      title: context.l10n.exportPassword,
      isOptional: true,
      mindsCount: mindsCount,
      audioFilesCount: audioFilesCount,
      emotionsCount: emotionsCount,
    );

    if (password == null) return; // User cancelled

    // On Android, show action selection bottom sheet
    SettingsExportAction action = SettingsExportAction.share;
    if (DeviceUtils.safeGetPlatform() == SupportedPlatform.android) {
      if (!mounted) return;

      SettingsExportAction? selectedAction;

      await KekSheet.show<void>(
        context: context,
        builder: (context) => ActionsScreen(
          actions: [
            (
              ActionModel.custom(title: context.l10n.saveToFiles, icon: const Icon(Icons.save)),
              () => selectedAction = SettingsExportAction.saveToFiles,
            ),
            (
              ActionModel.custom(title: context.l10n.share, icon: const Icon(Icons.share)),
              () => selectedAction = SettingsExportAction.share,
            ),
          ],
        ),
      );

      if (selectedAction == null) return; // User cancelled
      action = selectedAction!;
    }

    // Export as ZIP with optional password
    sendEventToBloc<SettingsBloc>(
      SettingsExport(type: SettingsExportType.zip, password: password.isEmpty ? null : password, action: action),
    );
  }

  File? _lastImportFile;

  Future<void> _handleImport() async {
    // Show file picker for CSV and ZIP files
    final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['csv', 'zip']);

    if (result == null || result.files.isEmpty) return;

    final pickedFile = result.files.single;
    if (pickedFile.path == null) return;

    final file = File(pickedFile.path!);
    _lastImportFile = file;

    // Check if file is encrypted by examining magic bytes
    // ZIP files start with "PK" (0x50 0x4B), encrypted files don't
    bool needsPassword = false;
    try {
      final bytes = await file.readAsBytes();
      if (bytes.length > 2) {
        final isZip = bytes[0] == 0x50 && bytes[1] == 0x4B;
        needsPassword = !isZip && !pickedFile.name.endsWith('.csv');
      }
    } catch (e) {
      // If we can't read the file, assume no password needed
      needsPassword = false;
    }

    String? password;
    if (needsPassword) {
      if (!mounted) return;
      password = await PasswordInputBottomSheet.show(
        context: context,
        title: context.l10n.importPassword,
        isOptional: false,
      );

      if (password == null) return; // User cancelled
    }

    // Trigger import
    sendEventToBloc<SettingsBloc>(SettingsImport(file: file, password: password));
  }

  Future<void> _handleInvalidPasswordError() async {
    if (!mounted) return;
    final result = await showOkCancelAlertDialog(
      context: context,
      title: context.l10n.incorrectPassword,
      message: context.l10n.incorrectPasswordMessage,
      okLabel: context.l10n.retry,
      cancelLabel: context.l10n.cancel,
    );

    if (result == OkCancelResult.ok && _lastImportFile != null) {
      if (!mounted) return;
      final password = await PasswordInputBottomSheet.show(
        context: context,
        title: context.l10n.importPassword,
        isOptional: false,
      );

      if (password != null) {
        sendEventToBloc<SettingsBloc>(SettingsImport(file: _lastImportFile!, password: password));
      }
    }
  }

  void _showSuccessMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(child: Text(context.l10n.ok), onPressed: () => Navigator.of(context).pop())],
      ),
    );
  }

  void _showErrorMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(child: Text(context.l10n.ok), onPressed: () => Navigator.of(context).pop())],
      ),
    );
  }
}
