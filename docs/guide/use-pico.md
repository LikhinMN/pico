# Hooks (`usePico`)

For developers who prefer using the `flutter_hooks` ecosystem, Pico provides a dedicated hook: `usePico`.

This hook offers zero-boilerplate, highly-performant state consumption. It behaves exactly like `PicoBuilder`, ensuring your `HookWidget` only rebuilds when its specific slice of state changes.

## Installation

Ensure you have both `pico` and `flutter_hooks` installed in your `pubspec.yaml`:

```bash
flutter pub add flutter_hooks
```

## API Signature

```dart
SliceType usePico<StoreType, SliceType>(
  Store<StoreType> store,
  SliceType Function(StoreType state) selector,
  [bool Function(SliceType oldSlice, SliceType newSlice)? equals]
)
```

## Detailed Parameters

1. **`store`**: The `Store` instance you want to subscribe to.
2. **`selector` (Required)**: A pure function that extracts the exact piece of data your widget needs from the store's state. The hook caches this value and will only trigger a widget rebuild if the extracted value changes.
3. **`equals` (Optional)**: A custom equality function. Pico defaults to Dart's `==` operator for change detection. If your slice is a complex object or a newly generated `List`/`Map`, you can provide a deep equality checker here to prevent unnecessary rebuilds.

## Basic Example

To use the hook, simply call it inside the `build` method of a `HookWidget`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pico/pico.dart';

// 1. Define State & Store
typedef AppState = ({ int count, String title });
final store = Store<AppState>((count: 0, title: 'Home'));

// 2. Consume with usePico
class CounterView extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // Subscribes this HookWidget exclusively to the 'count' property.
    // If 'title' changes, this widget will NOT rebuild.
    final count = usePico<AppState, int>(
      store, 
      (state) => state.count,
    );

    return Scaffold(
      body: Center(
        child: Text('Count: $count'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => store.set((s) => (
          count: s.count + 1, 
          title: s.title,
        )),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## Advanced: Custom Equality

If your selector returns a collection (like a `List` or `Map`), Dart's default `==` operator compares memory addresses, not contents. If an action creates a *new* list with the exact same items, Dart thinks it changed, causing an unnecessary rebuild.

Pass a custom `equals` comparator using `package:collection` to resolve this:

```dart
import 'package:collection/collection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pico/pico.dart';

class InventoryList extends HookWidget {
  @override
  Widget build(BuildContext context) {
    
    final items = usePico<AppState, List<String>>(
      store,
      (state) => state.items,
      // Deep-compare the list contents
      (oldList, newList) => const ListEquality().equals(oldList, newList),
    );

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) => Text(items[i]),
    );
  }
}
```
