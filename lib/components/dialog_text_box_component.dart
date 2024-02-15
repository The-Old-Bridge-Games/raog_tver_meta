import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:raog_tver_meta/utils/styles.dart';

final class DialogTextBoxComponent extends TextBoxComponent {
  DialogTextBoxComponent({
    required String text,
    required Vector2 size,
    double timePerChar = 0.05,
    super.position,
    super.priority,
  }) : super(
            anchor: Anchor.center,
            text: text,
            pixelRatio: Styles.dialogPixelRation,
            textRenderer: Styles.dialogTextRenderer,
            boxConfig: TextBoxConfig(
              maxWidth: size.x,
              margins: EdgeInsets.zero,
              timePerChar: timePerChar,
              dismissDelay: 1,
            ));
}
