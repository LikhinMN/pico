# Async Data

Network requests and asynchronous operations are notoriously difficult to track in the UI. Instead of creating boilerplate flags like `bool isLoading`, `String? errorMessage`, and `User? data`, Pico ships natively with an `AsyncValue` primitive.

## The `AsyncValue<T>` Primitive

`AsyncValue` is a sealed class that can only exist in one of three states:
1. `AsyncLoading<T>()`: Represents an ongoing operation.
2. `AsyncData<T>(T value)`: Represents a successful operation with data.
3. `AsyncError<T>(Object error, [StackTrace? stackTrace])`: Represents a failed operation.

### Initializing State

To use it, wrap your desired data type in `AsyncValue` inside your state Record:

```dart
typedef AppState = ({ AsyncValue<User> userProfile });

final store = Store<AppState>((
  userProfile: const AsyncLoading(), // Default to loading state
));
```

## `store.executeAsync`

To perform a network request, use the `store.executeAsync` helper method. It automatically dispatches `AsyncLoading` before your Future starts, `AsyncData` if it succeeds, and `AsyncError` if it throws an exception.

### API Signature
```dart
Future<void> executeAsync<R>(
  Future<R> Function() action, 
  T Function(T state, AsyncValue<R> value) updateState
)
```

### Example
```dart
Future<void> fetchUser() async {
  await store.executeAsync<User>(
    // 1. The async operation (e.g. an HTTP request)
    () async {
      return await api.getUser();
    },
    
    // 2. The merge function: how to patch the result back into your state
    (state, asyncValue) {
      return (userProfile: asyncValue);
    },
  );
}
```

## Consuming in the UI

`AsyncValue` comes with a powerful set of methods to elegantly unpack the state in your UI.

### 1. Pattern Matching with `.when()`

The `.when()` method forces you to handle all three possible states, ensuring you never show a blank screen during a network error.

```dart
PicoBuilder<AppState, AsyncValue<User>>(
  store: store,
  selector: (state) => state.userProfile,
  builder: (context, userState) {
    return userState.when(
      loading: () => const CircularProgressIndicator(),
      data: (user) => Text('Welcome ${user.name}'),
      error: (err, stack) => Text('Failed to load user: $err'),
    );
  },
)
```

### 2. Extension Methods

If you don't want to use pattern matching, Pico provides convenient extension methods on `AsyncValue`:

#### `valueOrNull`
Returns the data if it exists, otherwise returns `null`. This is completely safe and will not throw an error.
```dart
final user = userState.valueOrNull;
if (user != null) {
  print(user.name);
}
```

#### `requireValue`
Returns the data if it exists. If the state is `AsyncLoading`, it throws a `StateError`. If the state is `AsyncError`, it rethrows the original error. Use this only when you are absolutely certain data exists.
```dart
try {
  final user = userState.requireValue;
  print(user.name);
} catch (e) {
  print('Failed to unpack data: $e');
}
```

#### `map<R>()`
Transforms an `AsyncValue<T>` into an `AsyncValue<R>`. It applies your transformation function *only* if the state is `AsyncData`. If the state is loading or error, it safely passes those states through without modifying them.
```dart
// Converts AsyncValue<User> into AsyncValue<String>
AsyncValue<String> userNameState = userState.map((user) => user.name);
```
