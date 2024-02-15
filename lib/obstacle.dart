import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:raog_tver_meta/main.dart';
import 'package:raog_tver_meta/player.dart';

class Obstacle extends PositionComponent
    with CollisionCallbacks, HasGameRef<RaogTverMeta> {
  Obstacle({super.size, super.position});

  Player get player => game.me;

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox());
    return super.onLoad();
  }
}
