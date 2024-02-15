import 'package:flutter/material.dart';
import 'package:raog_tver_meta/missions/mission.dart';

class MissionsController extends ChangeNotifier {
  static const npcAmount = 10;

  final Map<Missions, bool> _missions;

  MissionsController(this._missions)
      : assert(_missions.length == Missions.values.length);

  int _talkToEverybodyCounter = 0;
  int get talkToEverybodyCounter => _talkToEverybodyCounter;

  int get completedMissionsAmount =>
      _missions.values.where((value) => value).length;

  int get missionsAmount => _missions.entries.length;

  bool get allMissionsCompleted =>
      _missions.values.every((completed) => completed);

  Missions? _lastCompletedMission;
  Missions? get lastCompletedMission => _lastCompletedMission;

  MapEntry<Missions, bool> getByIndex(int index) =>
      _missions.entries.toList()[index];

  void complete(Missions mission) {
    final missionCompleted = _missions[mission] ?? true;
    if (!missionCompleted) {
      if (mission == Missions.talkToEverybody) {
        _talkToEverybodyCounter++;
        notifyListeners();
        if (_talkToEverybodyCounter == npcAmount) {
          _lastCompletedMission = mission;
          _missions[mission] = true;
          notifyListeners();
        }
      } else {
        _missions[mission] = true;
        _lastCompletedMission = mission;
        notifyListeners();
      }
    }
  }
}
