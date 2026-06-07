import 'dart:async';
import 'target_listener.dart';
import 'async_value.dart';

class Store<S> {
  Store(S initialState, {this.onUpdate}) : _state = initialState;

  S _state;
  bool _isBatching = false;
  final List<TargetListener<S, dynamic>> _listeners = [];
  final void Function(S oldState, S newState)? onUpdate;

  S get state => _state;

  void addListener(TargetListener<S, dynamic> listener) {
    _listeners.add(listener);
  }

  void removeListener(TargetListener<S, dynamic> listener) {
    _listeners.remove(listener);
  }

  void set(S Function(S state) updater) {
    final oldState = _state;
    _state = updater(_state);

    if (onUpdate != null) {
      onUpdate!(oldState, _state);
    }

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

  /// Executes an asynchronous [computation], automatically dispatching
  /// [AsyncLoading], [AsyncData], and [AsyncError] states to the provided [setter].
  Future<void> executeAsync<T>(
    Future<T> Function() computation,
    S Function(S state, AsyncValue<T> value) setter,
  ) async {
    set((state) => setter(state, AsyncLoading<T>()));
    try {
      final result = await computation();
      set((state) => setter(state, AsyncData<T>(result)));
    } catch (e, stack) {
      set((state) => setter(state, AsyncError<T>(e, stack)));
    }
  }
}
