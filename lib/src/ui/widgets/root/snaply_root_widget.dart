import 'package:flutter/material.dart';
import 'package:snaply/src/ui/state/snaply_state.dart';
import 'package:snaply/src/ui/state/snaply_state_provider.dart';
import 'package:snaply/src/ui/viewmodel/snaply_view_model_creator.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_creator_layout.dart';
import 'package:snaply/src/ui/widgets/root/data_gathering_layout.dart';
import 'package:snaply/src/ui/widgets/snackbar/snackbar_root_layout.dart';

class SnaplyRootWidget extends StatefulWidget {
  const SnaplyRootWidget({super.key});

  @override
  State<SnaplyRootWidget> createState() => _SnaplyRootWidgetState();
}

class _SnaplyRootWidgetState extends State<SnaplyRootWidget> {
  final _viewModel = SnaplyViewModelCreator.create();

  @override
  Widget build(BuildContext context) {
    return SnaplyStateProvider(
      onAction: (action) => _viewModel.act(action),
      child: ValueListenableBuilder(
        valueListenable: _viewModel,
        builder: (context, state, _) => Stack(
          children: [
            Positioned.fill(
              child: _fullScreenWidget(state),
            ),
            SnackbarRootLayout(_viewModel.uiEventsStream),
          ],
        ),
      ),
    );
  }

  Widget _fullScreenWidget(SnaplyState state) {
    return state.isGathering
        ? DataGatheringLayout(state: state)
        : ReportCreatorLayout(state: state);
  }
}
