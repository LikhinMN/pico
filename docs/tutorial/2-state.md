# 2. Defining State

In Pico, you define your entire application state upfront using **Dart 3 Records**. Records are incredibly powerful because they are immutable and automatically handle deep equality for us.

## The Data Model

First, let's create a simple class for a single `Todo` item. Create a file called `todo.dart`.

```dart
// todo.dart
class Todo {
  final String id;
  final String title;
  final bool isCompleted;

  const Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  // A helper method to create a copy of the Todo with new values
  Todo copyWith({String? title, bool? isCompleted}) {
    return Todo(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
```

## The Global State

Next, we define our global state Record and initialize our `Store`. Let's create a `store.dart` file.

```dart
// store.dart
import 'package:pico/pico.dart';
import 'todo.dart';

// 1. Define the shape of our state using a Record
typedef AppState = ({
  List<Todo> todos,
  bool isLoading,
});

// 2. Initialize a global Store singleton
final store = Store<AppState>((
  todos: [], 
  isLoading: false,
));
```

That's it! No boilerplate classes, no `extends ChangeNotifier`, no complex annotations. Just a simple Record and a Store.

Next, let's build the UI that consumes this state.
