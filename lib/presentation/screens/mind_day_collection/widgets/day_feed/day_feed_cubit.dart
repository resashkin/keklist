import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_layout.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_media_loader.dart';

enum DayFeedMediaIssue { photoAccessDenied, folderNotChosen }

final class DayFeedState {
  final List<DayFeedItem> items;
  final bool isMediaLoading;
  final DayFeedMediaIssue? mediaIssue;

  const DayFeedState({required this.items, required this.isMediaLoading, this.mediaIssue});
}

final class DayFeedCubit extends Cubit<DayFeedState> {
  List<DayFeedItem> _minds = const [];
  List<DayFeedItem> _media = const [];
  bool _isMediaLoading = true;
  DayFeedMediaIssue? _mediaIssue;
  int _mediaRequestId = 0;

  DayFeedCubit() : super(const DayFeedState(items: [], isMediaLoading: true));

  void setMinds({required int dayIndex, required Iterable<Mind> allMinds}) {
    _minds = DayFeedLayout.mindItemsForDay(dayIndex: dayIndex, allMinds: allMinds);
    _emit();
  }

  Future<void> loadMedia({
    required int dayIndex,
    required String? folderPath,
    required bool isFolderRecursive,
    bool requestPhotoAccess = false,
  }) async {
    final int requestId = ++_mediaRequestId;
    _media = const [];
    _mediaIssue = null;
    _isMediaLoading = true;
    _emit();

    final (List<DayFeedItem> media, DayFeedMediaIssue? issue) = Platform.isAndroid
        ? await _loadFolderMedia(dayIndex, folderPath, isFolderRecursive)
        : await _loadPhotoMedia(dayIndex, requestPhotoAccess);

    if (requestId != _mediaRequestId || isClosed) return;
    _media = media;
    _mediaIssue = issue;
    _isMediaLoading = false;
    _emit();
  }

  Future<(List<DayFeedItem>, DayFeedMediaIssue?)> _loadPhotoMedia(int dayIndex, bool requestAccess) async {
    final bool hasAccess = await DayMediaLoader.hasPhotoAccess(requestIfNeeded: requestAccess);
    if (!hasAccess) return (const <DayFeedItem>[], DayFeedMediaIssue.photoAccessDenied);
    return (await DayMediaLoader.loadPhotoAssets(dayIndex), null);
  }

  Future<(List<DayFeedItem>, DayFeedMediaIssue?)> _loadFolderMedia(
    int dayIndex,
    String? folderPath,
    bool recursive,
  ) async {
    if (folderPath == null) return (const <DayFeedItem>[], DayFeedMediaIssue.folderNotChosen);
    return (await DayMediaLoader.loadFolderMedia(dayIndex, folderPath, recursive: recursive), null);
  }

  void _emit() {
    if (isClosed) return;
    emit(
      DayFeedState(
        items: DayFeedLayout.merge(minds: _minds, media: _media),
        isMediaLoading: _isMediaLoading,
        mediaIssue: _mediaIssue,
      ),
    );
  }
}
