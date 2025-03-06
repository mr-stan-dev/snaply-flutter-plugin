import 'package:flutter/material.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';
import 'package:snaply/src/ui/state/snaply_state_provider.dart';

class VideoInProgressButton extends StatelessWidget {
  const VideoInProgressButton({
    required this.videoProgress,
    super.key,
  });

  final double videoProgress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.act(StopVideoRecording()),
      child: Stack(
        children: [
          CircularProgressIndicator(
            backgroundColor: Theme.of(context).colorScheme.surface,
            color: Theme.of(context).colorScheme.primary,
            value: videoProgress,
          ),
          Positioned.fill(
            child: Align(
              child: Icon(
                Icons.stop_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
