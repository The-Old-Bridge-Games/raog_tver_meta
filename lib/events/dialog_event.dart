import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart'
    show TextStyle, FontWeight, Paint, Colors, PaintingStyle;
import 'package:raog_tver_meta/components/dialog_text_box_component.dart';
import 'package:raog_tver_meta/events/event.dart';
import 'package:raog_tver_meta/main.dart';
import 'package:raog_tver_meta/player.dart';
import 'package:raog_tver_meta/utils/audio_mixins.dart';

final class DialogEvent extends PositionComponent
    with Event, HasGameRef<RaogTverMeta>, CollisionCallbacks, Talking {
  final int table;
  final int index;
  final bool isGuy;

  DialogEvent({
    required this.table,
    required this.isGuy,
    super.position,
    super.size,
    this.index = 1,
  }) {
    debugMode = false;
  }

  bool _running = false;
  bool _completed = false;

  bool get canShowButton => !_running && !_completed;

  void run({
    void Function()? onComplete,
    void Function()? onStopped,
  }) {
    if (_completed) return;
    if (table == 1 && index == 1) {
      _runTable1Index1(onComplete);
      return;
    }
    if (table == 1 && index == 2) {
      _runTable1Index2(onComplete);
      return;
    }
    if (table == 2 && isGuy) {
      _runTable2Guy(onComplete);
      return;
    }
    if (table == 2 && !isGuy) {
      _runTable2Girl(onComplete);
      return;
    }
    if (table == 3 && index == 1 && isGuy) {
      _runTable3Index1Guy(onComplete);
      return;
    }
    if (table == 3 && index == 1 && !isGuy) {
      _runTable3Index1Girl(onComplete);
      return;
    }
    if (table == 3 && index == 2 && isGuy) {
      _runTable3Index2Guy(onComplete);
      return;
    }
    if (table == 3 && index == 2 && !isGuy) {
      _runTable3Index2Girl(onComplete);
      return;
    }
    if (table == 0 && isGuy) {
      _runCouchGuy(
        onComplete: onComplete,
        onStopped: onStopped,
      );
    }
    if (table == 0 && !isGuy) {
      _runCouchGirl(
        onComplete: onComplete,
        onStopped: onStopped,
      );
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && canShowButton) {
      add(startButton()..position = size / 2);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    final hasButton = children.whereType<ButtonComponent>().isNotEmpty;
    if (other is Player && hasButton && !other.sitting) {
      removeWhere((component) => component is ButtonComponent);
    }
    super.onCollisionEnd(other);
  }

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(isSolid: true));
    return super.onLoad();
  }

  @override
  PositionComponent startButton() {
    return ButtonComponent(
      onPressed: () {
        gameRef.proceedDialog(this);
      },
      anchor: Anchor.center,
      button: TextComponent(
        text: 'Говорить',
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

  Future<void> _runTable1Index1(void Function()? onComplete) async {
    const text = 'Привет! Я – Стив. Рад видеть тебя на Альфе!';
    const timePerChar = 0.05;
    const duration = text.length * timePerChar;
    _running = true;
    await playTalking();
    addAll([
      DialogTextBoxComponent(
        text: text,
        size: size,
      ),
      TimerComponent(
        period: duration,
        removeOnFinish: true,
        onTick: () {
          _completed = true;
          _running = false;
          onComplete?.call();
        },
      )
    ]);
  }

  Future<void> _runTable1Index2(void Function()? onComplete) async {
    const text = 'Привет! Прости, я немного занят.. Поговорим в другой раз.';
    const timePerChar = 0.05;
    const duration = text.length * timePerChar;
    _running = true;
    await playTalking();
    final hasButton = children.whereType<ButtonComponent>().isNotEmpty;
    if (hasButton) removeWhere((component) => component is ButtonComponent);
    addAll([
      DialogTextBoxComponent(
        text: text,
        size: size,
      ),
      TimerComponent(
        period: duration,
        removeOnFinish: true,
        onTick: () {
          _completed = true;
          _running = false;
          onComplete?.call();
        },
      )
    ]);
  }

  Future<void> _runTable2Guy(void Function()? onComplete) async {
    const text1 = 'А какую суперспособность ты выбрал?';
    const text2 =
        'Я бы хотела летать! Тогда не пришлось бы ездить в душных автобусах..';
    const timePerChar = 0.05;
    const duration1 = text1.length * timePerChar;
    const duration2 = text2.length * timePerChar;
    _running = true;
    await playTalking();
    final hasButton = children.whereType<ButtonComponent>().isNotEmpty;
    if (hasButton) removeWhere((component) => component is ButtonComponent);
    addAll([
      DialogTextBoxComponent(
        text: text1,
        size: size,
      ),
      TimerComponent(
        period: duration1,
        removeOnFinish: true,
        onTick: () {
          addAll([
            DialogTextBoxComponent(
              text: text2,
              size: size,
              position: Vector2(size.x, 0),
            ),
            TimerComponent(
              period: duration2,
              removeOnFinish: true,
              onTick: () {
                _completed = true;
                _running = false;
                onComplete?.call();
              },
            )
          ]);
        },
      )
    ]);
  }

  Future<void> _runTable2Girl(void Function()? onComplete) async {
    const text1 =
        'Привет! Меня зовут Амелия! Это моя третья Альфа, но здесь классно, как в первый раз!';
    const text2 =
        'А я первый раз, но мне здесь все понятно.......... Хочу домой..';
    const timePerChar = 0.05;
    const duration1 = text1.length * timePerChar;
    const duration2 = text2.length * timePerChar;
    _running = true;
    await playTalking();
    final hasButton = children.whereType<ButtonComponent>().isNotEmpty;
    if (hasButton) removeWhere((component) => component is ButtonComponent);
    addAll([
      DialogTextBoxComponent(
        text: text1,
        size: size,
        position: Vector2(size.x, 0),
      ),
      TimerComponent(
        period: duration1,
        removeOnFinish: true,
        onTick: () {
          addAll([
            DialogTextBoxComponent(
              text: text2,
              size: size,
            ),
            TimerComponent(
              period: duration2,
              removeOnFinish: true,
              onTick: () {
                _completed = true;
                _running = false;
                onComplete?.call();
              },
            )
          ]);
        },
      )
    ]);
  }

  Future<void> _runTable3Index1Guy(void Function()? onComplete) async {
    const text1 =
        'Я записал, все, что сегодня произошло.. Можешь обратиться ко мне, если что-то упустил.';
    const timePerChar = 0.05;
    const duration = text1.length * timePerChar;
    _running = true;
    await playTalking();
    final hasButton = children.whereType<ButtonComponent>().isNotEmpty;
    if (hasButton) removeWhere((component) => component is ButtonComponent);
    addAll([
      DialogTextBoxComponent(
        text: text1,
        size: size,
        position: Vector2(size.x, 0),
      ),
      TimerComponent(
        period: duration,
        removeOnFinish: true,
        onTick: () {
          _completed = true;
          _running = false;
          onComplete?.call();
        },
      )
    ]);
  }

  Future<void> _runTable3Index1Girl(void Function()? onComplete) async {
    const text1 =
        'Боб опять все записывал, лучше бы он был больше в общении...';
    const text2 = '...';
    const text3 = '...Кто же тогда будет все записывать???';
    const text4 = 'Оооххх';
    const timePerChar = 0.05;
    const timePerChar2 = 1.0;
    const duration1 = text1.length * timePerChar;
    const double duration2 = text2.length * timePerChar2;
    const duration3 = text3.length * timePerChar;
    const double duration4 = text4.length * timePerChar;
    final bobTextPosition = Vector2(-size.x, 0);
    final girlTextPosition = Vector2(size.x, 0);
    final _size = Vector2(size.x, size.y * 2);
    _running = true;
    await playTalking();
    final hasButton = children.whereType<ButtonComponent>().isNotEmpty;
    if (hasButton) removeWhere((component) => component is ButtonComponent);
    addAll([
      DialogTextBoxComponent(
        text: text1,
        size: _size,
        timePerChar: timePerChar,
        position: girlTextPosition,
      ),
      TimerComponent(
        period: duration1,
        removeOnFinish: true,
        onTick: () {
          addAll([
            DialogTextBoxComponent(
              text: text2,
              size: _size,
              timePerChar: timePerChar2,
              position: bobTextPosition,
            ),
            TimerComponent(
                period: duration2,
                removeOnFinish: true,
                onTick: () {
                  addAll([
                    DialogTextBoxComponent(
                      text: text3,
                      size: _size,
                      timePerChar: timePerChar,
                      position: bobTextPosition,
                    ),
                    TimerComponent(
                        period: duration3,
                        removeOnFinish: true,
                        onTick: () {
                          addAll([
                            DialogTextBoxComponent(
                              text: text4,
                              size: _size,
                              timePerChar: timePerChar,
                              position: girlTextPosition,
                            ),
                            TimerComponent(
                                period: duration4,
                                removeOnFinish: true,
                                onTick: () {
                                  _completed = true;
                                  _running = false;
                                  onComplete?.call();
                                }),
                          ]);
                        })
                  ]);
                }),
          ]);
        },
      )
    ]);
  }

  Future<void> _runTable3Index2Guy(void Function()? onComplete) async {
    const text1 =
        'Я бы точно накормил всех голодающих, если бы у меня было 24 часа безграничных возможностей!';
    const text2 = 'Ты скорее бы купил весь шоколад мира!';
    const timePerChar = 0.05;
    const duration1 = text1.length * timePerChar;
    const duration2 = text2.length * timePerChar;
    _running = true;
    await playTalking();
    final hasButton = children.whereType<ButtonComponent>().isNotEmpty;
    if (hasButton) removeWhere((component) => component is ButtonComponent);
    addAll([
      DialogTextBoxComponent(
        text: text1,
        size: size,
        timePerChar: timePerChar,
      ),
      TimerComponent(
        period: duration1,
        removeOnFinish: true,
        onTick: () {
          addAll([
            DialogTextBoxComponent(
              text: text2,
              size: size,
              timePerChar: timePerChar,
              position: Vector2(size.x, 0),
            ),
            TimerComponent(
                period: duration2,
                removeOnFinish: true,
                onTick: () {
                  _completed = true;
                  _running = false;
                  onComplete?.call();
                }),
          ]);
        },
      )
    ]);
  }

  Future<void> _runTable3Index2Girl(void Function()? onComplete) async {
    const text1 =
        '24 часа безграничных возможностей... Я бы купила себе все, чего мне так не хватает!';
    const text2 = 'Даже после этого уверен тебе бы чего-то не хватало..';
    const timePerChar = 0.05;
    const duration1 = text1.length * timePerChar;
    const duration2 = text2.length * timePerChar;
    _running = true;
    await playTalking();
    final hasButton = children.whereType<ButtonComponent>().isNotEmpty;
    if (hasButton) removeWhere((component) => component is ButtonComponent);
    addAll([
      DialogTextBoxComponent(
        text: text1,
        size: size,
        timePerChar: timePerChar,
        position: Vector2(size.x, 0),
      ),
      TimerComponent(
        period: duration1,
        removeOnFinish: true,
        onTick: () {
          addAll([
            DialogTextBoxComponent(
              text: text2,
              size: size,
              timePerChar: timePerChar,
            ),
            TimerComponent(
                period: duration2,
                removeOnFinish: true,
                onTick: () {
                  _completed = true;
                  _running = false;
                  onComplete?.call();
                }),
          ]);
        },
      )
    ]);
  }

  Future<void> _runCouchGuy({
    void Function()? onComplete,
    void Function()? onStopped,
  }) async {
    final isSitting = gameRef.me.sitting;
    if (!isSitting) {
      const text = 'Присаживайся, пообщаемся!';
      const timePerChar = 0.05;
      const duration = text.length * timePerChar;
      addAll([
        DialogTextBoxComponent(
          text: text,
          size: size,
          timePerChar: timePerChar,
        ),
        TimerComponent(
          period: duration,
          removeOnFinish: true,
          onTick: () {
            _running = false;
            onStopped?.call();
          },
        )
      ]);
    } else {
      _running = true;
      const text =
          'Меня зовут Дениз! Вообще-то я пастор церкви, если интересует духовный вопрос.. и не только.. я весь твой!';
      const timePerChar = 0.05;
      const duration = text.length * timePerChar;
      addAll([
        DialogTextBoxComponent(
          text: text,
          size: size,
          timePerChar: timePerChar,
        ),
        TimerComponent(
          period: duration,
          removeOnFinish: true,
          onTick: () {
            _running = false;
            _completed = true;
            onComplete?.call();
          },
        )
      ]);
    }
  }

  Future<void> _runCouchGirl({
    void Function()? onComplete,
    void Function()? onStopped,
  }) async {
    final isSitting = gameRef.me.sitting;
    if (!isSitting) {
      const text = 'Я могу рассказать тебе кое-что, присаживайся!';
      const timePerChar = 0.05;
      const duration = text.length * timePerChar;
      addAll([
        DialogTextBoxComponent(
          text: text,
          size: Vector2(size.x / 2, 0),
          timePerChar: timePerChar,
          position: Vector2(size.x / 2, 0),
        ),
        TimerComponent(
          period: duration,
          removeOnFinish: true,
          onTick: () {
            _running = false;
            onStopped?.call();
          },
        )
      ]);
    } else {
      _running = true;
      const text =
          'Меня зовут Натали! Я жена пастора. Если тебе что-то нужно – просто скажи!';
      const timePerChar = 0.05;
      const duration = text.length * timePerChar;
      addAll([
        DialogTextBoxComponent(
          text: text,
          size: Vector2(size.x / 2, 0),
          timePerChar: timePerChar,
          position: Vector2(size.x / 2, 0),
        ),
        TimerComponent(
          period: duration,
          removeOnFinish: true,
          onTick: () {
            _running = false;
            _completed = true;
            onComplete?.call();
          },
        )
      ]);
    }
  }
}
