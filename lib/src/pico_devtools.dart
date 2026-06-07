import 'dart:developer';

/// A middleware for [Store] that broadcasts state updates to the Dart VM Service.
///
/// This event stream can be intercepted by a custom Flutter DevTools extension
/// to visualize state history and enable time-travel debugging.
///
/// Usage:
/// ```dart
/// final store = Store(
///   initialState,
///   onUpdate: picoDevToolsMiddleware,
/// );
/// ```
void picoDevToolsMiddleware<S>(S oldState, S newState) {
  postEvent('pico:state_update', {
    'oldState': oldState.toString(),
    'newState': newState.toString(),
    'timestamp': DateTime.now().toIso8601String(),
  });
}
