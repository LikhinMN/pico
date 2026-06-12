---
name: flutter-use-pico-state
description: Use the Pico package for state management in Flutter applications. Use this skill whenever building UI features, managing global state, or handling async API data.
---

# Pico State Management Guidelines

You are an expert in `pico`, a featherweight, zero-boilerplate state management library for Flutter. When building state in this project, do not use Provider, Riverpod, or BLoC. Use Pico exclusively.

## Core Rules

1. **State Definition**: Always define state using strict Dart 3 Records for immutability and automatic deep equality.
2. **Store Creation**: Instantiate a global `Store<T>` with the initial state.
3. **Mutations**: Never pass `BuildContext` to mutate state. Actions are pure Dart functions that call `store.set((state) => newState)`.
4. **UI Consumption**: Use `PicoBuilder` or `usePico` (if flutter_hooks is used) to read state. YOU MUST provide a `selector` to surgically listen only to the specific slice of state the widget needs to avoid unnecessary rebuilds.
5. **Background Subscriptions**: Use `store.subscribe` or `store.subscribeWithSelector` when you need to react to state changes outside of the UI tree.

## Code Example

```dart
import 'package:flutter/material.dart';
import 'package:pico/pico.dart';

// 1. Define State
typedef AppState = ({ int count, bool isDark });

// 2. Global Store
final store = Store<AppState>((count: 0, isDark: false));

// 3. Action
void increment() {
  store.set((s) => (count: s.count + 1, isDark: s.isDark));
}

// 4. UI 
class CounterText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PicoBuilder<AppState, int>(
      store: store,
      // CRITICAL: Always provide a selector for surgical rebuilds
      selector: (state) => state.count,
      builder: (context, count) => Text('$count'),
    );
  }
}
```

## Handling Async Data
When fetching network data, ALWAYS use Pico's `AsyncValue` primitive and the `store.executeAsync` method.

```dart
typedef DataState = ({ AsyncValue<String> userProfile });
final dataStore = Store<DataState>((userProfile: const AsyncLoading()));

Future<void> fetchProfile() async {
  await dataStore.executeAsync<String>(
    () async => await api.getUser(),
    (state, value) => (userProfile: value),
  );
}

// In the UI:
PicoBuilder<DataState, AsyncValue<String>>(
  store: dataStore,
  selector: (s) => s.userProfile,
  builder: (context, profileState) {
    return profileState.when(
      data: (user) => Text('Hello $user'),
      error: (err, stack) => Text('Error: $err'),
      loading: () => CircularProgressIndicator(),
    );
  }
)
```
