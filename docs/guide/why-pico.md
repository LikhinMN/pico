# Why Pico?

State management in Flutter has historically forced developers to choose between two extremes:

1. **The Boilerplate Problem**: Drowning in the immense boilerplate and inherited complexity of `BLoC` or `Redux`.
2. **The Magic Problem**: Battling the steep learning curve and constant code-generation steps required by modern solutions like `Riverpod`.

Pico was built to offer a third path. 

## The Pico Philosophy

Pico gives you robust, high-performance state management that stays entirely out of your way. Our core pillars are:

- **Zero Context Required**: Access and mutate state globally from any function, anywhere, without passing `BuildContext`.
- **Surgical Rebuilds**: Leverage high-performance slice caching. Your UI components only rebuild when their exact slice of state changes—never before.
- **Built-in Async State**: Safely manage complex network requests natively with our generic `AsyncValue` primitive.
- **Pure Dart**: No FFI, no code-generation (`build_runner`), and absolutely zero magic. Just simple, beautiful Dart code.
