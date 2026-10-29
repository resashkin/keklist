import 'package:in_app_review/in_app_review.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/analytics/analytics.dart';
import 'package:keklist/domain/services/phone_web/phone_web_mode.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';
import 'package:keklist/presentation/core/helpers/bloc_utils.dart';
import 'package:keklist/presentation/screens/whats_new/whats_new_release.dart';
import 'package:keklist/presentation/screens/whats_new/whats_new_sheet.dart';
import 'package:material_ui/material_ui.dart';

/// Shows [WhatsNewSheet] once per release and later asks for a store review, see `documentation/WHATS_NEW.md`.
mixin ReleasePrompts<W extends StatefulWidget> on State<W>, DisposeBag {
  KeklistSettings? _settings;
  bool _isWhatsNewChecked = false;
  bool _isReviewRequested = false;

  void startReleasePrompts() {
    if (kIsPhoneWeb) return;
    // The bloc starts with placeholder settings, so only states after this SettingsGet are the stored ones.
    subscribeToBloc<SettingsBloc>(
      onNewState: (state) {
        if (state is! SettingsDataState) return;
        _settings = state.settings;
        if (_isWhatsNewChecked) return;
        _isWhatsNewChecked = true;
        if (WhatsNewRelease.shouldShow(state.settings)) _showWhatsNew();
      },
    )?.disposed(by: this);
    sendEventToBloc<SettingsBloc>(SettingsGet());

    subscribeToBloc<MindBloc>(
      onNewState: (state) {
        if (state is MindList) _askForReviewIfDue(state);
      },
    )?.disposed(by: this);
  }

  void _showWhatsNew() {
    sendEventToBloc<SettingsBloc>(const SettingsMarkWhatsNewSeen(release: WhatsNewRelease.release));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) WhatsNewSheet.show(context);
    });
  }

  Future<void> _askForReviewIfDue(MindList state) async {
    final KeklistSettings? settings = _settings;
    if (settings == null || _isReviewRequested) return;
    if (!WhatsNewRelease.shouldAskForReview(settings: settings, minds: state.values, now: DateTime.now())) return;
    _isReviewRequested = true;
    sendEventToBloc<SettingsBloc>(const SettingsMarkReviewPrompted(release: WhatsNewRelease.release));
    if (!await InAppReview.instance.isAvailable()) return;
    Analytics.reviewPrompted(WhatsNewRelease.release);
    await InAppReview.instance.requestReview();
  }
}
