class CallbacksHolder {
  CallbacksHolder._();

  static final CallbacksHolder _instance = CallbacksHolder._();

  static CallbacksHolder get instance => _instance;

  Future<void> Function()? onReportReview;
}
