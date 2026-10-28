import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:material_ui/material_ui.dart';

extension StorySettingsWatch on BuildContext {
  /// Rebuilds the caller when the stories/viewer tweaks change.
  StorySettings watchStorySettings() => select<SettingsBloc, StorySettings>((bloc) {
    final SettingsState state = bloc.state;
    return state is SettingsDataState ? state.settings.story : const StorySettings();
  });
}
