import 'dart:collection';

const _defaultMaxEntries = 1000;

class FixedSizeQueue<T> {
  FixedSizeQueue({this.maxEntries = _defaultMaxEntries});

  final int maxEntries;

  final Queue<T> _queue = ListQueue();

  Iterable<T> get entries => _queue;

  void add(T entry) {
    if (_queue.length > maxEntries) {
      _queue.removeFirst();
    }
    _queue.addLast(entry);
  }
}
