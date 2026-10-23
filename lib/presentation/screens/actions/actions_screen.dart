import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:keklist/presentation/screens/actions/action_model.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';

final class ActionsScreen extends StatelessWidget {
  final List<(ActionModel, FutureOr<void> Function())> actions;
  final String? title;

  const ActionsScreen({super.key, required this.actions, this.title});

  @override
  Widget build(BuildContext context) {
    return KekSheetScaffold(
      title: title,
      child: SingleChildScrollView(
        child: Wrap(
          children: actions
              .map(
                (action) => ListTile(
                  leading: action.$1.icon,
                  title: Text(action.$1.title, style: const TextStyle(fontSize: 16.0)),
                  onTap: () {
                    Navigator.of(context).pop();
                    action.$2.call();
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
