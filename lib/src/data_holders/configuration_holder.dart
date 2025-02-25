import 'package:flutter/foundation.dart';

class ConfigurationHolder {
  ConfigurationHolder._();

  static final ConfigurationHolder _instance = ConfigurationHolder._();

  static ConfigurationHolder get instance => _instance;

  static const String _envConfig =
      String.fromEnvironment("SNAPLY_CONFIG", defaultValue: '');

  static final List<String> _configValues = _envConfig.split(';');

  bool get useMediaProjection =>
      _configValues.contains('useAndroidMediaProjection');

  bool isEnabled = false;

  final VisibilityNotifier visibility = VisibilityNotifier();

  bool get isVisible => visibility.value;
}

// True (visible) by default
class VisibilityNotifier extends ValueNotifier<bool> {
  VisibilityNotifier() : super(true);
}
