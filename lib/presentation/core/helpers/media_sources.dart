import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

/// In the web version media paths are URLs served by the phone, elsewhere they are local files.
bool isRemoteMediaPath(String path) => path.startsWith('http://') || path.startsWith('https://');

VideoPlayerController videoControllerFor(String path) => isRemoteMediaPath(path)
    ? VideoPlayerController.networkUrl(Uri.parse(path))
    : VideoPlayerController.file(File(path));

Future<Duration?> setAudioSource(AudioPlayer player, String path) =>
    isRemoteMediaPath(path) ? player.setUrl(path) : player.setFilePath(path);

Widget imageFor(String path, {BoxFit? fit, double? width, double? height, ImageErrorWidgetBuilder? errorBuilder}) =>
    isRemoteMediaPath(path)
    ? Image.network(path, fit: fit, width: width, height: height, gaplessPlayback: true, errorBuilder: errorBuilder)
    : Image.file(File(path), fit: fit, width: width, height: height, gaplessPlayback: true, errorBuilder: errorBuilder);
