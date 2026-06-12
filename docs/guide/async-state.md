# Async Data

Network requests and asynchronous operations are notoriously difficult to track in the UI. Pico ships natively with an `AsyncValue` primitive to gracefully handle loading, data, and error states.

## `store.executeAsync`

Instead of manually setting loading flags, catching errors, and setting data, you can use `store.executeAsync`.

```dart
typedef AppState = ({ AsyncValue<User> user });
final store = Store<AppState>((user: AsyncLoading()));

Future<void> fetchUser() async {
  await store.executeAsync<User>(
    // 1. The async operation
    () async => await api.getUser(),
    
    // 2. How to merge it back into your state
    (state, asyncValue) => (user: asyncValue),
  );
}
```

## Consuming AsyncValue in UI

Elegantly unpack the state in your UI using the `.when()` pattern matcher:

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

## Extensions

Pico also provides helpful extensions on `AsyncValue` if you don't want to use pattern matching:
- `state.valueOrNull` (returns the data or null)
- `state.requireValue` (returns the data or throws the error)
- `state.map((data) => ...)` (transforms the data type)
