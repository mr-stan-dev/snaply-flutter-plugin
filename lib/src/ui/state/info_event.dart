sealed class InfoEvent {
  const InfoEvent({
    this.autoHideDelay,
  });

  final Duration? autoHideDelay;
}

class ClearAllWidgets extends InfoEvent {}

class ReportUploadedEvent extends InfoEvent {
  ReportUploadedEvent(this.reportUrl);

  final String reportUrl;
}

class PlainInfo extends InfoEvent {
  PlainInfo(
    this.infoMsg, {
    super.autoHideDelay = const Duration(seconds: 3),
  });

  factory PlainInfo.short(String infoMsg) => PlainInfo(
        infoMsg,
        autoHideDelay: const Duration(seconds: 1),
      );

  factory PlainInfo.medium(String infoMsg) => PlainInfo(infoMsg);

  factory PlainInfo.long(String infoMsg) => PlainInfo(
        infoMsg,
        autoHideDelay: const Duration(seconds: 5),
      );

  final String infoMsg;
}

class ErrorEvent extends InfoEvent {
  ErrorEvent(this.errorMsg, {super.autoHideDelay});

  final String errorMsg;
}
