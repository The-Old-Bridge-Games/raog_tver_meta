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
    'assets/images/gallery/IMG_3701.heic',
    'assets/images/gallery/IMG_3697.heic',
    'assets/images/gallery/IMG_3698.heic',
    'assets/images/gallery/IMG_3699.heic',
    'assets/images/gallery/gallery2.jpg',
    'assets/images/gallery/IMG_2609.heic',
    'assets/images/gallery/IMG_3042.heic',
    'assets/images/gallery/IMG_3082.heic',
    'assets/images/gallery/IMG_3084.heic',
    'assets/images/gallery/IMG_6929.heic',
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
                  if (page == 9) {
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
                              child:
                                  IgnorePointer(child: Image.asset(imagePath)),
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
              child: const Text('Выйти'),
            ),
          )
        ],
      ),
    );
  }
}
