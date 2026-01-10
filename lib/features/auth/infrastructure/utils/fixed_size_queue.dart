import 'dart:collection';

/// A queue with a fixed maximum size. When the size limit is reached,
/// the oldest element is removed before adding a new one.
class FixedSizeQueue<T> {
  final int maxSize;
  final ListQueue<T> _queue = ListQueue<T>();

  FixedSizeQueue(this.maxSize);

  void add(T element) {
    if (_queue.length == maxSize) {
      _queue.removeFirst();
    }
    _queue.add(element);
  }

  void remove(T element) => _queue.remove(element);
  void clear() => _queue.clear();
  bool contains(T element) => _queue.contains(element);
  int get length => _queue.length;
  T get first => _queue.first;
  T get last => _queue.last;
  bool get isEmpty => _queue.isEmpty;
  bool get isNotEmpty => _queue.isNotEmpty;
  List<T> toList() => _queue.toList();
  Set<T> toSet() => _queue.toSet();

  /// Returns an Iterable of elements that satisfy the predicate [test]
  Iterable<T> where(bool Function(T element) test) => _queue.where(test);
}
