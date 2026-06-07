import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'store.dart';
import 'target_listener.dart';

T usePico<S, T>(
  Store<S> store,
  T Function(S state) selector, {
  bool Function(T oldSlice, T newSlice)? equals,
}) {
  return use(_PicoHook<S, T>(store, selector, equals));
}

class _PicoHook<S, T> extends Hook<T> {
  const _PicoHook(this.store, this.selector, this.equals);

  final Store<S> store;
  final T Function(S state) selector;
  final bool Function(T oldSlice, T newSlice)? equals;

  @override
  _PicoHookState<S, T> createState() => _PicoHookState<S, T>();
}

class _PicoHookState<S, T> extends HookState<T, _PicoHook<S, T>> {
  late TargetListener<S, T> _listener;

  void _createListener() {
    _listener = TargetListener<S, T>(
      selector: hook.selector,
      onRebuild: () {
        setState(() {});
      },
      initialState: hook.store.state,
      equals: hook.equals,
    );
  }

  @override
  void initHook() {
    super.initHook();
    _createListener();
    hook.store.addListener(_listener);
  }

  @override
  void didUpdateHook(_PicoHook<S, T> oldHook) {
    super.didUpdateHook(oldHook);
    if (oldHook.store != hook.store) {
      oldHook.store.removeListener(_listener);
      _createListener();
      hook.store.addListener(_listener);
    }
  }

  @override
  void dispose() {
    hook.store.removeListener(_listener);
    super.dispose();
  }

  @override
  T build(BuildContext context) {
    return _listener.cachedSlice;
  }
}
