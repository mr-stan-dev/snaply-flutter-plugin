import 'dart:typed_data';

import 'package:snaply/src/platform_interface/snaply_platform_interface.dart';

class MediaFilesManager {
  MediaFilesManager(this._platform);

  final SnaplyPlatformInterface _platform;

  Future<Uint8List?> takeScreenshot() async {
    return await _platform.takeScreenshot();
  }

  Future<void> startVideoRecording() async {
    await _platform.startVideoRecording();
  }

  Future<String> stopVideoRecording() async {
    return await _platform.stopVideoRecording();
  }
}
