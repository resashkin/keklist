import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';
import 'package:material_ui/material_ui.dart';

enum MediaRemoval { hide, deleteFromGallery }

/// Asks how to remove a gallery photo or video: hide it from keklist only, or delete it from the gallery.
final class MediaRemoveSheet extends StatelessWidget {
  final bool isVideo;

  const MediaRemoveSheet({super.key, required this.isVideo});

  static Future<MediaRemoval?> show(BuildContext context, {required bool isVideo}) => KekSheet.show<MediaRemoval>(
    context: context,
    builder: (_) => MediaRemoveSheet(isVideo: isVideo),
  );

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return KekSheetScaffold(
      title: isVideo ? context.l10n.removeVideoTitle : context.l10n.removePhotoTitle,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10.0,
          children: [
            _Choice(
              icon: Icons.visibility_off_outlined,
              title: context.l10n.hideMedia,
              subtitle: context.l10n.hideMediaSubtitle,
              color: colors.onSurface,
              onTap: () => Navigator.of(context).pop(MediaRemoval.hide),
            ),
            _Choice(
              icon: Icons.delete_outline,
              title: context.l10n.deleteFromGallery,
              subtitle: context.l10n.deleteFromGallerySubtitle,
              color: colors.error,
              onTap: () => Navigator.of(context).pop(MediaRemoval.deleteFromGallery),
            ),
          ],
        ),
      ),
    );
  }
}

final class _Choice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _Choice({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            spacing: 14.0,
            children: [
              Icon(icon, color: color),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2.0,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
                    ),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
