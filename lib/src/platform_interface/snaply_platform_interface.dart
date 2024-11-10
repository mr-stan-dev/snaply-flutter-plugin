import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:snaply/src/platform_interface/snaply_platform_impl.dart';

abstract class SnaplyPlatformInterface extends PlatformInterface {
  /// Constructs a snaplyPlatform.
  SnaplyPlatformInterface() : super(token: _token);

  static final Object _token = Object();

  static SnaplyPlatformInterface _instance = const SnaplyPlatformImpl(
    MethodChannel('SnaplyMethodChannel'),
  );

  /// The default instance of [SnaplyPlatformInterface] to use.
  ///
  /// Defaults to [SnaplyPlatformImpl].
  static SnaplyPlatformInterface get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SnaplyPlatformInterface] when
  /// they register themselves.
  static set instance(SnaplyPlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Uint8List?> takeScreenshot() {
    throw UnimplementedError('takeScreenshot() has not been implemented.');
  }

  Future<void> startVideoRecording() {
    throw UnimplementedError('startVideoRecording() has not been implemented.');
  }

  Future<String> stopVideoRecording() {
    throw UnimplementedError('stopVideoRecording() has not been implemented.');
  }

  Future<void> shareFiles(List<String> filePaths) {
    throw UnimplementedError('shareFiles() has not been implemented.');
  }

  Future<String> getSnaplyDirectory() {
    throw UnimplementedError('getSnaplyDirectory() has not been implemented.');
  }

  Future<Map<String, Map<String, String>>> getDeviceInfo() {
    throw UnimplementedError('getDeviceInfo() has not been implemented.');
  }
}
