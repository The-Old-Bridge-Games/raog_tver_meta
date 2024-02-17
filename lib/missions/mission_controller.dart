import 'package:flutter/material.dart';
import 'package:raog_tver_meta/missions/mission.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MissionsController extends ChangeNotifier {
  static const npcAmount = 10;

  final Map<Missions, bool> _missions;
  final SharedPreferences _prefs;

  MissionsController(
    this._missions,
    this._prefs,
  ) : assert(_missions.length == Missions.values.length) {
    if (_missions[Missions.talkToEverybody] == true) {
      _talkToEverybodyCounter = 10;
    }
  }

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
          _prefs.setBool(mission.name, true);

          notifyListeners();
        }
      } else {
        _missions[mission] = true;
        _prefs.setBool(mission.name, true);
        _lastCompletedMission = mission;
        notifyListeners();
      }
    }
  }
}
