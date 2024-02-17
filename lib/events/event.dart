import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:raog_tver_meta/components/dialog_text_box_component.dart';
import 'package:raog_tver_meta/main.dart';
import 'package:raog_tver_meta/missions/mission.dart';
import 'package:raog_tver_meta/missions/mission_controller.dart';
import 'package:raog_tver_meta/player.dart';

enum EventType {
  girl,
  guy,
  chair,
  couch,
  drink,
  light,
  tv,
  gallery;

  const EventType();

  factory EventType.fromClass(String class_) {
    return switch (class_) {
      'Guy' => EventType.guy,
      'Girl' => EventType.girl,
      'Chair' => EventType.chair,
      'Couch' => EventType.couch,
      'Drink' => EventType.drink,
      'Light' => EventType.light,
      'TV' => EventType.tv,
      'Gallery' => EventType.gallery,
      _ => throw UnsupportedError(
          'factory EventType.fromClass(String class_): $class_ is not a valid class.'),
    };
  }
}

enum EventState {
  inactive,
  requesting,
  inProgress,
  finished,
}

mixin Event on PositionComponent {
  PositionComponent startButton();

  bool get hasButton;
}

class DrinkEvent extends PositionComponent
    with CollisionCallbacks, HasGameRef<RaogTverMeta>, Event {
  final MissionsController missionsController;

  DrinkEvent({
    required this.missionsController,
    super.size,
    super.position,
  });

  late final AudioPool _drinkPool;
  bool drinking = false;

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Player && !hasButton) {
      add(startButton()..position = size / 2);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is Player && hasButton) {
      removeWhere((component) => component is ButtonComponent);
    }
    super.onCollisionEnd(other);
  }

  @override
  FutureOr<void> onLoad() async {
    _drinkPool = await FlameAudio.createPool('DRINK.mp3', maxPlayers: 1);
    add(RectangleHitbox(isSolid: true));
    return super.onLoad();
  }

  @override
  PositionComponent startButton() {
    return ButtonComponent(
      onPressed: () {
        if (drinking) return;
        drinking = true;
        Future.delayed(const Duration(milliseconds: 600)).then(
          (value) => _drinkPool.start(),
        );
        missionsController.complete(Missions.drinkWater);
        gameRef.me.current = MyStates.drink;
        gameRef.joystick.position.add(Vector2(-1000, -1000));
        add(TimerComponent(
            period: 2,
            removeOnFinish: true,
            onTick: () {
              gameRef.me.current = MyStates.idleDown;
              gameRef.joystick.position.add(Vector2(1000, 1000));
              drinking = false;
            }));
      },
      button: TextComponent(
        text: 'Попить',
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 5,
            fontWeight: FontWeight.w600,
            background: Paint()
              ..color = Colors.black38
              ..style = PaintingStyle.fill,
          ),
        ),
      ),
    );
  }

  @override
  bool get hasButton => children.whereType<ButtonComponent>().isNotEmpty;
}

class TvEvent extends PositionComponent
    with HasGameRef<RaogTverMeta>, CollisionCallbacks, Event {
  TvEvent({super.size, super.position}) {
    debugMode = false;
  }

  late final AudioPool _talkingPool;

  @override
  bool get hasButton => children.whereType<ButtonComponent>().isNotEmpty;

  bool _talking = false;

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Player && !hasButton) {
      add(startButton()..position = size / 2);
    }
    if (other is Player && !_talking) {
      _talking = true;
      const text = 'Привет! Посмотри что тебя ждет на Альфа-курсе!';
      _talkingPool.start();
      addAll([
        DialogTextBoxComponent(
          text: text,
          size: size / 2,
          position: size / 3,
        ),
      ]);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (hasButton) removeWhere((component) => component is ButtonComponent);
    super.onCollisionEnd(other);
  }

  @override
  FutureOr<void> onLoad() async {
    _talkingPool = await FlameAudio.createPool(
      'talking1.mp3',
      maxPlayers: 1,
    );

    add(RectangleHitbox(isSolid: true));
    return super.onLoad();
  }

  @override
  PositionComponent startButton() {
    return ButtonComponent(
      onPressed: () {
        FlameAudio.play('TV ON.mp3');
        gameRef.overlays.add('tv');
        gameRef.bgm.pause();
      },
      button: TextComponent(
        text: 'Смотреть',
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 5,
            fontWeight: FontWeight.w600,
            background: Paint()
              ..color = Colors.black38
              ..style = PaintingStyle.fill,
          ),
        ),
      ),
    );
  }
}

class ChairEvent extends PositionComponent
    with CollisionCallbacks, HasGameRef<RaogTverMeta>, Event {
  final CustomProperties properties;

  ChairEvent({
    required this.properties,
    super.position,
    super.size,
  });

  @override
  bool get hasButton => children.whereType<ButtonComponent>().isNotEmpty;

  @override
  FutureOr<void> onLoad() async {
    add(RectangleHitbox(isSolid: true));
    add(TimerComponent(
        period: 0.5,
        repeat: true,
        onTick: () {
          final inArea = distance(gameRef.me) < 30;
          if (gameRef.dialogProceeding && hasButton) {
            removeWhere((component) => component is ButtonComponent);
          }
          if (gameRef.me.sitting && hasButton) {
            removeWhere((component) => component is ButtonComponent);
          }
          if (inArea &&
              !hasButton &&
              !gameRef.dialogProceeding &&
              !gameRef.me.sitting) {
            add(startButton()..position = size / 2);
          }
          if (!inArea && hasButton) {
            removeWhere((component) => component is ButtonComponent);
          }
        }));
    return super.onLoad();
  }

  @override
  PositionComponent startButton() {
    return ButtonComponent(
      onPressed: () {
        MyStates? newState;
        switch (properties.getValue<String>('direction')) {
          case 'left':
            newState = MyStates.sitLeft;
          case 'right':
            newState = MyStates.sitRight;
        }
        if (newState != null) {
          FlameAudio.play('SEATDOWN.mp3');
          gameRef.me.setCurrent(newState);
          gameRef.me.position = Vector2(center.x, center.y + size.y / 2);
        }
      },
      button: TextComponent(
        text: 'Сесть',
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 5,
            fontWeight: FontWeight.w600,
            background: Paint()
              ..color = Colors.black38
              ..style = PaintingStyle.fill,
          ),
        ),
      ),
    )..debugMode = false;
  }
}

class CouchEvent extends PositionComponent
    with CollisionCallbacks, HasGameRef<RaogTverMeta>, Event {
  final CustomProperties properties;

  CouchEvent({
    required this.properties,
    super.position,
    super.size,
  });

  @override
  bool get hasButton => children.whereType<ButtonComponent>().isNotEmpty;

  @override
  FutureOr<void> onLoad() async {
    add(RectangleHitbox(isSolid: true));
    return super.onLoad();
  }

  @override
  PositionComponent startButton() {
    return ButtonComponent(
      onPressed: () {
        MyStates? newState;
        switch (properties.getValue<String>('direction')) {
          case 'left':
            newState = MyStates.sitLeft;
          case 'right':
            newState = MyStates.sitRight;
        }
        if (newState != null) {
          FlameAudio.play('SEATDOWN.mp3');
          gameRef.me.current = newState;
          gameRef.me.position = center;
          removeWhere((component) => component is ButtonComponent);
        }
      },
      button: TextComponent(
        text: 'Сесть',
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 5,
            fontWeight: FontWeight.w600,
            background: Paint()
              ..color = Colors.black38
              ..style = PaintingStyle.fill,
          ),
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    final inArea = distance(gameRef.me) < 50;
    if (gameRef.me.sitting && hasButton) {
      removeWhere((component) => component is ButtonComponent);
    } else if (inArea && !hasButton && !gameRef.me.sitting) {
      add(startButton()..position = size / 2);
    } else if (hasButton && !inArea) {
      removeWhere((component) => component is ButtonComponent);
    }
    super.update(dt);
  }
}

class GalleryEvent extends PositionComponent
    with CollisionCallbacks, HasGameRef<RaogTverMeta>, Event {
  GalleryEvent({
    super.position,
    super.size,
  });

  @override
  bool get hasButton => children.whereType<ButtonComponent>().isNotEmpty;

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && !hasButton) {
      add(startButton()..position = size / 2);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is Player && hasButton) {
      removeWhere((component) => component is ButtonComponent);
    }
    super.onCollisionEnd(other);
  }

  @override
  FutureOr<void> onLoad() async {
    add(RectangleHitbox(isSolid: true));
    return super.onLoad();
  }

  @override
  PositionComponent startButton() {
    return ButtonComponent(
      onPressed: () {
        gameRef.overlays.add('gallery');
      },
      button: TextComponent(
        text: 'Смотреть',
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 5,
            fontWeight: FontWeight.w600,
            background: Paint()
              ..color = Colors.black38
              ..style = PaintingStyle.fill,
          ),
        ),
      ),
    );
  }
}
