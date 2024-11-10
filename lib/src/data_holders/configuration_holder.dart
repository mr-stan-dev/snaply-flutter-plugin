import 'package:flutter/foundation.dart';

class ConfigurationHolder {
  ConfigurationHolder._();

  static final ConfigurationHolder _instance = ConfigurationHolder._();

  static ConfigurationHolder get instance => _instance;

  final VisibilityNotifier visibility = VisibilityNotifier();

  bool get isVisible => visibility.value;
}

class VisibilityNotifier extends ValueNotifier<bool> {
  VisibilityNotifier() : super(false);
}
