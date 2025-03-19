import 'package:flutter/material.dart';
import 'package:snaply/src/ui/state/reporting_stage.dart';
import 'package:snaply/src/ui/state/snaply_state.dart';
import 'package:snaply/src/ui/theme/snaply_theme.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_creator_app_bar_builder.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_files/full/report_files_full_view_layout.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_reviewing_widget.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_uploading_widget.dart';

class ReportCreatorLayout extends StatelessWidget {
  const ReportCreatorLayout({
    required this.state,
    super.key,
  });

  final SnaplyState state;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: SnaplyTheme.defaultTheme,
      home: Scaffold(
        appBar: ReportCreatorAppBarBuilder.build(context, state),
        body: SafeArea(child: _bodyWidget()),
      ),
    );
  }

  Widget _bodyWidget() {
    switch (state.reportingStage) {
      case Gathering():
        return const SizedBox.shrink();
      case ViewingReport():
        return ReportReviewingWidget(state: state);
      case final ViewingFiles reportState:
        return ReportFilesFullViewLayout(
          files: reportState.isMediaFiles ? state.mediaFiles : state.extraFiles,
          initialIndex: reportState.index,
        );
      case final Loading loading:
        return ReportLoadingWidget(loading: loading);
    }
  }
}
