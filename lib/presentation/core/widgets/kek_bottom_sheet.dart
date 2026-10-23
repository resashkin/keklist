import 'package:material_ui/material_ui.dart';

/// Colors, corners, handle and title of every bottom sheet; [KekSheet] and [KekSheetScaffold] put them together.
abstract final class KekBottomSheetStyle {
  /// Top corner radius of the sheet container.
  static const double cornerRadius = 16.0;

  /// Sheet background color.
  static Color background(BuildContext context) => Theme.of(context).colorScheme.surface;

  static BorderRadius get topRadius => const BorderRadius.vertical(top: Radius.circular(cornerRadius));

  /// Box decoration for the sheet's outer container (surface + rounded top).
  static BoxDecoration decoration(BuildContext context) =>
      BoxDecoration(color: background(context), borderRadius: topRadius);

  /// Centered title style: bold [TextTheme.titleLarge].
  static TextStyle? titleStyle(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold);

  /// The bare 32×4 grab bar (no surrounding spacing) — use inside a custom
  /// draggable wrapper.
  static Widget handleBar(BuildContext context) => Container(
    width: 32,
    height: 4,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(2),
    ),
  );

  /// The standard centered drag handle with the etalon's spacing.
  static Widget handle(BuildContext context) => Center(
    child: Padding(padding: const EdgeInsets.only(top: 12, bottom: 8), child: handleBar(context)),
  );
}

/// The app's one bottom sheet, modelled on the emotions sheet: at most [maxWidth] wide and centered on large
/// screens, a grab handle, a header with an optional action, a centered title and a close button, and the
/// content's own height up to [maxHeightFactor] of the screen.
abstract final class KekSheet {
  static const double maxWidth = 640.0;
  static const double maxHeightFactor = 0.9;

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isDismissible = true,
  }) => showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: maxWidth),
    builder: builder,
  );
}

/// The body of a [KekSheet]: [child] is laid out under the header and may be a scrollable wrapped in [Flexible].
final class KekSheetScaffold extends StatelessWidget {
  final String? title;
  final Widget? leading;
  final Widget child;

  /// Whether the close button is shown; sheets that must not be skipped hide it.
  final bool showsClose;

  /// Fixed share of the screen height instead of the content's own height.
  final double? heightFactor;

  const KekSheetScaffold({
    super.key,
    this.title,
    this.leading,
    this.showsClose = true,
    this.heightFactor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final Widget body = Column(
      mainAxisSize: heightFactor == null ? MainAxisSize.min : MainAxisSize.max,
      children: [
        KekBottomSheetStyle.handle(context),
        if (title != null || leading != null || showsClose)
          KekSheetHeader(title: title, leading: leading, showsClose: showsClose),
        Flexible(child: child),
      ],
    );
    return Padding(
      // Text fields in a sheet stay above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * KekSheet.maxHeightFactor),
        child: Material(
          color: KekBottomSheetStyle.background(context),
          borderRadius: KekBottomSheetStyle.topRadius,
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: heightFactor == null ? body : SizedBox(height: screenHeight * heightFactor!, child: body),
          ),
        ),
      ),
    );
  }
}

/// Action on the left, title in the middle, close on the right — the same in every sheet.
final class KekSheetHeader extends StatelessWidget {
  final String? title;
  final Widget? leading;
  final bool showsClose;

  const KekSheetHeader({super.key, this.title, this.leading, this.showsClose = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.0,
      child: Stack(
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 76.0),
              child: Center(
                child: Text(
                  title!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KekBottomSheetStyle.titleStyle(context),
                ),
              ),
            ),
          if (leading != null) Align(alignment: Alignment.centerLeft, child: leading),
          if (showsClose)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ),
        ],
      ),
    );
  }
}
