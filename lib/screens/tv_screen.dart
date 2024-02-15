import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:raog_tver_meta/main.dart';
import 'package:raog_tver_meta/missions/mission.dart';
import 'package:video_player/video_player.dart';

class TvScreen extends StatefulWidget {
  final RaogTverMeta game;

  const TvScreen({required this.game, super.key});

  @override
  State<TvScreen> createState() => _TvScreenState();
}

class _TvScreenState extends State<TvScreen> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/videos/tv.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        _controller.play();
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_controller.value.isInitialized)
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        else
          Container(),
        Align(
          alignment: const Alignment(0.8, -0.8),
          child: ElevatedButton(
            onPressed: () {
              FlameAudio.play('TV OFF.mp3');
              _controller.pause();
              widget.game.overlays.remove('tv');
              // widget.game.bgm.resume();
              widget.game.missionsController.complete(Missions.watchTV);
            },
            child: const Text('Закрыть'),
          ),
        ),
      ],
    );
  }
}
