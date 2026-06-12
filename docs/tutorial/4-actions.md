# 4. Adding Actions

The final piece of the puzzle is mutating the state. 

In Pico, **Actions** are just standard Dart functions. You don't need a `BuildContext`, so you can write them anywhere in your app.

Let's open our `store.dart` file and add the functions to add and toggle todos.

```dart
// store.dart
import 'package:uuid/uuid.dart'; // flutter pub add uuid
import 'todo.dart';

// ... (Store initialization from Step 2)

// Action: Add a new Todo
void addTodo(String title) {
  final newTodo = Todo(
    id: const Uuid().v4(),
    title: title,
  );

  // Call store.set and return the new Record
  store.set((state) => (
    todos: [...state.todos, newTodo], 
    isLoading: state.isLoading,
  ));
}

// Action: Toggle completion
void toggleTodo(String id) {
  store.set((state) {
    // 1. Create a brand new list with the updated item
    final updatedTodos = state.todos.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(isCompleted: !todo.isCompleted);
      }
      return todo;
    }).toList();

    // 2. Return the new state
    return (
      todos: updatedTodos,
      isLoading: state.isLoading,
    );
  });
}
```

Now, wire these functions up to your UI buttons:

```dart
// Inside TodoList's Checkbox:
onChanged: (_) => toggleTodo(todo.id),

// Somewhere else in your UI:
FloatingActionButton(
  onPressed: () => addTodo('Learn Pico!'),
  child: const Icon(Icons.add),
)
```

---

## 🎉 Congratulations! 🎉

You have successfully built a lightning-fast, boilerplate-free Todo application using Pico!

By following these best practices, you achieved:
- **Global Accessibility**: Actions can be called from anywhere without context.
- **Surgical Rebuilds**: The header only rebuilds when the incomplete task count changes, even if you are typing in a text field elsewhere.
- **Immutability**: Safe, predictable state flow utilizing Dart 3 Records.

You are now ready to implement Pico in your production applications! Feel free to explore the [Core Concepts](/guide/store) to learn about Async State and Microtask Batching.
