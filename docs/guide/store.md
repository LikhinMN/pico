# Store & Actions

The `Store` is the core primitive of Pico. It acts as a synchronous, global container for your application state.

## Initialization

A `Store` requires a generic type `T` and an initial state value. We strongly recommend using Dart 3 **Records** to define your state, as they offer immutability and deep equality out-of-the-box.

```dart
typedef UserState = ({ String name, int age, bool isAuthenticated });

final userStore = Store<UserState>((
  name: 'Guest', 
  age: 0, 
  isAuthenticated: false,
));
```

## Reading State Synchronously

You can read the current state of the store at any time using the `state` getter:

```dart
final currentState = userStore.state;
print('Current user: ${currentState.name}');
```
*Note: Do not read `store.state` directly inside the `build` method of a Flutter widget. Instead, use `PicoBuilder` or `usePico` to ensure the widget properly listens for updates.*

## Mutating State (Actions)

To update the state, call `store.set()`. It takes a callback that receives the current state and returns the new state. 

Pico enforces immutability; you never mutate properties directly. Instead, you return a new Record (or object).

```dart
// A standard action
void authenticateUser(String newName, int newAge) {
  userStore.set((state) => (
    name: newName, 
    age: newAge, 
    isAuthenticated: true,
  ));
}

// Updating based on previous state
void celebrateBirthday() {
  userStore.set((state) => (
    name: state.name, 
    age: state.age + 1, 
    isAuthenticated: state.isAuthenticated,
  ));
}
```

### O(1) Microtask Batching
You can call `store.set()` as many times as you want synchronously. Pico utilizes an O(1) Microtask Batching engine. If you trigger 10 updates in a row synchronously, Pico intercepts them and will only dispatch **one** single update event to your listeners in the next microtask frame.

## Subscribing to State (Zustand-style)

Sometimes you need to listen to state changes outside of the Flutter UI tree (for example, to trigger analytics, route navigation, or persist data to local storage).

Pico provides two methods to subscribe to the store manually. Both return an `unsubscribe` callback.

### 1. `subscribeWithSelector` (Recommended)
This is the safest and most performant way to listen. You provide a `selector` so your callback is only triggered when a specific slice of the state changes.

```dart
final unsubscribe = userStore.subscribeWithSelector(
  // 1. Pick the slice
  selector: (state) => state.isAuthenticated,
  
  // 2. The callback (fires only when isAuthenticated changes)
  onUpdate: (isAuth, prevIsAuth) {
    if (isAuth) {
      router.go('/home');
    } else {
      router.go('/login');
    }
  },
  
  // Optional: Provide a custom equality function
  // equals: (a, b) => a == b,
  
  // Optional: Trigger the onUpdate callback instantly upon subscribing
  // fireImmediately: true, 
);

// To stop listening:
unsubscribe();
```

### 2. `subscribe` (Low-level)
If you want to listen to *every single update* dispatched by the store, you can pass a `TargetListener`. This is generally only used for low-level logging or debugging.

```dart
final unsubscribe = userStore.subscribe(
  TargetListener<UserState, UserState>(
    selector: (state) => state,
    onUpdate: (newState) {
      print('Global State Updated: $newState');
    },
  )
);
```
