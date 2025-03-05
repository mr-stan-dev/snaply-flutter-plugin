import 'dart:io';

import 'package:flutter/material.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_files/preview/delete_media_file_button.dart';
import 'package:video_player/video_player.dart';

class PreviewVideoFile extends StatefulWidget {
  const PreviewVideoFile({
    required this.file,
    super.key,
  });

  final ScreenVideoFile file;

  @override
  State<PreviewVideoFile> createState() => _PreviewVideoFileState();
}

class _PreviewVideoFileState extends State<PreviewVideoFile> {
  VideoPlayerController? _controller;
  bool _hasFrame = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final controller = VideoPlayerController.file(File(widget.file.filePath));
    try {
      await controller.initialize();
      final seekPosition = _shortestDuration(
        const Duration(milliseconds: 300),
        controller.value.duration,
      );
      await controller.seekTo(seekPosition);
      _controller = controller;
      if (mounted) setState(() => _hasFrame = true);
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasFrame && _controller != null) {
      final size = _controller!.value.size;
      final aspectRatio = size.width / size.height;
      final duration = _controller!.value.duration;
      final minutes = duration.inMinutes;
      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

      return Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: aspectRatio * 100,
                height: 100,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),
          // Dimming overlay
          Container(color: Colors.black.withOpacity(0.3)),
          const Center(
            child: Icon(
              Icons.play_circle_outline,
              size: 42,
              color: Colors.white,
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Text(
              '$minutes:$seconds',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: DeleteMediaFileButton(mediaFile: widget.file),
          ),
        ],
      );
    }

    if (_controller != null && !_hasFrame) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.video_camera_back_rounded,
          size: 32,
        ),
        SizedBox(height: 8),
        Text('Video file'),
      ],
    );
  }

  Duration _shortestDuration(Duration a, Duration b) =>
      a.compareTo(b) < 0 ? a : b;
}
