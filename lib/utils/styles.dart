import 'package:flame/components.dart';
import 'package:flutter/material.dart';

abstract class Styles {
  const Styles._();

  static final greenColor = Colors.green[500];
  static const whiteColor = Color(0xffF1F3EA);
  static final dialogTextRenderer = TextPaint(
      style: TextStyle(
    fontSize: 4,
    color: Colors.black,
    fontWeight: FontWeight.w600,
    background: Paint()..color = Colors.white,
  ));
  static const double dialogPixelRation = 10;

  static const missionsHeaderStyle = TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );
  static const missionStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );
  static final missionCompleteStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: greenColor,
  );
}
