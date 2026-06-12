# 3. Building the UI

Now that our `store` is initialized, let's connect it to the Flutter UI using `PicoBuilder`.

We are going to build two specific widgets to demonstrate Pico's **surgical rebuilds**:
1. A Header that *only* rebuilds when the count of incomplete tasks changes.
2. A List that *only* rebuilds when the `todos` array changes.

## The Header (Surgical Rebuild Example)

Let's use `PicoBuilder` to extract just the count of incomplete todos.

```dart
import 'package:flutter/material.dart';
import 'package:pico/pico.dart';
import 'store.dart';

class TodoHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PicoBuilder<AppState, int>(
      store: store,
      // 1. The selector isolates the exact data we need
      selector: (state) {
        return state.todos.where((t) => !t.isCompleted).length;
      },
      // 2. The builder receives that exact data
      builder: (context, incompleteCount) {
        print("Header Rebuilt!"); // This will only print when the count changes
        return Text(
          'You have $incompleteCount tasks remaining',
          style: Theme.of(context).textTheme.titleLarge,
        );
      },
    );
  }
}
```

## The Todo List

Next, let's build the actual list. Since we are selecting a `List` object, we should provide a custom `equals` comparator using `package:collection` to ensure Dart performs a deep-check on the list contents.

*(Note: Don't forget to run `flutter pub add collection`)*

```dart
import 'package:collection/collection.dart';

class TodoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PicoBuilder<AppState, List<Todo>>(
      store: store,
      selector: (state) => state.todos,
      
      // Deep-compare the list so we don't rebuild unnecessarily
      equals: (a, b) => const ListEquality().equals(a, b),
      
      builder: (context, todos) {
        if (todos.isEmpty) return const Text('No tasks yet!');

        return ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            return ListTile(
              title: Text(
                todo.title,
                style: TextStyle(
                  decoration: todo.isCompleted 
                      ? TextDecoration.lineThrough 
                      : null,
                ),
              ),
              leading: Checkbox(
                value: todo.isCompleted,
                onChanged: (bool? value) {
                  // We will add this action in the next step!
                },
              ),
            );
          },
        );
      },
    );
  }
}
```

Our UI is wired up and highly optimized! Now we just need to add interactivity.
