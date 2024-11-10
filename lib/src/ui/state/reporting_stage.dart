sealed class ReportingStage {}

final class Gathering extends ReportingStage {}

final class ViewingReport extends ReportingStage {}

final class ViewingFiles extends ReportingStage {
  ViewingFiles({
    required this.isMediaFiles,
    required this.index,
  });

  final bool isMediaFiles;
  final int index;
}

final class Loading extends ReportingStage {}
