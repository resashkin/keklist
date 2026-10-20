import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/core/helpers/platform_utils.dart';
import 'package:keklist/presentation/core/widgets/bool_widget.dart';
import 'package:keklist/presentation/core/widgets/round_video/media_recording.dart';

final class MindCreatorBottomBar extends StatefulWidget {
  final Mind? editableMind;
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final String doneTitle;
  final String placeholder;
  final VoidCallback onTapCancelEdit;
  final Function(CreateMindData) onDone;
  final VoidCallback? onRecordAudio;
  final VoidCallback? onRecordVideo;

  const MindCreatorBottomBar({
    super.key,
    required this.textEditingController,
    required this.focusNode,
    required this.doneTitle,
    required this.onDone,
    required this.placeholder,
    this.editableMind,
    required this.onTapCancelEdit,
    required this.onRecordAudio,
    required this.onRecordVideo,
  });

  @override
  State<MindCreatorBottomBar> createState() => _MindCreatorBottomBarState();
}

final class _MindCreatorBottomBarState extends State<MindCreatorBottomBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            const _HorizontalSeparator(),
            if (widget.editableMind != null) ...[
              _EditableMindInfoWidget(
                editableMind: widget.editableMind!,
                onTapCancelEdit: widget.onTapCancelEdit,
              ),
              const _HorizontalSeparator(),
            ],
            const SizedBox(height: 8.0),
            _TextFieldWidget(
              placeholder: widget.placeholder,
              focusNode: widget.focusNode,
              textEditingController: widget.textEditingController,
              doneTitle: widget.doneTitle.toUpperCase(),
              onDone: () {
                widget.onDone(CreateMindData(text: widget.textEditingController.text));
              },
              onRecordAudio: widget.onRecordAudio,
              onRecordVideo: widget.onRecordVideo,
            ),
            const SizedBox(height: 4.0),
          ],
        ),
      ),
    );
  }
}

final class _EditableMindInfoWidget extends StatelessWidget {
  final Mind editableMind;
  final Function() onTapCancelEdit;

  const _EditableMindInfoWidget({required this.editableMind, required this.onTapCancelEdit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Padding(padding: EdgeInsets.all(10.0), child: Icon(Icons.edit)),
        Container(color: Theme.of(context).disabledColor, height: 38.0, width: 0.3),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(editableMind.note.replaceAll('\n', ' '), overflow: TextOverflow.ellipsis, maxLines: 1),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: onTapCancelEdit),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final class _HorizontalSeparator extends StatelessWidget {
  const _HorizontalSeparator();

  @override
  Widget build(BuildContext context) {
    return Container(color: Theme.of(context).disabledColor, height: 0.3);
  }
}

final class _TextFieldWidget extends StatelessWidget {
  const _TextFieldWidget({
    required this.placeholder,
    required this.focusNode,
    required this.textEditingController,
    required this.doneTitle,
    required this.onDone,
    required this.onRecordAudio,
    required this.onRecordVideo,
  });

  final FocusNode focusNode;
  final TextEditingController textEditingController;
  final String placeholder;
  final String doneTitle;
  final Function() onDone;
  final VoidCallback? onRecordAudio;
  final VoidCallback? onRecordVideo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8.0),
        Flexible(
          flex: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.2),
            child: TextField(
              focusNode: focusNode,
              keyboardType: TextInputType.multiline,
              maxLines: () {
                if (MediaQuery.of(context).orientation != Orientation.landscape && DeviceUtils.isPhone(context)) {
                  return null;
                } else {
                  return 1;
                }
              }(),
              textCapitalization: TextCapitalization.sentences,
              controller: textEditingController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(12.0),
                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                hintText: placeholder,
                suffixIcon: TextButton(
                    style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      foregroundColor: WidgetStateProperty.all(Colors.blueAccent),
                    ),
                    onPressed: onDone,
                    child: Text(doneTitle, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
              ),
            ),
          ),
        ),
        BoolWidget(
          condition: onRecordAudio != null && onRecordVideo != null,
          trueChild: MediaRecordToggleButton(
            onRecordAudio: () => onRecordAudio?.call(),
            onRecordVideo: () => onRecordVideo?.call(),
          ).animate().fade(),
          falseChild: Gap(0),
        ),
        const SizedBox(width: 8.0),
      ],
    );
  }
}

final class CreateMindData {
  final String text;

  const CreateMindData({required this.text});
}
