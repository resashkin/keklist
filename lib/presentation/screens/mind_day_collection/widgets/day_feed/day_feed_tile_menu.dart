import 'dart:async';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/helpers/mind_text_edit.dart';
import 'package:keklist/presentation/core/widgets/text_edit_sheet.dart';
import 'package:keklist/presentation/screens/emotions/emotion_marking_sheet.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/folder_media_item.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:url_launcher/url_launcher.dart';

/// Long press on any tile: the system context menu (UIContextMenu with Liquid Glass on iOS, native menus elsewhere)
/// with the tile lifted as its preview. Minds: edit, emotions, share, delete; photos and videos: share, show in the
/// gallery, delete.
final class DayFeedTileMenu extends StatelessWidget {
  final DayFeedItem item;
  final Widget child;

  const DayFeedTileMenu({super.key, required this.item, required this.child});

  /// Fires after a photo or video was removed from the gallery, so screens showing it reload.
  static final StreamController<void> _mediaDeleted = StreamController<void>.broadcast();
  static Stream<void> get mediaDeleted => _mediaDeleted.stream;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return child;
    return ContextMenuWidget(
      menuProvider: (_) => Menu(children: _actions(context)),
      child: child,
    );
  }

  List<MenuElement> _actions(BuildContext context) => switch (item) {
    DayFeedMind(:final mind) => [
      _action(context.l10n.edit, 'pencil', Icons.edit_outlined, () => _editText(context, mind)),
      _action(
        context.l10n.emotions,
        'face.smiling',
        Icons.sentiment_satisfied_alt_outlined,
        () => _editEmotions(context, mind),
      ),
      _action(context.l10n.share, 'square.and.arrow.up', Icons.ios_share, () => _shareText(context, mind)),
      MenuSeparator(),
      _action(context.l10n.delete, 'trash', Icons.delete_outline, () => _deleteMind(context, mind), destructive: true),
    ],
    DayFeedAsset(:final asset) => [
      _action(context.l10n.share, 'square.and.arrow.up', Icons.ios_share, () => _shareAsset(context, asset)),
      _action(
        context.l10n.showInGallery,
        'photo.on.rectangle',
        Icons.photo_library_outlined,
        () => _showInGallery(asset),
      ),
      MenuSeparator(),
      _action(context.l10n.delete, 'trash', Icons.delete_outline, () => _deleteAsset(asset), destructive: true),
    ],
    DayFeedFolderMedia(item: FolderFileItem(:final file)) => [
      _action(context.l10n.share, 'square.and.arrow.up', Icons.ios_share, () => _shareFile(context, file)),
    ],
    DayFeedFolderMedia() => const [],
  };

  static MenuAction _action(
    String title,
    String sfSymbol,
    IconData icon,
    VoidCallback callback, {
    bool destructive = false,
  }) => MenuAction(
    title: title,
    image: defaultTargetPlatform == TargetPlatform.iOS ? MenuImage.system(sfSymbol) : MenuImage.icon(icon),
    attributes: MenuActionAttributes(destructive: destructive),
    callback: callback,
  );

  // Minds

  static Future<void> _editText(BuildContext context, Mind mind) async {
    final String? text = await TextEditSheet.show(context, initialText: mind.plainNote.trim());
    if (text == null || !context.mounted) return;
    context.read<MindBloc>().add(MindEdit(mind: mindWithText(mind, text)));
  }

  static void _editEmotions(BuildContext context, Mind mind) => EmotionMarkingSheet.show(
    context: context,
    initialSelectedIds: mind.emotionIds.toSet(),
    onSelectionChanged: (ids) =>
        context.read<MindBloc>().add(MindSetEmotions(mindId: mind.id, emotionIds: ids.toList())),
  );

  static Future<void> _shareText(BuildContext context, Mind mind) =>
      SharePlus.instance.share(ShareParams(text: mind.plainNote.trim(), sharePositionOrigin: _originOf(context)));

  static Future<void> _deleteMind(BuildContext context, Mind mind) async {
    final OkCancelResult result = await showOkCancelAlertDialog(
      context: context,
      title: context.l10n.areYouSure,
      okLabel: context.l10n.delete,
      isDestructiveAction: true,
    );
    if (result == OkCancelResult.ok && context.mounted) context.read<MindBloc>().add(MindDelete(mind: mind));
  }

  // Photos and videos

  static Future<void> _shareAsset(BuildContext context, AssetEntity asset) async {
    final Rect? origin = _originOf(context);
    final File? file = await asset.originFile;
    if (file == null) return;
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], sharePositionOrigin: origin));
  }

  static Future<void> _shareFile(BuildContext context, File file) =>
      SharePlus.instance.share(ShareParams(files: [XFile(file.path)], sharePositionOrigin: _originOf(context)));

  /// iOS can only open the Photos app, not a given photo; Android opens the photo itself.
  static Future<void> _showInGallery(AssetEntity asset) => launchUrl(
    defaultTargetPlatform == TargetPlatform.iOS
        ? Uri.parse('photos-redirect://')
        : Uri.parse('content://media/external/${asset.type == AssetType.video ? 'video' : 'images'}/media/${asset.id}'),
    mode: LaunchMode.externalApplication,
  );

  /// The system asks to confirm and keeps it in Recently Deleted.
  static Future<void> _deleteAsset(AssetEntity asset) async {
    final List<String> deleted = await PhotoManager.editor.deleteWithIds([asset.id]);
    if (deleted.isNotEmpty) _mediaDeleted.add(null);
  }

  /// Where the share sheet points on an iPad.
  static Rect? _originOf(BuildContext context) {
    final RenderObject? box = context.findRenderObject();
    return box is RenderBox && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null;
  }
}
