import 'package:flutter/material.dart';
import 'package:snaply/src/data_holders/configuration_holder.dart';
import 'package:snaply/src/ui/state/snaply_state.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';
import 'package:snaply/src/ui/state/snaply_state_provider.dart';
import 'package:snaply/src/ui/widgets/control_buttons/control_buttons.dart';

class DataGatheringLayout extends StatefulWidget {
  const DataGatheringLayout({
    super.key,
    required this.state,
  });

  final SnaplyState state;

  @override
  State<DataGatheringLayout> createState() => _DataGatheringLayoutState();
}

class _DataGatheringLayoutState extends State<DataGatheringLayout> {
  late double _xPos = 30;
  late double _yPos = 70;

  @override
  void initState() {
    ConfigurationHolder.instance.visibility.addListener(_onVisibilityChanged);
    super.initState();
  }

  @override
  void dispose() {
    ConfigurationHolder.instance.visibility
        .removeListener(_onVisibilityChanged);
    super.dispose();
  }

  void _onVisibilityChanged() {
    context.act(
      SetControlsVisibility(ConfigurationHolder.instance.isVisible),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: _xPos,
          bottom: _yPos,
          child: GestureDetector(
            onPanUpdate: _onPanUpdate,
            child: ControlButtons(state: widget.state),
          ),
        ),
      ],
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(
      () {
        _xPos -= details.delta.dx;
        _yPos -= details.delta.dy;
      },
    );
  }
}
