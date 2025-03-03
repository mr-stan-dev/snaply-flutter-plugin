import 'dart:io';

import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/platform_interface/snaply_platform_interface.dart';

class MediaFilesManager {
  MediaFilesManager(this._platform);

  final SnaplyPlatformInterface _platform;

  Future<ScreenshotFile?> takeScreenshot(int index) async {
    final bytes = await _platform.takeScreenshot();
    if (bytes != null) {
      final snaplyDirPath = await _platform.getSnaplyDirectory();
      final filePath = ScreenshotFile.getPath(
        dirPath: snaplyDirPath,
        index: index,
      );
      final tempFile = File(filePath);
      await tempFile.writeAsBytes(bytes);
      return ScreenshotFile(
        filePath: filePath,
        createdAt: DateTime.timestamp(),
      );
    }
    return null;
  }

  Future<void> startVideoRecording({
    bool isMediaProjection = false,
  }) async {
    await _platform.startVideoRecording(
      isMediaProjection: isMediaProjection,
    );
  }

  Future<ScreenVideoFile> stopVideoRecording({
    DateTime? videoStartedAt,
  }) async {
    final path = await _platform.stopVideoRecording();
    return ScreenVideoFile(
      filePath: path,
      startedAt: videoStartedAt ?? DateTime.timestamp(),
      endedAt: DateTime.timestamp(),
    );
  }
}
