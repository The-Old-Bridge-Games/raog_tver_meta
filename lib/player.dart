import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:raog_tver_meta/main.dart';
import 'package:raog_tver_meta/obstacle.dart';

class Player extends SpriteAnimationGroupComponent<MyStates>
    with CollisionCallbacks, HasGameRef<RaogTverMeta> {
  Player() : super(anchor: Anchor.bottomCenter) {
    debugMode = false;
  }

  AudioPlayer? _walkingPlayer;

  double maxSpeed = 5.0;

  var collisionDirection = CollisionDirection.none;
  List<CollisionDirection> possibleCollisionDirections = [];

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
        print('playWalking');
      } else if (isWalking(current) && !isWalking(newState)) {
        _walkingPlayer?.stop();
      }
      current = newState;
    }
  }

  List<CollisionDirection> get collisionDirections {
    switch (joystick.direction) {
      case JoystickDirection.idle:
        return [];
      case JoystickDirection.down:
        return [CollisionDirection.down];
      case JoystickDirection.downLeft:
        return [CollisionDirection.down, CollisionDirection.left];
      case JoystickDirection.downRight:
        return [CollisionDirection.down, CollisionDirection.right];
      case JoystickDirection.left:
        return [CollisionDirection.left];
      case JoystickDirection.upLeft:
        return [CollisionDirection.up, CollisionDirection.left];
      case JoystickDirection.up:
        return [CollisionDirection.up];
      case JoystickDirection.upRight:
        return [CollisionDirection.up, CollisionDirection.right];
      case JoystickDirection.right:
        return [CollisionDirection.right];
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
      for (final dir in collisionDirections) {
        if (!possibleCollisionDirections.contains(dir)) {
          possibleCollisionDirections.add(dir);
        }
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    possibleCollisionDirections = [];
    super.onCollisionEnd(other);
  }

  @override
  FutureOr<void> onLoad() async {
    const stepTime = 0.2;
    final spriteSheet = SpriteSheet.fromColumnsAndRows(
      image: await Flame.images.load('Adam_16x16.png'),
      columns: 24,
      rows: 7,
    );
    final idleRightAnimation = spriteSheet.createAnimation(
      row: 1,
      stepTime: stepTime,
      to: 5,
    );
    final idleDownAnimation = SpriteAnimation.fromFrameData(
      await Flame.images.load('Adam_16x16.png'),
      SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: stepTime,
          textureSize: Vector2(16, 32),
          texturePosition: Vector2(18 * 16, 32)),
    );
    final idleLeftAnimation = spriteSheet.createAnimation(
      row: 1,
      stepTime: stepTime,
      from: 12,
      to: 17,
    );
    final idleUpAnimation = spriteSheet.createAnimation(
      row: 1,
      stepTime: stepTime,
      from: 6,
      to: 11,
    );
    final moveRightAnimation = spriteSheet.createAnimation(
      row: 2,
      stepTime: stepTime,
      to: 5,
    );
    final moveDownAnimation = spriteSheet.createAnimation(
      row: 2,
      stepTime: stepTime,
      from: 18,
    )..frames.forEach((element) {
        element.sprite.srcSize = element.sprite.srcSize - Vector2.all(2);
      });
    final moveLeftAnimation = spriteSheet.createAnimation(
      row: 2,
      stepTime: stepTime,
      from: 12,
      to: 17,
    );
    final moveUpAnimation = spriteSheet.createAnimation(
      row: 2,
      stepTime: stepTime,
      from: 6,
      to: 11,
    );
    final sitRightAnimation = spriteSheet.createAnimation(
      row: 5,
      stepTime: stepTime,
      to: 5,
      loop: false,
    );
    final sitLeftAnimation = spriteSheet.createAnimation(
      row: 5,
      stepTime: stepTime,
      from: 6,
      to: 12,
    );
    final drinkAnimation = spriteSheet.createAnimation(
      row: 6,
      stepTime: stepTime,
      to: 8,
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
      size: Vector2(size.x, size.y / 2),
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final prevState = current;
    MyStates? newState;
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
      case JoystickDirection.left:
        if (current != MyStates.moveLeft) {
          newState = MyStates.moveLeft;
        }
      case JoystickDirection.right:
        if (current != MyStates.moveRight) {
          newState = MyStates.moveRight;
        }
      case JoystickDirection.upLeft:
      case JoystickDirection.upRight:
      case JoystickDirection.up:
        if (current != MyStates.moveUp) {
          newState = MyStates.moveUp;
        }
    }
    if (current != newState && newState != null) {
      setCurrent(newState);
    }
    if (joystick.direction != JoystickDirection.idle) {
      Vector2 delta = joystick.delta;
      if (possibleCollisionDirections.contains(CollisionDirection.up)) {
        if (delta.y < 0) {
          delta = Vector2(delta.x, 0);
        } else {
          delta = Vector2(delta.x, delta.y);
        }
      }
      if (possibleCollisionDirections.contains(CollisionDirection.right)) {
        if (delta.x > 0) {
          delta = Vector2(0, delta.y);
        } else {
          delta = Vector2(delta.x, delta.y);
        }
      }
      if (possibleCollisionDirections.contains(CollisionDirection.down)) {
        if (delta.y > 0) {
          delta = Vector2(delta.x, 0);
        } else {
          delta = Vector2(delta.x, delta.y);
        }
      }
      if (possibleCollisionDirections.contains(CollisionDirection.left)) {
        if (delta.x > 0) {
          delta = Vector2(delta.x, delta.y);
        } else {
          delta = Vector2(0, delta.y);
        }
      }
      // Vector2 delta = switch (collisionDirection) {
      //   CollisionDirection.none => joystick.delta,
      //   CollisionDirection.up => Vector2(joystick.delta.x, 0),
      //   CollisionDirection.down => Vector2(joystick.delta.x, 0),
      //   CollisionDirection.right => Vector2(0, joystick.delta.y),
      //   CollisionDirection.left => Vector2(0, joystick.delta.y),
      // };
      delta = delta * maxSpeed * dt;
      if (position.x + size.x / 2 + delta.x > gameRef.mapSize.x - width / 2) {
        delta.x = 0;
      }
      if (position.x - size.x / 2 + delta.x < width / 2) {
        delta.x = 0;
      }
      if (position.y + delta.y > gameRef.mapSize.y - height / 2) {
        delta.y = 0;
      }
      if (position.y - height / 3 * 2 + delta.y < height / 2) {
        delta.y = 0;
      }
      if ((prevState == MyStates.sitLeft || prevState == MyStates.sitRight) &&
          current != prevState) {
        if (prevState == MyStates.sitRight) {
          position.add(-Vector2(15, 0));
        }
        if (prevState == MyStates.sitLeft) {
          position.add(Vector2(15, 0));
        }
      }
      position.add(delta);
    }
  }
}
