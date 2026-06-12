# Store & Actions

The core of Pico revolves around the global `Store` and standalone actions.

## The Store

A `Store` is a simple container that holds your global application state. You initialize it with a default value.

```dart
typedef UserState = ({ String name, int age });

final userStore = Store<UserState>((name: 'Guest', age: 0));
```

You can have one massive global store (similar to Redux), or multiple smaller feature-based stores. Since Pico uses O(1) Slice Caching, both approaches are extremely fast.

## Actions

In Pico, **Actions** are just standard Dart functions. There is no `Action` class, no boilerplate, and no boilerplate classes to extend.

To update the state, you call `store.set()`.

```dart
void loginUser(String name, int age) {
  userStore.set((state) => (name: name, age: age));
}

void celebrateBirthday() {
  userStore.set((state) => (
    name: state.name, 
    age: state.age + 1,
  ));
}
```

Because Actions don't require `BuildContext`, you can call them from literally anywhere: UI buttons, background isolates, socket listeners, etc.

## Subscribing outside the UI

If you need to listen to state changes without a Flutter Widget (e.g. logging, analytics, or syncing to local storage), use `subscribe`:

```dart
final unsubscribe = userStore.subscribe((newState, oldState) {
  print('Age changed from ${oldState.age} to ${newState.age}');
});

// Stop listening
unsubscribe();
```
