import 'package:flutter_test/flutter_test.dart';
import 'package:pico/pico.dart';

void main() {
  test('Microtask Batching: 5 synchronous state updates trigger 1 rebuild', () async {
    final store = Store<int>(0);
    int rebuildCount = 0;

    final listener = TargetListener<int, int>(
      selector: (s) => s,
      onRebuild: () {
        rebuildCount++;
      },
      initialState: store.state,
    );

    store.addListener(listener);

    store.set((s) => s + 1);
    store.set((s) => s + 1);
    store.set((s) => s + 1);
    store.set((s) => s + 1);
    store.set((s) => s + 1);

    expect(rebuildCount, 0);

    await Future.microtask(() {});

    expect(rebuildCount, 1);
  });

  test('Surgical Rebuilds: updating an unrelated state property does not trigger the listener', () async {
    final store = Store<({int a, int b})>((a: 0, b: 0));
    int rebuildCount = 0;

    final listener = TargetListener<({int a, int b}), int>(
      selector: (s) => s.a,
      onRebuild: () {
        rebuildCount++;
      },
      initialState: store.state,
    );

    store.addListener(listener);

    store.set((s) => (a: s.a, b: s.b + 1));

    await Future.microtask(() {});

    expect(rebuildCount, 0);
  });
}
