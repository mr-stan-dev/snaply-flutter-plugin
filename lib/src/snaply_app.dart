import 'package:flutter/material.dart';
import 'package:snaply/snaply.dart';
import 'package:snaply/src/data_holders/configuration_holder.dart';
import 'package:snaply/src/ui/theme/snaply_theme.dart';
import 'package:snaply/src/ui/widgets/root/snaply_root_widget.dart';

class SnaplyApp extends StatefulWidget {
  /// Creates a SnaplyApp widget.
  ///
  /// The [child] parameter must not be null and typically would be your
  /// application's root widget (usually MaterialApp or CupertinoApp).
  const SnaplyApp({
    required this.child,
    this.mode = const SharingFilesMode(),
    this.isVisible = true,
    super.key,
  });

  final SnaplyReporterMode mode;
  final bool isVisible;

  /// The application widget that Snaply will wrap.
  ///
  /// This widget and its subtree will be rendered normally, with Snaply's
  /// reporting interface rendered as an overlay when enabled.
  final Widget child;

  @override
  State<SnaplyApp> createState() => _SnaplyAppState();
}

class _SnaplyAppState extends State<SnaplyApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await ConfigurationHolder.instance.configure(widget.mode);
      SnaplyReporter.instance.setVisibility(isVisible: widget.isVisible);
      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Failed to init Snaply: $e');
    }
  }

  @override
  Widget build(BuildContext context) =>
      _isInitialized ? _childWithSnaplyOverlay() : widget.child;

  Widget _childWithSnaplyOverlay() {
    // Directionality widget is needed to ensure Stack works as expected
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          Theme(
            data: SnaplyTheme.defaultTheme,
            child: const SnaplyRootWidget(),
          ),
        ],
      ),
    );
  }
}
