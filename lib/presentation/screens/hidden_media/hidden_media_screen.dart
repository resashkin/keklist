import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/glass_app_bar.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_layout.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_tiles.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/folder_media_item.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photo_manager/photo_manager.dart';

/// Photos and videos hidden from keklist; a tap brings one back to the feeds.
final class HiddenMediaScreen extends StatefulWidget {
  const HiddenMediaScreen({super.key});

  @override
  State<HiddenMediaScreen> createState() => _HiddenMediaScreenState();
}

final class _HiddenMediaScreenState extends State<HiddenMediaScreen> {
  static const int _columnCount = 4;
  static const String _assetPrefix = 'asset_';
  static const String _filePrefix = 'file_';
  static const String _safPrefix = 'saf_';

  Set<String> _ids = const {};
  List<DayFeedItem>? _items;

  @override
  void initState() {
    super.initState();
    final SettingsState state = context.read<SettingsBloc>().state;
    _load(state is SettingsDataState ? state.settings.hiddenMediaIds : const {});
  }

  @override
  Widget build(BuildContext context) => BlocListener<SettingsBloc, SettingsState>(
    listener: (_, state) {
      if (state is SettingsDataState) _load(state.settings.hiddenMediaIds);
    },
    child: Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(centerTitle: true, title: Text(context.l10n.hiddenMedia)),
      body: _buildBody(context),
    ),
  );

  Widget _buildBody(BuildContext context) {
    final List<DayFeedItem>? items = _items;
    if (items == null) return const Center(child: CircularProgressIndicator.adaptive());
    final ThemeData theme = Theme.of(context);
    if (items.isEmpty) {
      return Center(
        child: Text(context.l10n.hiddenMediaEmpty, style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor)),
      );
    }
    final EdgeInsets padding = MediaQuery.paddingOf(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.0, padding.top + kToolbarHeight + 8.0, 16.0, 12.0),
          sliver: SliverToBoxAdapter(
            child: Text(
              context.l10n.hiddenMediaHint,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            DayFeedLayout.horizontalPadding,
            0.0,
            DayFeedLayout.horizontalPadding,
            padding.bottom + 16.0,
          ),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final double size =
                  (constraints.crossAxisExtent - DayFeedLayout.cellSpacing * (_columnCount - 1)) / _columnCount;
              return SliverGrid.count(
                crossAxisCount: _columnCount,
                mainAxisSpacing: DayFeedLayout.cellSpacing,
                crossAxisSpacing: DayFeedLayout.cellSpacing,
                children: [
                  for (final DayFeedItem item in items)
                    GestureDetector(
                      key: ValueKey(item.id),
                      onTap: () => _show(context, item.id),
                      child: DayFeedItemTile(item: item, isMindTextVisible: false, size: size),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _show(BuildContext context, String id) {
    final SettingsBloc settings = context.read<SettingsBloc>();
    settings.add(SettingsSetMediaHidden(ids: {id}, isHidden: false));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.mediaShownAgain),
          action: SnackBarAction(
            label: context.l10n.undo,
            onPressed: () => settings.add(SettingsSetMediaHidden(ids: {id}, isHidden: true)),
          ),
        ),
      );
  }

  Future<void> _load(Set<String> ids) async {
    if (_items != null && ids.length == _ids.length && ids.containsAll(_ids)) return;
    _ids = ids;
    final List<DayFeedItem> items = [for (final DayFeedItem? item in await Future.wait(ids.map(_itemOf))) ?item]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (mounted && identical(ids, _ids)) setState(() => _items = items);
  }

  /// Gone files and photos deleted since are left out.
  static Future<DayFeedItem?> _itemOf(String id) async {
    if (id.startsWith(_assetPrefix)) {
      final AssetEntity? asset = await AssetEntity.fromId(id.substring(_assetPrefix.length));
      return asset == null ? null : DayFeedAsset(asset);
    }
    if (id.startsWith(_filePrefix)) {
      final File file = File(id.substring(_filePrefix.length));
      if (!await file.exists()) return null;
      return DayFeedFolderMedia(item: FolderFileItem(file), timestamp: await file.lastModified());
    }
    if (id.startsWith(_safPrefix)) {
      return DayFeedFolderMedia(
        item: FolderSafItem(uri: Uri.parse(id.substring(_safPrefix.length))),
        timestamp: DateTime.fromMillisecondsSinceEpoch(0),
      );
    }
    return null;
  }
}
