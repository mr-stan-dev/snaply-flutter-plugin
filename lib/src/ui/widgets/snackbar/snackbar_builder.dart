import 'package:flutter/cupertino.dart';
import 'package:snaply/src/ui/state/info_event.dart';
import 'package:snaply/src/ui/widgets/snackbar/snackbar_error_message.dart';
import 'package:snaply/src/ui/widgets/snackbar/snackbar_plain_info.dart';
import 'package:snaply/src/ui/widgets/snackbar/upload_success_info_widget.dart';

class SnackbarWidgetBuilder {
  static Widget build(InfoEvent event) {
    switch (event) {
      case ReportUploadedEvent():
        return UploadSuccessInfoWidget(reportUrl: event.reportUrl);
      case ErrorEvent():
        return SnackbarErrorMessage(errorMsg: event.errorMsg);
      case PlainInfo():
        return SnackbarPlainInfo(infoMsg: event.infoMsg);
      case ClearAllWidgets():
        return const SizedBox.shrink();
    }
  }
}
