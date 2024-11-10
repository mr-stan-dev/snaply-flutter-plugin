import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullViewVideo extends StatefulWidget {
  const FullViewVideo({
    required this.file,
    super.key,
  });

  final File file;

  @override
  State<FullViewVideo> createState() => _FullViewVideoState();
}

class _FullViewVideoState extends State<FullViewVideo> {
  late final _playerController = VideoPlayerController.file(widget.file);

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await _playerController.initialize();
    _playerController.play();
    _playerController.setLooping(true);
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? Column(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: _playerController.value.aspectRatio,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: VideoPlayer(_playerController),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              VideoProgressIndicator(
                _playerController,
                allowScrubbing: true,
                padding: const EdgeInsets.all(8),
                colors: VideoProgressColors(
                    playedColor: Theme.of(context).primaryColor),
              ),
            ],
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
