import 'package:keklist/domain/services/analytics/analytics.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/glass_capsule_button.dart';
import 'package:keklist/presentation/core/widgets/kek_bottom_sheet.dart';
import 'package:keklist/presentation/screens/whats_new/whats_new_release.dart';
import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

/// The slides of [WhatsNewRelease] in a tall sheet: swipe between them, Next and Start, ✕ or a swipe down closes.
final class WhatsNewSheet extends StatefulWidget {
  const WhatsNewSheet({super.key});

  static const double heightFactor = 0.9;

  static Future<void> show(BuildContext context) {
    Analytics.whatsNewShown(WhatsNewRelease.release);
    return KekSheet.show<void>(context: context, builder: (_) => const WhatsNewSheet());
  }

  @override
  State<WhatsNewSheet> createState() => _WhatsNewSheetState();
}

final class _WhatsNewSheetState extends State<WhatsNewSheet> {
  final PageController _pageController = PageController();
  int _page = 0;
  bool _isCompleted = false;

  @override
  void dispose() {
    Analytics.whatsNewClosed(WhatsNewRelease.release, isCompleted: _isCompleted, slide: _page + 1);
    _pageController.dispose();
    super.dispose();
  }

  void _next(int slideCount) {
    if (_page < slideCount - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
      return;
    }
    _isCompleted = true;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final List<WhatsNewSlide> slides = WhatsNewRelease.slides(context.l10n);
    final bool isLast = _page == slides.length - 1;
    return KekSheetScaffold(
      title: context.l10n.whatsNewTitle(WhatsNewRelease.release),
      heightFactor: WhatsNewSheet.heightFactor,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: slides.length,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (context, index) => _SlideView(slide: slides[index], isActive: index == _page),
            ),
          ),
          _PageDots(count: slides.length, current: _page),
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 12.0),
            child: GlassCapsuleButton(
              height: 48.0,
              isExpanded: true,
              onTap: () => _next(slides.length),
              child: Text(
                isLast ? context.l10n.whatsNewStart : context.l10n.whatsNewNext,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _SlideView extends StatelessWidget {
  final WhatsNewSlide slide;
  final bool isActive;

  const _SlideView({required this.slide, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: _SlideVideo(asset: slide.videoAsset, isActive: isActive),
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          if (slide.footnote case final String footnote) ...[
            const SizedBox(height: 12.0),
            Text(
              footnote,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A muted looping clip in a rounded phone frame; plays only while its slide is on screen.
final class _SlideVideo extends StatefulWidget {
  final String asset;
  final bool isActive;

  const _SlideVideo({required this.asset, required this.isActive});

  static const double placeholderAspectRatio = 1206 / 2622;

  @override
  State<_SlideVideo> createState() => _SlideVideoState();
}

final class _SlideVideoState extends State<_SlideVideo> {
  late final VideoPlayerController _controller = VideoPlayerController.asset(
    widget.asset,
    videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
  );
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _controller.setVolume(0.0);
    _controller.setLooping(true);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _isReady = true);
      _syncPlayback();
    }, onError: (_) {});
  }

  @override
  void didUpdateWidget(_SlideVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) _syncPlayback();
  }

  void _syncPlayback() {
    if (!_isReady) return;
    if (widget.isActive) {
      _controller.seekTo(Duration.zero);
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: _isReady ? _controller.value.aspectRatio : _SlideVideo.placeholderAspectRatio,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.0),
          border: Border.all(color: colors.outlineVariant, width: 1.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.0),
          child: _isReady ? VideoPlayer(_controller) : ColoredBox(color: colors.surfaceContainerHighest),
        ),
      ),
    );
  }
}

final class _PageDots extends StatelessWidget {
  final int count;
  final int current;

  const _PageDots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int index = 0; index < count; index++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: index == current ? 20.0 : 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                color: index == current ? colors.onSurface : colors.onSurface.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
        ],
      ),
    );
  }
}
