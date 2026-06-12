# Surgical Rebuilds & UI Integration

Pico is designed to be ridiculously fast. It achieves this by forcing developers to define exactly what "slice" of state a UI component cares about. If a different part of the global state updates, your component will not rebuild.

For standard Flutter widgets, you consume state using `PicoBuilder`. *(If you use `flutter_hooks`, see our dedicated [usePico Hooks Guide](/guide/use-pico)).*

## `PicoBuilder`

`PicoBuilder` is a highly-optimized Flutter Widget that connects your UI to a specific slice of a `Store`.

### API Signature
```dart
PicoBuilder<StoreType, SliceType>(
  store: Store<StoreType>,
  selector: SliceType Function(StoreType state),
  builder: Widget Function(BuildContext context, SliceType slice),
  equals: bool Function(SliceType oldSlice, SliceType newSlice)?,
)
```

### Detailed Properties
- **`store`**: The instance of the `Store` you want to listen to.
- **`selector` (Required)**: A pure function that extracts the specific data you need from the global state. The widget will *only* rebuild if the returned value changes.
- **`builder` (Required)**: Your standard Flutter builder function. It receives the `context` and the precise `slice` of data returned by the selector.
- **`equals` (Optional)**: A custom equality function. By default, Pico uses Dart's `==` operator. If your selector returns a mutable `List` or complex object, you can provide `(a, b) => const ListEquality().equals(a, b)` to prevent rebuilds.

### Example
```dart
PicoBuilder<AppState, String>(
  store: globalStore,
  // This widget ONLY cares about the user's name
  selector: (state) => state.user.name, 
  builder: (context, userName) {
    print('Rebuilding Name Widget!');
    return Text('Hello, $userName!');
  },
)
```

## Advanced: Custom Equality

If your state includes `List` or `Map` types, and you update them by creating new collections with identical contents, Dart's default `==` operator will return `false` (because the object references in memory are different). This will cause Pico to rebuild the widget.

To solve this, use the `equals` parameter:

```dart
import 'package:collection/collection.dart';

PicoBuilder<AppState, List<String>>(
  store: store,
  selector: (state) => state.inventoryItems,
  // Ensure we do a deep check of the list contents
  equals: (oldList, newList) => const ListEquality().equals(oldList, newList),
  builder: (context, items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) => Text(items[i]),
    );
  },
)
```
