# Pico ⚡

A high-performance, minimalist, and surgical state management library for Flutter and Dart.

## Why Pico?

- **Surgical Rebuilds**: Components only rebuild when their explicitly selected slice of state changes.
- **O(1) Microtask Batching**: Multiple synchronous state updates are batched together. The UI is rebuilt exactly once per frame tick.
- **Dart 3 Native**: Embraces Records, pattern matching, and sealed classes.
- **Hooks Integration**: Built-in adapter for `flutter_hooks` via `usePico`.
- **Zero Boilerplate**: Designed to stay out of your way. No code generation required.

## Quick Start

### 1. Define your State
Use Dart 3 Records for immutable, deeply-comparable state:

```dart
import 'package:pico/pico.dart';

typedef AppState = ({
  int count,
  bool isDark,
  AsyncValue<String> user,
});

final store = Store<AppState>((
  count: 0,
  isDark: false,
  user: const AsyncData('No user yet'),
));
```

### 2. Update State
```dart
void increment() {
  store.set((s) => (count: s.count + 1, isDark: s.isDark, user: s.user));
}

// Built-in Async resolution handling
Future<void> fetchUser() async {
  await store.executeAsync(
    () => Future.delayed(const Duration(seconds: 2), () => 'Dash'),
    (state, userAsyncVal) => (count: state.count, isDark: state.isDark, user: userAsyncVal),
  );
}
```

### 3. Consume State in UI
Wrap your UI slices with `PicoBuilder` to guarantee it only rebuilds when that specific property updates:

```dart
PicoBuilder<AppState, int>(
  store: store,
  selector: (state) => state.count,
  builder: (context, count) {
    return Text('$count'); // Rebuilds ONLY when state.count changes
  },
)
```

Or using `flutter_hooks`:

```dart
class HookExample extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final count = usePico(store, (state) => state.count);
    return Text('$count');
  }
}
```
