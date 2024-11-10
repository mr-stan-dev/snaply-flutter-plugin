import 'package:flutter/material.dart';
import 'package:snaply/src/ui/state/snaply_state.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_creator_action_buttons.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_creator_severity.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_creator_title.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_files/preview/extra_files_preview_layout.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_files/preview/media_files_preview_layout.dart';

class ReportReviewingWidget extends StatelessWidget {
  const ReportReviewingWidget({
    required this.state,
    super.key,
  });

  final SnaplyState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportCreatorTitle(state: state),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  ReportCreatorSeverity(state: state),
                  const Divider(height: 2),
                  MediaFilesPreviewLayout(mediaFiles: state.mediaFiles),
                  const Divider(height: 2),
                  const SizedBox(height: 12),
                  ExtraFilesPreviewLayout(extraFiles: state.extraFiles),
                  const Divider(height: 2),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const ReportCreatorActionButtons(),
        ],
      ),
    );
  }
}
