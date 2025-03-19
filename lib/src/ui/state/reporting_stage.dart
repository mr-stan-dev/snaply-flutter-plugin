sealed class ReportingStage {
  const ReportingStage();
}

final class Gathering extends ReportingStage {}

final class ViewingReport extends ReportingStage {}

final class ViewingFiles extends ReportingStage {
  const ViewingFiles({
    required this.isMediaFiles,
    required this.index,
  });

  final bool isMediaFiles;
  final int index;
}

final class Loading extends ReportingStage {
  const Loading._({
    required this.loadingMessage,
  });

  static const Loading preparing =
      Loading._(loadingMessage: 'Preparing report data');

  final String loadingMessage;
}
