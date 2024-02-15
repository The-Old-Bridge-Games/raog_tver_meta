import 'dart:math';

import 'package:flame_audio/flame_audio.dart';
import 'package:raog_tver_meta/events/event.dart';

mixin Talking on Event {
  final _rnd = Random();

  Future<void> playTalking() {
    return _rnd.nextBool()
        ? FlameAudio.play('talking1.mp3')
        : FlameAudio.play('talking2.mp3');
  }
}
