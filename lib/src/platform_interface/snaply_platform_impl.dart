import 'package:flutter/services.dart';
import 'package:snaply/src/platform_interface/snaply_platform_interface.dart';

/// An implementation of [SnaplyPlatformInterface] that uses method channels.
class SnaplyPlatformImpl implements SnaplyPlatformInterface {
  const SnaplyPlatformImpl(this.methodChannel);

  static const String _startScreenRecordingMethod =
      'startScreenRecordingMethod';
  static const String _stopScreenRecordingMethod = 'stopScreenRecordingMethod';
  static const String _takeScreenshotMethod = 'takeScreenshotMethod';
  static const String _shareFilesMethod = 'shareFilesMethod';
  static const String _getSnaplyDirectoryMethod = 'getSnaplyDirectoryMethod';
  static const String _getDeviceInfoMethod = 'getDeviceInfoMethod';

  final MethodChannel methodChannel;

  @override
  Future<Uint8List?> takeScreenshot() async {
    try {
      return await methodChannel
          .invokeMethod<Uint8List?>(_takeScreenshotMethod);
    } on PlatformException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<void> startVideoRecording({bool isMediaProjection = false}) async {
    try {
      await methodChannel.invokeMethod<void>(
        _startScreenRecordingMethod,
        {'isMediaProjection': isMediaProjection},
      );
    } on PlatformException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<String> stopVideoRecording() async {
    try {
      final path =
          await methodChannel.invokeMethod<String?>(_stopScreenRecordingMethod);
      if (path == null) {
        throw Exception('$_stopScreenRecordingMethod returned null');
      }
      return path;
    } on PlatformException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<void> shareFiles(List<String> filePaths) async {
    try {
      final argsMap = {'filePaths': filePaths};
      return await methodChannel.invokeMethod<void>(_shareFilesMethod, argsMap);
    } on PlatformException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<String> getSnaplyDirectory() async {
    try {
      final directory =
          await methodChannel.invokeMethod<String?>(_getSnaplyDirectoryMethod);
      if (directory == null) {
        throw Exception('$_getSnaplyDirectoryMethod returned null');
      }
      return directory;
    } catch (e) {
      throw Exception('$_getSnaplyDirectoryMethod error: $e');
    }
  }

  @override
  Future<Map<String, Map<String, String>>> getDeviceInfo() async {
    try {
      final result = await methodChannel
          .invokeMethod<Map<dynamic, dynamic>?>(_getDeviceInfoMethod);

      if (result == null) {
        throw Exception('$_getDeviceInfoMethod returned null');
      }
      return result.map(
        (key, value) => MapEntry(
          key.toString(),
          (value as Map<Object?, Object?>).map(
            (k, v) => MapEntry(
              k.toString(),
              v?.toString() ?? 'N/A',
            ),
          ),
        ),
      );
    } on PlatformException catch (e) {
      throw Exception(e.message);
    }
  }
}
