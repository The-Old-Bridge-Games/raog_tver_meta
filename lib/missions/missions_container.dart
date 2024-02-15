import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:raog_tver_meta/missions/mission.dart';
import 'package:raog_tver_meta/missions/mission_controller.dart';
import 'package:raog_tver_meta/utils/styles.dart';

class MissionsContainer extends StatefulWidget {
  final MissionsController controller;

  const MissionsContainer({
    required this.controller,
    super.key,
  });

  @override
  State<MissionsContainer> createState() => _MissionsContainerState();
}

class _MissionsContainerState extends State<MissionsContainer> {
  final _expandController = ExpandableController(initialExpanded: true);

  @override
  void initState() {
    widget.controller.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: const Alignment(0.8, -0.5),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _expandController.expanded ? 1 : 0.8,
            child: SizedBox(
              width: 160,
              child: Material(
                color: Colors.transparent,
                child: Expandable(
                  controller: _expandController,
                  collapsed: _buildCollapsed(),
                  expanded: _buildExpanded(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpanded() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCollapsed(),
        Container(
          decoration: BoxDecoration(
              color: Colors.black54, borderRadius: BorderRadius.circular(3)),
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.controller.missionsAmount,
              itemBuilder: (context, index) {
                final mission = widget.controller.getByIndex(index);
                final style = Styles.missionStyle.copyWith(
                  color: mission.value ? Colors.green : Colors.white,
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Text(
                        mission.key.text,
                        style: style,
                      )),
                      if (mission.key == Missions.talkToEverybody)
                        Text(
                          '${widget.controller.talkToEverybodyCounter}/${MissionsController.npcAmount}',
                          style: style,
                        )
                      else
                        Text(mission.value ? '1/1' : '0/1', style: style),
                    ],
                  ),
                );
              }),
        )
      ],
    );
  }

  Widget _buildCollapsed() {
    return GestureDetector(
      onTap: () {
        setState(_expandController.toggle);
      },
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Styles.whiteColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              const Spacer(),
              const Text('Задания', style: Styles.missionsHeaderStyle),
              const SizedBox(width: 4),
              Text(
                '${widget.controller.completedMissionsAmount}/${widget.controller.missionsAmount}',
                style: Styles.missionsHeaderStyle,
              ),
              const Spacer(),
            ],
          )),
    );
  }
}
