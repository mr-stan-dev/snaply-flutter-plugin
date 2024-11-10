import 'package:flutter/widgets.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';

class SnaplyStateProvider extends InheritedWidget {
  const SnaplyStateProvider({
    super.key,
    required this.onAction,
    required super.child,
  });

  final Function(SnaplyStateAction) onAction;

  static SnaplyStateProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SnaplyStateProvider>()!;
  }

  @override
  bool updateShouldNotify(SnaplyStateProvider oldWidget) => false;

  void act(SnaplyStateAction action) => onAction.call(action);
}

extension SnaplyReporterStateProviderX on BuildContext {
  void act(SnaplyStateAction action) =>
      SnaplyStateProvider.of(this).act(action);
}
