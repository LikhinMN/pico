import 'package:flutter/material.dart';
import 'package:pico/pico.dart';

typedef AppState = ({int count, bool isDark, AsyncValue<String> user});

final store = Store<AppState>((
  count: 0,
  isDark: false,
  user: const AsyncData('No user fetched yet'),
));

void increment() {
  store.set((s) => (count: s.count + 1, isDark: s.isDark, user: s.user));
}

void toggleTheme() {
  store.set((s) => (count: s.count, isDark: !s.isDark, user: s.user));
}

Future<void> fetchUser() async {
  store.set(
    (s) => (count: s.count, isDark: s.isDark, user: const AsyncLoading()),
  );
  await Future.delayed(const Duration(seconds: 2));
  store.set(
    (s) => (
      count: s.count,
      isDark: s.isDark,
      user: const AsyncData('Dash the Dart'),
    ),
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PicoBuilder<AppState, bool>(
      store: store,
      selector: (state) => state.isDark,
      builder: (context, isDark) {
        debugPrint('🎨 Theme Rebuilt');
        return MaterialApp(
          title: 'Pico Showcase',
          theme: isDark ? ThemeData.dark() : ThemeData.light(),
          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pico Showcase')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PicoBuilder<AppState, AsyncValue<String>>(
              store: store,
              selector: (state) => state.user,
              builder: (context, user) {
                return user.when(
                  data: (data) => Text(
                    data,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (err, stack) => Text('Error: $err'),
                );
              },
            ),
            const SizedBox(height: 32),
            PicoBuilder<AppState, int>(
              store: store,
              selector: (state) => state.count,
              builder: (context, count) {
                debugPrint('🔢 Counter Rebuilt');
                return Text(
                  '$count',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: fetchUser,
            heroTag: 'fetchUser',
            child: const Icon(Icons.person),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: toggleTheme,
            heroTag: 'toggleTheme',
            child: const Icon(Icons.brightness_6),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: increment,
            heroTag: 'increment',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
