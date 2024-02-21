import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:raog_tver_meta/events/event.dart';
import 'package:raog_tver_meta/main.dart';
import 'package:raog_tver_meta/obstacle.dart';

class Player extends SpriteAnimationGroupComponent<MyStates>
    with CollisionCallbacks, HasGameRef<RaogTverMeta> {
  Player() : super(anchor: Anchor.bottomCenter) {
    debugMode = false;
  }

  AudioPlayer? _walkingPlayer;

  double maxSpeed = 5.0;

  var collisionDirection = JoystickDirection.idle;

  JoystickComponent get joystick => game.joystick;

  bool get sitting =>
      current == MyStates.sitLeft || current == MyStates.sitRight;

  bool get walking =>
      current == MyStates.moveDown ||
      current == MyStates.moveLeft ||
      current == MyStates.moveRight ||
      current == MyStates.moveUp;

  void setCurrent(MyStates? newState) {
    if (newState != null && newState != current) {
      bool isWalking(MyStates? state) {
        return switch (state) {
          MyStates.moveDown ||
          MyStates.moveLeft ||
          MyStates.moveRight ||
          MyStates.moveUp =>
            true,
          _ => false,
        };
      }

      if (!isWalking(current) && isWalking(newState)) {
        playWalking();
      } else if (isWalking(current) && !isWalking(newState)) {
        _walkingPlayer?.stop();
      }
      current = newState;
    }
  }

  Future<void> playWalking() async {
    if (_walkingPlayer == null) {
      _walkingPlayer = await FlameAudio.loop('WALKING.mp3');
    } else {
      if (_walkingPlayer?.state == PlayerState.paused) {
        return _walkingPlayer?.resume();
      }
      if (_walkingPlayer?.state == PlayerState.stopped ||
          _walkingPlayer?.state == PlayerState.completed) {
        _walkingPlayer = null;
        return playWalking();
      }
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Obstacle) {
      collisionDirection = joystick.direction;
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is Obstacle) {
      collisionDirection = JoystickDirection.idle;
    }
    super.onCollisionEnd(other);
  }

  @override
  FutureOr<void> onLoad() async {
    const stepTime = 0.2;
    final idleRightAnimation = SpriteSheet(
      image: await Flame.images.load('player/Idle Right.png'),
      srcSize: Vector2(16, 32),
      spacing: 16,
    ).createAnimation(
      row: 0,
      stepTime: stepTime,
    );
    final idleDownAnimation = SpriteSheet(
      image: await Flame.images.load('player/Idle Down.png'),
      srcSize: Vector2(16, 32),
      spacing: 16,
    ).createAnimation(
      row: 0,
      stepTime: stepTime,
    );
    final idleLeftAnimation = SpriteSheet(
      image: await Flame.images.load('player/Idle Left.png'),
      srcSize: Vector2(16, 32),
      spacing: 16,
    ).createAnimation(
      row: 0,
      stepTime: stepTime,
    );
    final idleUpAnimation = SpriteSheet(
      image: await Flame.images.load('player/Idle Up.png'),
      srcSize: Vector2(16, 32),
      spacing: 16,
    ).createAnimation(
      row: 0,
      stepTime: stepTime,
    );
    final moveRightAnimation = SpriteSheet(
      image: await Flame.images.load('player/Move Right.png'),
      srcSize: Vector2(16, 32),
      spacing: 16,
    ).createAnimation(
      row: 0,
      stepTime: stepTime,
    );
    final moveDownAnimation = SpriteSheet(
      image: await Flame.images.load('player/Move Down.png'),
      srcSize: Vector2(16, 32),
      spacing: 16,
    ).createAnimation(
      row: 0,
      stepTime: stepTime,
    );
    final moveLeftAnimation = SpriteSheet(
      image: await Flame.images.load('player/Move Left.png'),
      srcSize: Vector2(16, 32),
      spacing: 16,
    ).createAnimation(
      row: 0,
      stepTime: stepTime,
    );
    final moveUpAnimation = SpriteSheet(
      image: await Flame.images.load('player/Move Up.png'),
      srcSize: Vector2(16, 32),
      spacing: 16,
    ).createAnimation(
      row: 0,
      stepTime: stepTime,
    );
    final sitRightAnimation = SpriteSheet(
      image: await Flame.images.load('player/Sit Right.png'),
      srcSize: Vector2(16, 32),
      spacing: 16,
    ).createAnimation(
      row: 0,
      stepTime: stepTime,
    );
    final sitLeftAnimation = SpriteSheet(
      image: await Flame.images.load('player/Sit Left.png'),
      srcSize: Vector2(16, 32),
      spacing: 16,
    ).createAnimation(
      row: 0,
      stepTime: stepTime,
    );
    final drinkAnimation = SpriteSheet(
      image: await Flame.images.load('player/Drink.png'),
      srcSize: Vector2(16, 32),
      spacing: 16,
    ).createAnimation(
      row: 0,
      stepTime: stepTime,
    );

    animations = {
      MyStates.idleDown: idleDownAnimation,
      MyStates.idleLeft: idleLeftAnimation,
      MyStates.idleRight: idleRightAnimation,
      MyStates.idleUp: idleUpAnimation,
      MyStates.sitLeft: sitLeftAnimation,
      MyStates.sitRight: sitRightAnimation,
      MyStates.moveDown: moveDownAnimation,
      MyStates.moveUp: moveUpAnimation,
      MyStates.moveLeft: moveLeftAnimation,
      MyStates.moveRight: moveRightAnimation,
      MyStates.drink: drinkAnimation,
    };
    current = MyStates.idleDown;
    add(RectangleHitbox(
      anchor: Anchor.bottomCenter,
      position: Vector2(size.x / 2, size.y),
      size: Vector2(size.x, 8),
      isSolid: true,
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final prevState = current;
    MyStates? newState;
    Vector2 delta = joystick.delta;
    switch (joystick.direction) {
      case JoystickDirection.idle:
        if (current == MyStates.moveDown) {
          newState = MyStates.idleDown;
        } else if (current == MyStates.moveRight) {
          newState = MyStates.idleRight;
        } else if (current == MyStates.moveUp) {
          newState = MyStates.idleUp;
        } else if (current == MyStates.moveLeft) {
          newState = MyStates.idleLeft;
        }
      case JoystickDirection.downLeft:
      case JoystickDirection.downRight:
      case JoystickDirection.down:
        if (current != MyStates.moveDown) {
          newState = MyStates.moveDown;
        }
        if (joystick.direction == JoystickDirection.up) {
          delta.x = 0;
        }
      case JoystickDirection.left:
        if (current != MyStates.moveLeft) {
          newState = MyStates.moveLeft;
        }
        delta.y = 0;
      case JoystickDirection.right:
        if (current != MyStates.moveRight) {
          newState = MyStates.moveRight;
        }
        delta.y = 0;
      case JoystickDirection.upLeft:
      case JoystickDirection.upRight:
      case JoystickDirection.up:
        if (joystick.direction == JoystickDirection.up) {
          delta.x = 0;
        }
        if (current != MyStates.moveUp) {
          newState = MyStates.moveUp;
        }
    }
    if (current != newState && newState != null) {
      setCurrent(newState);
    }
    if (joystick.direction != JoystickDirection.idle) {
      switch (collisionDirection) {
        case JoystickDirection.idle:
          break;
        case JoystickDirection.down:
          if (delta.y > 0) {
            delta.y = 0;
          }
        case JoystickDirection.downLeft:
          if (delta.x < 0) {
            delta.x = 0;
          }
          if (delta.y > 0) {
            delta.y = 0;
          }
        case JoystickDirection.downRight:
          if (delta.x > 0) {
            delta.x = 0;
          }
          if (delta.y > 0) {
            delta.y = 0;
          }
        case JoystickDirection.left:
          if (delta.x < 0) {
            delta.x = 0;
          }
        case JoystickDirection.right:
          if (delta.x > 0) {
            delta.x = 0;
          }
        case JoystickDirection.up:
          if (delta.y < 0) {
            delta.y = 0;
          }
        case JoystickDirection.upLeft:
          if (delta.x < 0) {
            delta.x = 0;
          }
          if (delta.y < 0) {
            delta.y = 0;
          }
        case JoystickDirection.upRight:
          if (delta.x > 0) {
            delta.x = 0;
          }
          if (delta.y < 0) {
            delta.y = 0;
          }
      }
      delta = delta * maxSpeed * dt;
      if (position.x + size.x / 2 + delta.x > gameRef.mapSize.x - width / 2) {
        delta.x = 0;
      }
      if (position.x - size.x / 2 + delta.x < width / 2) {
        delta.x = 0;
      }
      if (position.y + delta.y > gameRef.mapSize.y - 5) {
        delta.y = 0;
      }
      if (position.y - height / 3 * 2 + delta.y < height / 2) {
        delta.y = 0;
      }
      if ((prevState == MyStates.sitLeft || prevState == MyStates.sitRight) &&
          current != prevState) {
        if (prevState == MyStates.sitRight) {
          position.add(-Vector2(25, 0));
        }
        if (prevState == MyStates.sitLeft) {
          if (gameRef.me.activeCollisions.whereType<CouchEvent>().isNotEmpty) {
            position.add(Vector2(0, -25));
            return;
          }
          position.add(Vector2(25, 0));
        } else if (prevState == MyStates.sitRight) {
          if (gameRef.me.activeCollisions.whereType<CouchEvent>().isNotEmpty) {
            position.add(Vector2(-25, 0));
          }
        }
      }
      position.add(delta);
    }
  }
}
