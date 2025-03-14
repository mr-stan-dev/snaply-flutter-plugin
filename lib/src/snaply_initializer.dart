import 'package:snaply/src/snaply_reporter_mode.dart';

class SnaplyInitializer {
  SnaplyInitializer._();

  static final SnaplyInitializer _instance = SnaplyInitializer._();

  static SnaplyInitializer get instance => _instance;

  SnaplyReporterMode? _mode;

  SnaplyReporterMode get mode {
    if (_mode == null) {
      throw Exception('Attempt to get mode when it is not initialized');
    }
    return _mode!;
  }

  Future<void> init(SnaplyReporterMode mode) async {
    _mode = mode;
  }

  bool get isInitialized => _mode != null;
}
