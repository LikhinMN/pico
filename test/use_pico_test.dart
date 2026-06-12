import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' hide Store;
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/pico.dart';

void main() {
  group('usePico Hook Tests', () {
    testWidgets('Renders correctly with initial state', (tester) async {
      final store = Store<int>(42);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HookBuilder(
              builder: (context) {
                final value = usePico(store, (state) => state);
                return Text('Value: $value');
              },
            ),
          ),
        ),
      );

      expect(find.text('Value: 42'), findsOneWidget);
    });

    testWidgets('Rebuilds when selected slice changes', (tester) async {
      final store = Store<({int a, int b})>((a: 0, b: 0));
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HookBuilder(
              builder: (context) {
                final value = usePico<({int a, int b}), int>(
                  store,
                  (state) => state.a,
                );
                buildCount++;
                return Text('A: $value');
              },
            ),
          ),
        ),
      );

      expect(find.text('A: 0'), findsOneWidget);
      expect(buildCount, 1);

      // Mutate unrelated slice 'b'
      store.set((s) => (a: s.a, b: s.b + 1));
      await tester.pumpAndSettle();

      // No rebuild should happen
      expect(buildCount, 1);

      // Mutate 'a'
      store.set((s) => (a: s.a + 1, b: s.b));
      await tester.pumpAndSettle();

      // Should rebuild
      expect(find.text('A: 1'), findsOneWidget);
      expect(buildCount, 2);
    });

    testWidgets('Handles store swap correctly (didUpdateHook)', (tester) async {
      final store1 = Store<int>(1);
      final store2 = Store<int>(10);

      final storeNotifier = ValueNotifier<Store<int>>(store1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<Store<int>>(
              valueListenable: storeNotifier,
              builder: (context, currentStore, _) {
                return HookBuilder(
                  builder: (context) {
                    final value = usePico<int, int>(
                      currentStore,
                      (state) => state,
                    );
                    return Text('Value: $value');
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Value: 1'), findsOneWidget);

      // Trigger change in store1
      store1.set((s) => 2);
      await tester.pumpAndSettle();
      expect(find.text('Value: 2'), findsOneWidget);

      // Swap to store2
      storeNotifier.value = store2;
      await tester.pumpAndSettle();
      expect(find.text('Value: 10'), findsOneWidget);

      // Change store1 (should be ignored)
      store1.set((s) => 3);
      await tester.pumpAndSettle();
      expect(find.text('Value: 10'), findsOneWidget);

      // Change store2 (should rebuild)
      store2.set((s) => 11);
      await tester.pumpAndSettle();
      expect(find.text('Value: 11'), findsOneWidget);
    });

    testWidgets('Respects custom equals function', (tester) async {
      final store = Store<List<int>>([1, 2, 3]);
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HookBuilder(
              builder: (context) {
                final value = usePico<List<int>, List<int>>(
                  store,
                  (state) => state,
                  equals: (List<int> oldList, List<int> newList) {
                    if (oldList.length != newList.length) return false;
                    for (int i = 0; i < oldList.length; i++) {
                      if (oldList[i] != newList[i]) return false;
                    }
                    return true;
                  },
                );
                buildCount++;
                return Text('Length: ${value.length}');
              },
            ),
          ),
        ),
      );

      expect(buildCount, 1);

      // Update with exact same elements (different list reference)
      store.set((s) => [1, 2, 3]);
      await tester.pumpAndSettle();

      // Shouldn't rebuild because custom equals returns true
      expect(buildCount, 1);

      // Update with different elements
      store.set((s) => [1, 2, 4]);
      await tester.pumpAndSettle();

      // Should rebuild
      expect(buildCount, 2);
    });
  });
}
