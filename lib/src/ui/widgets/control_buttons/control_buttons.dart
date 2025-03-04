import 'package:flutter/material.dart';
import 'package:snaply/src/ui/state/snaply_state.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';
import 'package:snaply/src/ui/state/snaply_state_provider.dart';
import 'package:snaply/src/ui/widgets/control_buttons/start_video_button.dart';
import 'package:snaply/src/ui/widgets/control_buttons/take_screenshot_button.dart';
import 'package:snaply/src/ui/widgets/control_buttons/video_in_progress_button.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({
    required this.state,
    super.key,
  });

  final SnaplyState state;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 2,
      shadowColor: Colors.black,
      borderRadius: BorderRadius.circular(16),
      child: Visibility(
        visible: state.controlsState != ControlsState.invisible,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: _getChild(context),
          ),
        ),
      ),
    );
  }

  Widget _getChild(BuildContext context) {
    switch (state.controlsState) {
      case ControlsState.idle:
        return _idleWidget(context);
      case ControlsState.active:
        return _activeControlsWidget(context);
      case ControlsState.recordingInProgress:
        return VideoInProgressButton(videoProgress: state.videoProgress);
      case ControlsState.invisible:
        return const SizedBox.shrink();
    }
  }

  Widget _activeControlsWidget(BuildContext context) {
    return Column(
      children: [
        StartVideoButton(
          videosTaken: state.videosTaken,
        ),
        const SizedBox(height: 8),
        TakeScreenshotButton(
          screenshotsTaken: state.screenshotsTaken,
        ),
        const SizedBox(height: 24),
        Container(
          decoration: ShapeDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: const CircleBorder(),
          ),
          child: IconButton(
            onPressed: () => context.act(
              state.hasData ? ReviewReport() : Deactivate(),
            ),
            icon: state.hasData
                ? Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.primary,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _idleWidget(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: const CircleBorder(),
      ),
      child: IconButton(
        onPressed: () => context.act(Activate()),
        icon: Icon(
          Icons.bug_report_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
