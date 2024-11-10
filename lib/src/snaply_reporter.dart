import 'package:snaply/src/data_holders/configuration_holder.dart';
import 'package:snaply/src/data_holders/custom_attributes_holder.dart';
import 'package:snaply/src/logger/snaply_logger.dart';
import 'package:snaply/src/snaply_reporter_impl.dart';

/// A reporter interface for managing bug reporting functionality.
///
/// The [SnaplyReporter] provides methods to control the reporting behavior,
/// set custom attributes, and add log messages. It is designed to be used
/// as a singleton through the [instance] getter.
///
/// The reporter can be enabled/disabled at compile time using the
/// `SNAPLY_ENABLED` environment variable:
/// ```sh
/// flutter run --dart-define=SNAPLY_ENABLED=true
/// ```
abstract interface class SnaplyReporter {
  /// Whether the reporter is enabled.
  ///
  /// This is determined at compile time using the `SNAPLY_ENABLED` environment
  /// variable. Defaults to `false` if not specified.
  static const bool isEnabled =
      bool.fromEnvironment("SNAPLY_ENABLED", defaultValue: false);

  /// The singleton instance of [SnaplyReporter].
  ///
  /// This instance is initialized with the default implementation and
  /// configuration. All reporting operations should be performed through
  /// this instance.
  static final SnaplyReporter instance = SnaplyReporterImpl(
    isEnabled: isEnabled,
    configHolder: ConfigurationHolder.instance,
    attributesHolder: CustomAttributesHolder.instance,
    logger: SnaplyLogger.instance,
  );

  /// Sets the visibility state of the reporter.
  ///
  /// When [visibility] is `true`, the reporter button will be visible to the user
  /// and can capture screenshots and screen recordings. When `false`, the
  /// reporter button will be hidden.
  ///
  /// Note: this has no effect if the reporter is in report gathering state
  /// or in report reviewing state already.
  void setVisibility(bool visibility);

  /// Sets custom attributes to be included in bug reports.
  ///
  /// The [attributes] map can contain any string key-value pairs that should
  /// be attached to bug reports. These attributes can be used to provide
  /// additional context about the user, device, or application state.
  ///
  void setAttributes(Map<String, String> attributes);

  /// Adds a log message to the reporter.
  ///
  /// The [message] will be timestamped and stored with the bug report.
  /// This can be used to track user actions, state changes, or any other
  /// relevant information that might help in debugging.
  ///
  void log({required String message});
}
