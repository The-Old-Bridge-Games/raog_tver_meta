import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:raog_tver_meta/missions/mission.dart';
import 'package:raog_tver_meta/missions/mission_controller.dart';

class GalleryScreen extends StatefulWidget {
  final FlameGame game;
  final MissionsController missionsController;

  const GalleryScreen({
    super.key,
    required this.game,
    required this.missionsController,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  static const borderColor = Color(0xff3A3A52);

  final _pageController = PageController(viewportFraction: 0.7);

  final imagePaths = [
    'assets/images/gallery/gallery1.jpg',
    'assets/images/gallery/gallery2.jpg',
    'assets/images/gallery/gallery3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/gallery_bg.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  FlameAudio.play('SLIDE.mp3');
                  if (page == 2) {
                    widget.missionsController.complete(Missions.lookGallery);
                  }
                },
                itemCount: imagePaths.length,
                itemBuilder: (context, index) {
                  final imagePath = imagePaths[index];
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRect(
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 10, color: borderColor)),
                              child: Image.asset(imagePath),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
          Positioned(
            left: 24,
            top: 24,
            child: ElevatedButton(
              onPressed: () => widget.game.overlays.remove('gallery'),
              child: const Text('Назад'),
            ),
          )
        ],
      ),
    );
  }
}
