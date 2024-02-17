import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raog_tver_meta/events/dialog_event.dart';
import 'package:raog_tver_meta/events/event.dart';
import 'package:raog_tver_meta/missions/mission.dart';
import 'package:raog_tver_meta/missions/mission_controller.dart';
import 'package:raog_tver_meta/missions/mission_notification.dart';
import 'package:raog_tver_meta/obstacle.dart';
import 'package:raog_tver_meta/player.dart';
import 'package:raog_tver_meta/screens/gallery_screen.dart';
import 'package:raog_tver_meta/missions/missions_container.dart';
import 'package:raog_tver_meta/screens/tv_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. add photos ✅
// 2. fix player sprite ✅
// 3. add progress storing ✅
// 4. add app icon
// 5. deploy
// 6. write a post

late final SharedPreferences _prefs;

Map<Missions, bool> _parseJson(Map<String, dynamic> json) => {
      Missions.watchTV: json[Missions.watchTV.name] ?? false,
      Missions.lookGallery: json[Missions.lookGallery.name] ?? false,
      Missions.talkToEverybody: json[Missions.talkToEverybody.name] ?? false,
      Missions.drinkWater: json[Missions.drinkWater.name] ?? false,
    };

Future<Map<Missions, bool>?> _init() async {
  final prefs = await SharedPreferences.getInstance();
  _prefs = prefs;
  final missions = Map.fromEntries(
    Missions.values.map(
      (e) => MapEntry(e, false),
    ),
  );
  for (final mission in Missions.values) {
    final completed = prefs.getBool(mission.name);
    if (completed == true) {
      missions[mission] = true;
    }
  }
  return missions;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  material.runApp(material.MaterialApp(
    debugShowCheckedModeBanner: false,
    home: material.FutureBuilder(
        future: _init(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child:
                  material.Text(snapshot.error?.toString() ?? 'Error occurred'),
            );
          }
          if (snapshot.hasData) {
            final missions = snapshot.data ?? {};
            final missionsController = MissionsController(
              missions.isEmpty
                  ? Map.fromEntries(
                      Missions.values.map((e) => MapEntry(e, false)),
                      // Missions.values.map((e) {
                      //   if (Missions.values.indexOf(e) == 2) {
                      //     return MapEntry(e, false);
                      //   } else {
                      //     return MapEntry(e, true);
                      //   }
                      // }),
                    )
                  : missions,
              _prefs,
            );
            return material.Stack(
              children: [
                GameWidget(
                  game: RaogTverMeta(missionsController: missionsController),
                  overlayBuilderMap: {
                    'gallery': (context, FlameGame game) => GalleryScreen(
                          game: game,
                          missionsController: missionsController,
                        ),
                    'tv': (context, RaogTverMeta game) => TvScreen(game: game),
                    'missions': (context, RaogTverMeta game) =>
                        MissionsContainer(
                          controller: missionsController,
                        ),
                  },
                ),
                IgnorePointer(
                    child: MissionNotification(controller: missionsController)),
              ],
            );
          } else {
            return const Scaffold(
              body: material.Center(child: CircularProgressIndicator()),
            );
          }
        }),
  ));
}

class RaogTverMeta extends FlameGame with HasCollisionDetection {
  final MissionsController missionsController;

  RaogTverMeta({required this.missionsController});

  late final JoystickComponent joystick;
  late final Vector2 mapSize;
  late final Player me;

  late final AudioPlayer bgm;

  var _dialogProceeding = false;

  @override
  material.Color backgroundColor() => const material.Color(0xffAEB1C0);

  @override
  bool get debugMode => false;

  bool get dialogProceeding => _dialogProceeding;

  bool _joystickHidden = false;

  void hideJoystick() {
    if (!_joystickHidden) {
      _joystickHidden = true;
      joystick.position.add(Vector2(-1000, -1000));
    }
  }

  showJoystick() {
    if (_joystickHidden) {
      _joystickHidden = false;
      joystick.position.add(Vector2(1000, 1000));
    }
  }

  void proceedDialog(DialogEvent dialog) {
    if (_dialogProceeding) return;
    _dialogProceeding = true;
    hideJoystick();
    dialog.run(onComplete: () {
      _dialogProceeding = false;
      showJoystick();
      missionsController.complete(Missions.talkToEverybody);
    }, onStopped: () {
      _dialogProceeding = false;
      showJoystick();
    });
  }

  @override
  FutureOr<void> onLoad() async {
    bgm = await FlameAudio.loopLongAudio('SUCHI PEGA.mp3', volume: 0.3);
    const jBackgroundRadius = 20.0;
    const jKnobRadius = 7.0;
    const jPadding = 16.0;
    final bgAndWalls = await TiledComponent.load(
      'map.tmx',
      Vector2.all(16),
    )
      ..tileMap.getLayer('behind')?.visible = false
      ..tileMap.getLayer('front')?.visible = false
      ..tileMap.getLayer('npc')?.visible = false
      ..debugMode = debugMode;
    final front = await TiledComponent.load(
      'map.tmx',
      Vector2.all(16),
    )
      ..tileMap.getLayer('bg')?.visible = false
      ..tileMap.getLayer('behind')?.visible = false
      ..tileMap.getLayer('walls')?.visible = false
      ..tileMap.getLayer('npc')?.visible = false
      ..debugMode = debugMode;
    final behind = await TiledComponent.load(
      'map.tmx',
      Vector2.all(16),
    )
      ..tileMap.getLayer('bg')?.visible = false
      ..tileMap.getLayer('front')?.visible = false
      ..tileMap.getLayer('walls')?.visible = false
      ..tileMap.getLayer('npc')?.visible = false
      ..debugMode = debugMode;
    final npc = await TiledComponent.load(
      'map.tmx',
      Vector2.all(16),
    )
      ..tileMap.getLayer('bg')?.visible = false
      ..tileMap.getLayer('behind')?.visible = false
      ..tileMap.getLayer('front')?.visible = false
      ..tileMap.getLayer('walls')?.visible = false
      ..tileMap.getLayer('npc')?.visible = true
      ..debugMode = debugMode;
    mapSize = bgAndWalls.size;
    camera.viewport = FixedResolutionViewport(
      resolution: mapSize / 2,
    );

    camera.setBounds(
      Rectangle.fromCenter(
        center: mapSize / 2,
        size: mapSize * 2,
      ),
      considerViewport: true,
    );
    joystick = JoystickComponent(
        position: Vector2(jBackgroundRadius + jPadding,
            camera.visibleWorldRect.height - jBackgroundRadius - jPadding),
        background: CircleComponent(
          paint: material.Paint()
            ..color = material.Colors.blue.withOpacity(0.3),
          radius: jBackgroundRadius,
        ),
        knob: CircleComponent(
          paint: material.Paint()..color = material.Colors.blue,
          radius: jKnobRadius,
        ));
    camera.viewport.add(joystick);
    me = Player()..position = size / 2;

    world.addAll([bgAndWalls, behind, me, front, npc]);

    camera.follow(me);

    final obstacles = bgAndWalls.tileMap.getLayer<ObjectGroup>('obstacles_obj');
    for (final obj in obstacles!.objects) {
      world.add(Obstacle(
        size: Vector2(obj.width, obj.height),
        position: Vector2(obj.x, obj.y),
      )..debugMode = false);
    }

    overlays.add('missions');

    final events = bgAndWalls.tileMap.getLayer<ObjectGroup>('event_obj');
    for (final event in events!.objects) {
      switch (event.class_) {
        case 'TV':
          world.add(TvEvent(
            position: Vector2(event.x, event.y),
            size: Vector2(event.width, event.height),
          ));
        case 'Drink':
          world.add(DrinkEvent(
            missionsController: missionsController,
            position: Vector2(event.x, event.y),
            size: Vector2(event.width, event.height),
          ));
        case 'Chair':
          world.add(ChairEvent(
            properties: event.properties,
            position: Vector2(event.x, event.y),
            size: Vector2(event.width, event.height),
          ));
        case 'Couch':
          world.add(CouchEvent(
            properties: event.properties,
            position: Vector2(event.x, event.y),
            size: Vector2(event.width, event.height),
          ));
        case 'Guy':
          world.add(DialogEvent(
            table: event.properties.getValue<int>('table') ?? 0,
            index: event.properties.getValue<int>('index') ?? 1,
            isGuy: true,
            position: Vector2(event.x, event.y),
            size: Vector2(event.width, event.height),
          ));
        case 'Girl':
          world.add(DialogEvent(
            table: event.properties.getValue<int>('table') ?? 0,
            index: event.properties.getValue<int>('index') ?? 1,
            isGuy: false,
            position: Vector2(event.x, event.y),
            size: Vector2(event.width, event.height),
          ));
        case 'Gallery':
          world.add(GalleryEvent(
            position: Vector2(event.x, event.y),
            size: Vector2(event.width, event.height),
          )..debugMode = false);
      }
    }
    return super.onLoad();
  }
}

enum MyStates {
  idleRight,
  idleDown,
  idleLeft,
  idleUp,
  moveLeft,
  moveRight,
  moveUp,
  moveDown,
  sitRight,
  sitLeft,
  drink,
}
