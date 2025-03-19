import 'package:flutter/foundation.dart';
import 'package:snaply/src/snaply_reporter_mode.dart';

class ConfigurationHolder {
  ConfigurationHolder._();

  static final ConfigurationHolder _instance = ConfigurationHolder._();

  static ConfigurationHolder get instance => _instance;

  static const String _envConfig = String.fromEnvironment('SNAPLY_CONFIG');

  static final List<String> _configValues = _envConfig.split(';');

  bool get useMediaProjection =>
      _configValues.contains('useAndroidMediaProjection');

  final VisibilityNotifier visibility = VisibilityNotifier();

  bool get isVisible => visibility.value;

  bool _isInitialized = false;
  late final SnaplyReporterMode mode;

  Future<void> Function()? onReportReview;

  bool get isInitialized => _isInitialized;

  Future<void> configure(SnaplyReporterMode mode) async {
    this.mode = mode;
    _isInitialized = true;
  }
}

// True (visible) by default
class VisibilityNotifier extends ValueNotifier<bool> {
  VisibilityNotifier() : super(true);
}
