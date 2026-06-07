import 'dart:async';
import 'target_listener.dart';

class Store<S> {
  Store(S initialState) : _state = initialState;

  S _state;
  bool _isBatching = false;
  final List<TargetListener<S, dynamic>> _listeners = [];

  S get state => _state;

  void addListener(TargetListener<S, dynamic> listener) {
    _listeners.add(listener);
  }

  void removeListener(TargetListener<S, dynamic> listener) {
    _listeners.remove(listener);
  }

  void set(S Function(S state) updater) {
    _state = updater(_state);

    if (!_isBatching) {
      _isBatching = true;
      scheduleMicrotask(() {
        for (final listener in _listeners) {
          if (listener.updateAndCheck(_state)) {
            listener.onRebuild();
          }
        }
        _isBatching = false;
      });
    }
  }
}
