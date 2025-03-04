import 'package:snaply/src/logger/fixed_size_queue.dart';
import 'package:snaply/src/logger/log_record.dart';

class SnaplyLogger {
  SnaplyLogger._();

  static final SnaplyLogger _instance = SnaplyLogger._();

  static SnaplyLogger get instance => _instance;

  final FixedSizeQueue<LogRecord> _logsQueue = FixedSizeQueue();

  List<LogRecord> get logs => _logsQueue.entries.toList();

  void addLog({required String message}) {
    _logsQueue.add(
      LogRecord(
        timestamp: DateTime.timestamp(),
        message: message,
      ),
    );
  }
}
