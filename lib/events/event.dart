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
  bool showButton = false;
  bool drinking = false;

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Player && !showButton) {
      showButton = true;
      add(startButton()..position = size / 2);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is Player && showButton) {
      showButton = false;
      removeWhere((component) => component is ButtonComponent);
    }
    super.onCollisionEnd(other);
  }

  @override
  FutureOr<void> onLoad() async {
    _drinkPool = await FlameAudio.createPool('DRINK.mp3', maxPlayers: 1);
    add(RectangleHitbox());
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
            fontSize: 4,
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

class TvEvent extends PositionComponent
    with HasGameRef<RaogTverMeta>, CollisionCallbacks, Event {
  TvEvent({super.size, super.position}) {
    debugMode = true;
  }

  late final AudioPool _talkingPool;

  bool _talking = false;
  bool _showButton = false;
  set showButton(bool show) {
    if (show == _showButton) return;
    _showButton = show;
    if (_showButton) {
      add(startButton()..position = size / 2);
    } else {
      removeWhere((component) => component is ButtonComponent);
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Player && !_showButton) {
      showButton = true;
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
    if (_showButton) showButton = false;
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
        // gameRef.bgm.pause();
      },
      button: TextComponent(
        text: 'Смотреть',
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 4,
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

  var showButton = false;

  @override
  FutureOr<void> onLoad() async {
    add(RectangleHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    final inArea = distance(gameRef.me) < 30;
    if (gameRef.dialogProceeding) {
      showButton = false;
      removeWhere((component) => component is ButtonComponent);
    }
    if (gameRef.me.sitting) {
      showButton = false;
      removeWhere((component) => component is ButtonComponent);
    } else if (inArea && !showButton && !gameRef.dialogProceeding) {
      showButton = true;
      add(startButton()..position = size / 2);
    }
    super.update(dt);
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
          gameRef.me.position = Vector2(center.x, center.y + size.y / 2);
        }
      },
      button: TextComponent(
        text: 'Сесть',
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 4,
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

class CouchEvent extends PositionComponent
    with CollisionCallbacks, HasGameRef<RaogTverMeta>, Event {
  final CustomProperties properties;

  CouchEvent({
    required this.properties,
    super.position,
    super.size,
  });

  var showButton = false;

  @override
  FutureOr<void> onLoad() async {
    add(RectangleHitbox());
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
            fontSize: 4,
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
    if (gameRef.me.sitting) {
      showButton = false;
      removeWhere((component) => component is ButtonComponent);
    } else if (inArea && !showButton) {
      showButton = true;
      add(startButton()..position = size / 2);
    } else if (showButton && !inArea) {
      showButton = false;
      removeWhere((component) => component is ButtonComponent);
    }
    super.update(dt);
  }
}

class EventComponent extends PositionComponent
    with HasGameRef<RaogTverMeta>, CollisionCallbacks {
  final EventType event;
  final CustomProperties properties;

  EventComponent({
    required this.event,
    required this.properties,
    super.size,
    super.position,
  }) {
    debugMode = false;
  }

  @override
  Paint get debugPaint => Paint()
    ..color = Colors.red.withOpacity(0.1)
    ..style = PaintingStyle.fill;

  late final ButtonComponent _requestingComponent;
  late final TextBoxComponent _inProgressComponent;
  late final TextBoxComponent _finishedComponent;

  List<PositionComponent> get allComponents => [
        _requestingComponent,
        _inProgressComponent,
        _finishedComponent,
      ];

  var _state = EventState.inactive;
  EventState get state => _state;

  set state(EventState newState) {
    _state = newState;
    switch (newState) {
      case EventState.requesting:
        if (!contains(_requestingComponent)) {
          add(_requestingComponent);
        }
      case EventState.inactive:
        for (final component in allComponents) {
          if (children.contains(component)) {
            remove(component);
          }
        }
      default:
        return;
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && event != EventType.light) {
      state = EventState.requesting;
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is Player) {
      state = EventState.inactive;
    }
    super.onCollisionEnd(other);
  }

  @override
  FutureOr<void> onLoad() {
    _requestingComponent = requestingComponent()
      ..position = Vector2(size.x / 2, size.y / 2)
      ..anchor = Anchor.center;
    _inProgressComponent = TextBoxComponent();
    _finishedComponent = TextBoxComponent();
    add(RectangleHitbox());
    return super.onLoad();
  }

  ButtonComponent requestingComponent() {
    ButtonComponent wrapper({
      required String text,
      VoidCallback? onPressed,
    }) {
      return ButtonComponent(
        onPressed: onPressed,
        button: TextComponent(
          text: text,
          textRenderer: TextPaint(
            style: TextStyle(
              fontSize: 4,
              fontWeight: FontWeight.w600,
              background: Paint()
                ..color = Colors.black38
                ..style = PaintingStyle.fill,
            ),
          ),
        ),
      );
    }

    return switch (event) {
      EventType.guy || EventType.girl => wrapper(text: 'Говорить'),
      EventType.chair || EventType.couch => wrapper(text: 'Сесть'),
      EventType.drink => wrapper(text: 'Попить воды'),
      EventType.gallery => wrapper(
          text: 'Смотреть',
          onPressed: _onGalleryPressed,
        ),
      EventType.light => wrapper(text: 'Включить'),
      EventType.tv => wrapper(text: 'Смотреть'),
    };
  }

  void _onGalleryPressed() {
    gameRef.overlays.add('gallery');
  }
}
