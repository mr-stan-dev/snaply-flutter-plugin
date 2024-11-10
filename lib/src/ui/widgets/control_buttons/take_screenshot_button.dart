import 'package:flutter/material.dart';
import 'package:snaply/src/ui/state/snaply_state.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';
import 'package:snaply/src/ui/state/snaply_state_provider.dart';

class TakeScreenshotButton extends StatelessWidget {
  const TakeScreenshotButton({
    required this.screenshotsTaken,
    super.key,
  });

  final int screenshotsTaken;

  @override
  Widget build(BuildContext context) {
    final button = Container(
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: const CircleBorder(),
      ),
      child: IconButton(
        onPressed: () => context.act(TakeScreenshot()),
        icon: Icon(
          Icons.photo_camera_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
    return screenshotsTaken > 0
        ? Badge(
            label:
                Text('$screenshotsTaken/${SnaplyState.maxScreenshotsNumber}'),
            child: button,
          )
        : button;
  }
}
