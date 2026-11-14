import 'package:material_ui/material_ui.dart';

/// Focuses a text field only after the sheet, dialog or page holding it has finished sliding in.
///
/// With `autofocus: true` the keyboard animates in at the same time as the route, so every frame lays out the
/// route twice (its own animation plus the shrinking view insets) and the opening stutters. Waiting for the route
/// keeps the two animations apart. See `documentation/DEFERRED_AUTOFOCUS.md`.
final class DeferredAutofocus extends StatefulWidget {
  final Widget Function(BuildContext context, FocusNode focusNode) builder;

  const DeferredAutofocus({super.key, required this.builder});

  @override
  State<DeferredAutofocus> createState() => _DeferredAutofocusState();
}

final class _DeferredAutofocusState extends State<DeferredAutofocus> {
  final FocusNode _focusNode = FocusNode();
  Animation<double>? _routeAnimation;
  bool _isScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isScheduled) return;
    _isScheduled = true;
    final Animation<double>? animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.status == AnimationStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focus());
    } else {
      _routeAnimation = animation..addStatusListener(_onRouteStatus);
    }
  }

  void _onRouteStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    _routeAnimation = null;
    _focus();
  }

  void _focus() {
    if (mounted) _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _focusNode);
}
