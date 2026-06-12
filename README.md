<p align="center">
  <img src="docs/public/logo.png" alt="Pico Logo" width="200" />
</p>

# Pico

Featherweight, zero-boilerplate state management for Flutter

[![pub package](https://img.shields.io/pub/v/pico.svg)](https://pub.dev/packages/pico)
[![downloads](https://img.shields.io/pub/dm/pico.svg)](https://pub.dev/packages/pico)
[![likes](https://img.shields.io/pub/likes/pico.svg)](https://pub.dev/packages/pico)
[![pub points](https://img.shields.io/pub/points/pico.svg)](https://pub.dev/packages/pico)

## Why Pico?

State management in Flutter has historically forced developers to choose between two extremes: drowning in the immense boilerplate and inherited complexity of BLoC and Provider, or battling the steep learning curve and constant code-generation steps required by modern solutions like Riverpod. Pico was built to offer a third path. 

Pico gives you robust, high-performance state management that stays entirely out of your way. Our core pillars are:
- **Zero Context Required:** Access and mutate state globally from any function, anywhere, without passing `BuildContext`.
- **Surgical Rebuilds:** Leverage high-performance slice caching. Your UI components only rebuild when their exact slice of state changes—never before.
- **Built-in Async State:** Safely manage complex network requests natively with our generic `AsyncValue` primitive.
- **Pure Dart:** No FFI, no code-generation (`build_runner`), and absolutely zero magic. Just simple, beautiful Dart code.

## Installation

```bash
flutter pub add pico
```

## Quick Start (The 3-Minute Guide)

Pico is so simple, you can learn it in three minutes. 

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
Wrap your UI slices with `PicoBuilder`. You can easily trigger your actions via standard callbacks.

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

*Prefer Hooks? We've got you covered with `usePico`:*
```dart
final count = usePico(store, (state) => state.count);
```

## Core Feature: Surgical Rebuilds (Slice Caching)

Pico is extremely fast because it natively prevents unnecessary rebuilds. By defining a `selector`, you tell Pico exactly which "slice" of the global state a widget cares about. 

```dart
PicoBuilder<AppState, String>(
  store: store,
  // This widget ONLY cares about the user's name
  selector: (state) => state.user.name,
  // If state.count updates, this widget is completely ignored!
  builder: (context, userName) {
    return Text('Hello, $userName!');
  },
)
```

Under the hood, Pico uses an O(1) Microtask Batching engine to intercept synchronous state spam and safely update the UI exactly once per frame tick. Need to compare complex lists or objects? Just pass a custom collection equality function to the optional `equals:` parameter.

## Core Feature: Async State Built-in

Network requests and asynchronous operations are notoriously difficult to track in the UI. Pico ships natively with an `AsyncValue` primitive inspired by the best in the ecosystem.

Track loading, data, and error states gracefully:
```dart
Future<void> fetchUser() async {
  store.set((s) => (..., user: AsyncLoading()));
  
  try {
    final data = await api.getUser();
    store.set((s) => (..., user: AsyncData(data)));
  } catch (err, stack) {
    store.set((s) => (..., user: AsyncError(err, stack)));
  }
}
```

Then, elegantly unpack the state in your UI using the `.when()` pattern matcher:
```dart
PicoBuilder<AppState, AsyncValue<User>>(
  store: store,
  selector: (state) => state.user,
  builder: (context, userState) {
    return userState.when(
      loading: () => const CircularProgressIndicator(),
      data: (user) => Text('Welcome ${user.name}'),
      error: (err, stack) => Text('Failed to load user: $err'),
    );
  },
)
```

## 🤖 Using Pico with AI Agents (Cursor, Copilot, etc.)

Because Pico is highly opinionated and featherweight, AI coding agents might guess your state architecture incorrectly if they haven't seen it before.

We've made it effortless to teach your AI exactly how to write Pico code:

**Option 1: `.cursorrules` / `.windsurfrules`**
Simply point your AI to our standard `llms.txt` file which contains high-density, AI-optimized instructions. Ask your AI to read `https://raw.githubusercontent.com/likhinmn/pico/main/llms.txt`.

**Option 2: Agent Skills**
If you are using an advanced Agent architecture (like DeepMind's coding agents), you can copy the `agent_skills/flutter-use-pico-state/` directory from this repository directly into your project's `.agents/skills/` folder. Your AI will automatically inherit Pico expertise!
