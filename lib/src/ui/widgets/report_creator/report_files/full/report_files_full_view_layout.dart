import 'dart:io';

import 'package:flutter/material.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_files/full/full_view_attributes.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_files/full/full_view_logs.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_files/full/full_view_screenshot.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_files/full/full_view_video.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_files/full/report_files_page_indicator.dart';

class ReportFilesFullViewLayout extends StatefulWidget {
  const ReportFilesFullViewLayout({
    required this.files,
    required this.initialIndex,
    super.key,
  });

  final List<ReportFile> files;
  final int initialIndex;

  @override
  State<ReportFilesFullViewLayout> createState() =>
      _ReportFilesFullViewLayoutState();
}

class _ReportFilesFullViewLayoutState extends State<ReportFilesFullViewLayout> {
  late int currentPage = widget.initialIndex;
  late final _pageController = PageController(initialPage: widget.initialIndex);

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages =
        widget.files.map((f) => _fileFullView(f)).toList();

    if (widget.files.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: Text('No media files attached'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => currentPage = page),
              children: pages,
            ),
          ),
          if (pages.length > 1)
            ReportFilesPageIndicator(
              currentPage: currentPage,
              length: pages.length,
            ),
        ],
      ),
    );
  }

  Widget _fileFullView(ReportFile file) {
    switch (file) {
      case ScreenVideoFile():
        return FullViewVideo(file: File(file.filePath));
      case ScreenshotFile():
        return FullViewScreenshot(bytes: file.bytes);
      case LogsFile():
        return FullViewLogs(logsFile: file);
      case AttributesFile():
        return FullViewAttributes(attrsFile: file);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
