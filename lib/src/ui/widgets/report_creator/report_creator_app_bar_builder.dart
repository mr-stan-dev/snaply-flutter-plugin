import 'package:flutter/material.dart';
import 'package:snaply/src/ui/state/reporting_stage.dart';
import 'package:snaply/src/ui/state/snaply_state.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';
import 'package:snaply/src/ui/state/snaply_state_provider.dart';

class ReportCreatorAppBarBuilder {
  ReportCreatorAppBarBuilder._();

  static AppBar? build(BuildContext context, SnaplyState state) {
    final showAppBar = state.reportingStage is ViewingReport ||
        state.reportingStage is ViewingFiles;
    return showAppBar
        ? AppBar(
            title: Row(
              children: [
                Text(_appBarTitle(state)),
              ],
            ),
            elevation: 4,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton(
                  onPressed: () => _onActionButtonPressed(context, state),
                  child: Text(_appBarButtonText(state)),
                ),
              ),
            ],
          )
        : null;
  }

  static void _onActionButtonPressed(BuildContext context, SnaplyState state) {
    switch (state.reportingStage) {
      case Gathering():
      case ViewingReport():
      case Loading():
        context.act(Deactivate());
      case ViewingFiles():
        context.act(ReviewReport());
    }
  }

  static String _appBarTitle(SnaplyState state) {
    switch (state.reportingStage) {
      case Gathering():
      case ViewingReport():
      case Loading():
        return 'New report';
      case ViewingFiles state:
        return 'Report ${state.isMediaFiles ? 'media' : 'extra'} files';
    }
  }

  static String _appBarButtonText(SnaplyState state) {
    switch (state.reportingStage) {
      case Gathering():
      case ViewingReport():
      case Loading():
        return 'Discard';
      case ViewingFiles():
        return 'Back';
    }
  }
}
