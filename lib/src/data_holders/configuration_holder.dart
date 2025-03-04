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

  SnaplyReporterMode? _mode;

  SnaplyReporterMode get mode {
    if (_mode == null) {
      throw Exception('Attempt to get mode when it is not enabled');
    }
    return _mode!;
  }

  void setMode(SnaplyReporterMode? mode) {
    if (isEnabled) {
      throw Exception('SnaplyReporterMode can be set only once');
    }
    _mode = mode ?? SharingFilesMode();
  }

  bool get isEnabled => _mode != null;

  final VisibilityNotifier visibility = VisibilityNotifier();

  bool get isVisible => visibility.value;
}

// True (visible) by default
class VisibilityNotifier extends ValueNotifier<bool> {
  VisibilityNotifier() : super(true);
}
