import 'package:flutter/material.dart';
import 'package:snaply/snaply.dart';
import 'package:snaply/src/ui/theme/snaply_theme.dart';
import 'package:snaply/src/ui/widgets/root/snaply_root_widget.dart';

/// A widget that provides bug reporting functionality by wrapping your app.
///
/// The [SnaplyApp] widget sets up the necessary environment for the bug reporting
/// interface.
///
/// When [SnaplyReporter.isEnabled] is false, this widget simply returns the child
/// without adding any overhead.
///
/// Example usage:
/// ```dart
/// void main() {
///   runApp(
///     SnaplyApp(
///       child: MaterialApp(
///         home: MyHomePage(),
///       ),
///     ),
///   );
/// }
/// ```
///
/// The widget uses a lightweight approach by avoiding a full MaterialApp for the
/// overlay, making it more efficient and preventing theme conflicts with the main app.
class SnaplyApp extends StatelessWidget {
  /// Creates a SnaplyApp widget.
  ///
  /// The [child] parameter must not be null and typically would be your
  /// application's root widget (usually MaterialApp or CupertinoApp).
  const SnaplyApp({
    super.key,
    required this.child,
  });

  /// The application widget that Snaply will wrap.
  ///
  /// This widget and its subtree will be rendered normally, with Snaply's
  /// reporting interface rendered as an overlay when enabled.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // If disabled, simply return the child widget
    if (!SnaplyReporter.instance.isEnabled) {
      return child;
    }
    // Directionality widget is needed to ensure Stack works as expected
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          Theme(
            data: SnaplyTheme.defaultTheme,
            child: const SnaplyRootWidget(),
          ),
        ],
      ),
    );
  }
}
