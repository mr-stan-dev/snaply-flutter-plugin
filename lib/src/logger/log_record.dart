class LogRecord {
  LogRecord({
    required this.timestamp,
    required this.message,
  });

  final DateTime timestamp;
  final String message;

  String get formattedTime =>
      "${(timestamp.year % 100).toString().padLeft(2, '0')}-"
      "${timestamp.month.toString().padLeft(2, '0')}-"
      "${timestamp.day.toString().padLeft(2, '0')} "
      "${timestamp.hour.toString().padLeft(2, '0')}:"
      "${timestamp.minute.toString().padLeft(2, '0')}:"
      "${timestamp.second.toString().padLeft(2, '0')}."
      "${timestamp.millisecond.toString().padLeft(3, '0')}";

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'timestamp': timestamp.toIso8601String(),
      'message': message,
    };
    return map;
  }
}
