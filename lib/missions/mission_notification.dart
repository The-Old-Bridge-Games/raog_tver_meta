import 'package:flutter/material.dart';
import 'package:raog_tver_meta/missions/mission.dart';
import 'package:raog_tver_meta/missions/mission_controller.dart';
import 'package:raog_tver_meta/utils/styles.dart';

class MissionNotification extends StatefulWidget {
  final MissionsController controller;

  const MissionNotification({required this.controller, super.key});

  @override
  State<MissionNotification> createState() => _MissionNotificationState();
}

class _MissionNotificationState extends State<MissionNotification>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<Offset> translateAnimation;
  late final Animation<double> opacityAnimation;

  Missions? _lastCompletedMission;

  bool _finished = false;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    translateAnimation = Tween<Offset>(
      begin: const Offset(0, -200),
      end: const Offset(0, 32),
    ).animate(animationController);
    opacityAnimation =
        Tween<double>(begin: 0.5, end: 1).animate(animationController);
    widget.controller.addListener(() {
      final newMissionCompleted =
          _lastCompletedMission != widget.controller.lastCompletedMission;
      if (newMissionCompleted) {
        _lastCompletedMission = widget.controller.lastCompletedMission;
        animationController.forward().whenComplete(() {
          Future.delayed(const Duration(seconds: 2)).whenComplete(
            () => animationController.reverse(),
          );
        });
      }
      if (widget.controller.allMissionsCompleted) {
        setState(() {
          _finished = true;
        });
        Future.delayed(const Duration(seconds: 5))
            .then((value) => setState(() => _finished = false));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
        AnimatedBuilder(
            animation: translateAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: translateAnimation.value,
                child: _buildNotification(),
              );
            }),
        Center(
          child: AnimatedOpacity(
            opacity: _finished ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            child: Material(
              borderRadius: BorderRadius.circular(13),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('ПОЗДРАВЛЯЕМ!', style: Styles.missionCompleteStyle),
                    const Text(
                      'Ты выполнил все миссии. Ждем тебя на Альфе',
                      style: Styles.missionsHeaderStyle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotification() {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
          animation: opacityAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: opacityAnimation.value,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'МИССИЯ ВЫПОЛНЕНА!',
                      style: Styles.missionCompleteStyle,
                    ),
                    Text(
                      widget.controller.lastCompletedMission?.text ?? '',
                      style: Styles.missionsHeaderStyle,
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
