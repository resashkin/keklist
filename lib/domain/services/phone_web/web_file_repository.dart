import 'dart:io';

import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/services/phone_web/phone_api.dart';

/// App files for the web version: "paths" are the phone's URLs for them, and nothing is written in the browser.
final class WebFileRepository extends AppFileRepository {
  const WebFileRepository();

  @override
  Future<String> resolveAbsolutePath(String relativePath) async => PhoneApi.fileUrl(relativePath);

  @override
  Future<AppFileHandle> createAudioFile({String extension = 'm4a'}) => throw UnsupportedError(_readOnly);

  @override
  Future<AppFileHandle> createVideoFile({required String extension}) => throw UnsupportedError(_readOnly);

  @override
  Future<String> saveAvatarImage(File source) => throw UnsupportedError(_readOnly);

  static const String _readOnly = "The web version doesn't store files";
}
