import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snaply/src/ui/state/info_event.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';
import 'package:snaply/src/ui/state/snaply_state_provider.dart';
import 'package:snaply/src/ui/widgets/snackbar/snackbar_builder.dart';

class SnackbarRootLayout extends StatefulWidget {
  const SnackbarRootLayout(
    this.uiEventsStream, {
    super.key,
  });

  final Stream<InfoEvent> uiEventsStream;

  @override
  State<SnackbarRootLayout> createState() => _SnackbarRootLayoutState();
}

class _SnackbarRootLayoutState extends State<SnackbarRootLayout>
    with TickerProviderStateMixin {
  StreamSubscription<InfoEvent>? _uiEventsSubscription;

  Timer? fadeOutTimer;

  Widget _snackbarWidget = const SizedBox.shrink();

  bool _isVisible = false;

  late final _opacityController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  late final _slideAnimationOffset = Tween<Offset>(
    begin: const Offset(0, 0.2),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      curve: Curves.decelerate,
      parent: _opacityController,
    ),
  );

  @override
  void initState() {
    super.initState();
    _uiEventsSubscription = widget.uiEventsStream.listen(_handleEvent);
    _opacityController.addStatusListener(_handleAnimationStatus);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    final completed = status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed;
    setState(() {
      if (completed) {
        _isVisible = _opacityController.value == 1.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () => context.act(ClearInfoWidgets()),
                child: FadeTransition(
                  opacity: _opacityController,
                  child: SlideTransition(
                    position: _slideAnimationOffset,
                    child: Visibility(
                      visible: _isVisible,
                      child: _snackbarWidget,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleEvent(InfoEvent infoEvent) {
    if (infoEvent is ClearAllWidgets) {
      _hideSnackbarWidget();
    } else {
      _showSnackbarWidget(infoEvent);
      if (infoEvent.autoHideDelay != null) {
        _hideAfterDelay(infoEvent.autoHideDelay!);
      }
    }
  }

  void _showSnackbarWidget(InfoEvent infoEvent) {
    setState(() {
      _snackbarWidget = SnackbarWidgetBuilder.build(infoEvent);
      _isVisible = true;
    });
    _opacityController.forward();
  }

  void _hideAfterDelay(Duration delay) {
    fadeOutTimer = Timer(delay, _hideSnackbarWidget);
  }

  void _hideSnackbarWidget() {
    _opacityController.reverse();
  }

  @override
  void dispose() {
    _uiEventsSubscription?.cancel();
    _uiEventsSubscription = null;
    _opacityController
      ..removeStatusListener(_handleAnimationStatus)
      ..dispose();
    fadeOutTimer?.cancel();
    super.dispose();
  }
}
