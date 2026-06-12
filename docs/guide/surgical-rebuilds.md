# Surgical Rebuilds

Pico is extremely fast because it natively prevents unnecessary rebuilds. 

## The Selector Pattern

By defining a `selector`, you tell Pico exactly which "slice" of the global state a widget cares about. 

```dart
PicoBuilder<AppState, String>(
  store: store,
  // This widget ONLY cares about the user's name
  selector: (state) => state.user.name,
  builder: (context, userName) {
    return Text('Hello, $userName!');
  },
)
```

If another action updates `state.count` or `state.themeColor`, the widget above is completely ignored!

## Microtask Batching

Under the hood, Pico uses an $O(1)$ Microtask Batching engine to intercept synchronous state spam. 

If you execute 10 synchronous state updates consecutively:
```dart
store.set((s) => s + 1);
store.set((s) => s + 1);
store.set((s) => s + 1);
// ...
```
Pico safely intercepts these and triggers exactly **one** UI rebuild per frame tick.

## Deep Equality

By default, Pico uses Dart's native equality (`==`) to check if a slice has changed. This is why we heavily recommend using Dart 3 **Records**, as they automatically evaluate deep equality.

However, if you are selecting complex Lists or Maps, you can provide a custom `equals` function:

```dart
PicoBuilder<AppState, List<User>>(
  store: store,
  selector: (state) => state.users,
  equals: (oldList, newList) => const ListEquality().equals(oldList, newList),
  builder: (context, users) => ListView(...),
)
```
