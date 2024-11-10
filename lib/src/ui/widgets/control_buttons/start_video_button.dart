import 'package:flutter/material.dart';
import 'package:snaply/src/ui/state/snaply_state.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';
import 'package:snaply/src/ui/state/snaply_state_provider.dart';

class StartVideoButton extends StatelessWidget {
  const StartVideoButton({
    required this.videosTaken,
    super.key,
  });

  final int videosTaken;

  @override
  Widget build(BuildContext context) {
    final button = Container(
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: const CircleBorder(),
      ),
      child: IconButton(
        onPressed: () => context.act(StartVideoRecording()),
        icon: Icon(
          Icons.video_camera_back_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
    return videosTaken > 0
        ? Badge(
            label: Text('$videosTaken/${SnaplyState.maxVideosNumber}'),
            child: button,
          )
        : button;
  }
}
