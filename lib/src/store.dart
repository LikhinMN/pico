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
        try {
          for (final listener in _listeners.toList()) {
            if (listener.updateAndCheck(_state)) {
              listener.onRebuild();
            }
          }
        } finally {
          _isBatching = false;
        }
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

  /// Subscribes to the store to listen for state changes.
  ///
  /// The [listener] will be called whenever the state changes.
  /// If [fireImmediately] is true, the listener is called synchronously once upon subscription.
  /// Returns a function that can be called to unsubscribe.
  void Function() subscribe(
    void Function(S state, S previousState) listener, {
    bool fireImmediately = false,
  }) {
    S previousState = _state;

    late final TargetListener<S, S> targetListener;

    targetListener = TargetListener<S, S>(
      selector: (s) => s,
      initialState: _state,
      onRebuild: () {
        final currentState = targetListener.cachedSlice;
        listener(currentState, previousState);
        previousState = currentState;
      },
    );

    addListener(targetListener);

    if (fireImmediately) {
      listener(previousState, previousState);
    }

    return () {
      removeListener(targetListener);
    };
  }

  /// Subscribes to a specific slice of the store's state.
  ///
  /// The [listener] will only be called when the value returned by [selector] changes.
  /// If [fireImmediately] is true, the listener is called synchronously once upon subscription.
  /// Returns a function that can be called to unsubscribe.
  void Function() subscribeWithSelector<T>(
    void Function(T value, T previousValue) listener, {
    required T Function(S state) selector,
    bool Function(T a, T b)? equals,
    bool fireImmediately = false,
  }) {
    T previousSlice = selector(_state);

    late final TargetListener<S, T> targetListener;

    targetListener = TargetListener<S, T>(
      selector: selector,
      initialState: _state,
      equals: equals,
      onRebuild: () {
        final currentSlice = targetListener.cachedSlice;
        listener(currentSlice, previousSlice);
        previousSlice = currentSlice;
      },
    );

    addListener(targetListener);

    if (fireImmediately) {
      listener(previousSlice, previousSlice);
    }

    return () {
      removeListener(targetListener);
    };
  }
}
