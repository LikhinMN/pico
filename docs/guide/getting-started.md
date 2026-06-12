# Getting Started

Pico is extremely simple to install and set up in any Flutter project.

## Installation

Add Pico to your Flutter project via the command line:

```bash
flutter pub add pico
```

If you prefer to use Hooks (`flutter_hooks`), Pico has built-in hook support. Just make sure hooks is also installed:
```bash
flutter pub add flutter_hooks
```

## The 3-Minute Guide

### 1. Define your State
We highly recommend using Dart 3 Records for strict immutability and automatic deep equality:

```dart
import 'package:pico/pico.dart';

typedef AppState = ({
  int count,
  bool isDark,
});
```

### 2. Create the Store
Instantiate a global `Store` with your initial state.

```dart
final store = Store<AppState>((
  count: 0, 
  isDark: false,
));
```

### 3. Write an Action
Actions are just standard Dart functions. Call `store.set()` and return the new state. 

```dart
void increment() {
  store.set((state) => (
    count: state.count + 1, 
    isDark: state.isDark,
  ));
}
```

### 4. Consume in the UI
Wrap your UI slices with `PicoBuilder`.

```dart
class CounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PicoBuilder<AppState, int>(
          store: store,
          selector: (state) => state.count,
          builder: (context, count) {
            return Text('Count: $count');
          },
        ),
        ElevatedButton(
          onPressed: increment, 
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```
