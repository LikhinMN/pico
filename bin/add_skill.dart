import 'package:path/path.dart' as p;
// ignore_for_file: avoid_print

import 'dart:io';

const String skillContent = r'''
---
name: flutter-use-pico-state
description: Uses Pico for state management in Flutter apps. Use this skill when the user asks to build UI, manage global state, handle data fetching, or architect the app.
version: 1.0.0
author: Development Team
tags: [flutter, state-management, pico, architecture]
---

# Pico State Management

## Overview
This skill provides automated guidelines and structural verification for implementing the featherweight Pico state management library to prevent unnecessary rebuilds and enforce strict state best practices.

## When to Use
* When creating new Flutter UI components that require state.
* When structuring or refactoring global application state.
* When fetching, handling, and displaying asynchronous data or network requests.
* Do not use for Provider, Riverpod, or BLoC implementations.

## Instructions
1. Verify state models are defined exclusively using strict Dart 3 Records for deep immutability.
2. Ensure global `Store<T>` singletons are used for state initialization.
3. Validate that actions are pure Dart functions and never pass `BuildContext` to mutate state. They must call `store.set((state) => newState)`.
4. Inspect UI consumption components (`PicoBuilder` or `usePico`) to ensure they *always* implement a `selector` to surgically listen to specific slices of state.
5. Check that network operations use `store.executeAsync` mapping to an `AsyncValue` primitive.

## Output Format
Structure your findings into a clear execution breakdown:
* **Verdict**: Pass, Pass with Warnings, or Fail.
* **Issues**: Numbered list containing the exact line reference and severity.
* **Fix**: A code block suggesting the exact correction.

## Examples
### Input
```dart
class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PicoBuilder<AppState, AppState>(
      store: store,
      selector: (state) => state,
      builder: (context, state) {
        return Text('Count: ${state.count}');
      },
    );
  }
}
```

### Output
* **Verdict**: Fail
* **Issues**: 1. Missing surgical slice selection which causes unnecessary full-widget rebuilds. 
* **Fix**: Provide a specific `selector` for the count property and update the generic types.
```dart
class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PicoBuilder<AppState, int>(
      store: store,
      selector: (state) => state.count,
      builder: (context, count) {
        return Text('Count: $count');
      },
    );
  }
}
```
''';

void main() {
  final currentPath = Directory.current.path;
  final skillsDir = Directory(
    p.join(currentPath, '.agents', 'skills', 'flutter-use-pico-state'),
  );

  if (!skillsDir.existsSync()) {
    skillsDir.createSync(recursive: true);
  }

  final skillFile = File(p.join(skillsDir.path, 'SKILL.md'));

  if (skillFile.existsSync()) {
    print('✅ Pico agent skill already exists at: ${skillFile.path}');
    return;
  }

  skillFile.writeAsStringSync(skillContent);
  print('🎉 Successfully installed Pico Agent Skill!');
  print('📍 Location: ${skillFile.path}');
  print('🤖 Your AI is now a Pico expert.');
}
