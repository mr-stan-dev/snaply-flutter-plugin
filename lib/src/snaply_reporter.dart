import 'package:snaply/src/data_holders/configuration_holder.dart';
import 'package:snaply/src/data_holders/custom_attributes_holder.dart';
import 'package:snaply/src/logger/snaply_logger.dart';
import 'package:snaply/src/snaply_reporter_impl.dart';
import 'package:snaply/src/snaply_reporter_mode.dart';

/// A reporter interface for managing bug reporting functionality.
///
/// The SnaplyReporter provides functionality for capturing and sharing
/// bug reports with screenshots, screen recordings, device information,
/// and logs. Access the singleton instance through [instance].
///
/// To enable/disable at compile time:
/// ```sh
/// flutter run --dart-define=SNAPLY_ENABLED=true
/// ```
///
/// Example usage:
/// ```dart
/// // Initialize with default mode
/// await SnaplyReporter.instance.init();
///
/// // Add custom attributes
/// SnaplyReporter.instance.setAttributes({
///   'user_id': '12345',
///   'app_version': '1.0.0',
/// });
///
/// // Add logs
/// SnaplyReporter.instance.log(message: 'User completed onboarding');
/// ```
abstract interface class SnaplyReporter {
  /// Singleton instance of [SnaplyReporter].
  static final SnaplyReporter instance = SnaplyReporterImpl(
    configHolder: ConfigurationHolder.instance,
    attributesHolder: CustomAttributesHolder.instance,
    logger: SnaplyLogger.instance,
  );

  /// Whether the reporter is enabled.
  ///
  /// When disabled, all operations become no-ops. This can be controlled
  /// at compile time using the SNAPLY_ENABLED flag.
  bool get isEnabled;

  /// Initializes the reporter with optional [mode].
  ///
  /// Call this before using any other reporter functionality.
  Future<void> init({SnaplyReporterMode? mode});

  /// Controls visibility of the report activation button.
  ///
  /// Has no effect if report gathering or reviewing is in progress.
  /// ```dart
  /// // Hide the report button
  /// SnaplyReporter.instance.setVisibility(isVisible: false);
  /// ```
  void setVisibility({required bool isVisible});

  /// Sets custom attributes to be included in bug reports.
  ///
  /// These attributes will be included alongside automatically collected
  /// device and system information.
  /// ```dart
  /// SnaplyReporter.instance.setAttributes({
  ///   'user_id': '12345',
  ///   'environment': 'production',
  /// });
  /// ```
  void setAttributes(Map<String, String> attributes);

  /// Adds a timestamped log message to the report.
  ///
  /// Use this to capture important events or state changes that may be
  /// relevant for debugging.
  /// ```dart
  /// SnaplyReporter.instance.log(message: 'Payment transaction completed');
  /// ```
  void log({required String message});
}
