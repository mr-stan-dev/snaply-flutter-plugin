import 'package:snaply/src/data_holders/configuration_holder.dart';
import 'package:snaply/src/data_holders/custom_attributes_holder.dart';
import 'package:snaply/src/logger/snaply_logger.dart';
import 'package:snaply/src/snaply_reporter_impl.dart';

/// A reporter interface for managing bug reporting functionality.
///
/// Controls reporting behavior, custom attributes, and logging. Use [instance]
/// to access the singleton reporter.
///
/// Enable/disable at compile time:
/// ```sh
/// flutter run --dart-define=SNAPLY_ENABLED=true
/// ```
abstract interface class SnaplyReporter {
  /// Singleton instance of [SnaplyReporter].
  static final SnaplyReporter instance = SnaplyReporterImpl(
    configHolder: ConfigurationHolder.instance,
    attributesHolder: CustomAttributesHolder.instance,
    logger: SnaplyLogger.instance,
  );

  /// Whether the reporter is enabled. When disabled, all operations are no-ops.
  bool get isEnabled;
  set isEnabled(bool value);

  /// Controls report activation button visibility.
  ///
  /// No effect if report gathering or reviewing is in progress.
  void setVisibility(bool visibility);

  /// Sets custom attributes for bug reports.
  void setAttributes(Map<String, String> attributes);

  /// Adds a timestamped log message to the report.
  void log({required String message});
}
