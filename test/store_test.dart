import 'package:flutter_test/flutter_test.dart';
import 'package:pico/pico.dart';

void main() {
  test(
    'Microtask Batching: 5 synchronous state updates trigger 1 rebuild',
    () async {
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
    },
  );

  test(
    'Surgical Rebuilds: updating an unrelated state property does not trigger the listener',
    () async {
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
    },
  );

  test(
    'Store.subscribe: triggers when state changes and can unsubscribe',
    () async {
      final store = Store<int>(0);
      int callCount = 0;
      int lastState = -1;
      int lastPrevState = -1;

      final unsubscribe = store.subscribe((state, prevState) {
        callCount++;
        lastState = state;
        lastPrevState = prevState;
      });

      store.set((s) => s + 1);
      await Future.microtask(() {});

      expect(callCount, 1);
      expect(lastState, 1);
      expect(lastPrevState, 0);

      store.set((s) => s + 1);
      await Future.microtask(() {});

      expect(callCount, 2);
      expect(lastState, 2);
      expect(lastPrevState, 1);

      unsubscribe();

      store.set((s) => s + 1);
      await Future.microtask(() {});

      expect(callCount, 2, reason: 'Should not trigger after unsubscribe');
    },
  );

  test('Store.subscribe: fireImmediately works correctly', () async {
    final store = Store<int>(5);
    int callCount = 0;
    int lastState = -1;
    int lastPrevState = -1;

    store.subscribe((state, prevState) {
      callCount++;
      lastState = state;
      lastPrevState = prevState;
    }, fireImmediately: true);

    expect(callCount, 1);
    expect(lastState, 5);
    expect(lastPrevState, 5);
  });

  test(
    'Store.subscribeWithSelector: only triggers when selected slice changes',
    () async {
      final store = Store<({int a, int b})>((a: 0, b: 0));
      int callCount = 0;
      int lastState = -1;
      int lastPrevState = -1;

      store.subscribeWithSelector<int>((aValue, prevAValue) {
        callCount++;
        lastState = aValue;
        lastPrevState = prevAValue;
      }, selector: (s) => s.a);

      // Change 'b', should not trigger
      store.set((s) => (a: s.a, b: s.b + 1));
      await Future.microtask(() {});
      expect(callCount, 0);

      // Change 'a', should trigger
      store.set((s) => (a: s.a + 1, b: s.b));
      await Future.microtask(() {});
      expect(callCount, 1);
      expect(lastState, 1);
      expect(lastPrevState, 0);
    },
  );

  test('Store.onUpdate: fires synchronously before microtask', () {
    int onUpdateCallCount = 0;
    int lastOldState = -1;
    int lastNewState = -1;

    final store = Store<int>(
      0,
      onUpdate: (oldState, newState) {
        onUpdateCallCount++;
        lastOldState = oldState;
        lastNewState = newState;
      },
    );

    store.set((s) => 42);

    expect(onUpdateCallCount, 1);
    expect(lastOldState, 0);
    expect(lastNewState, 42);
  });

  test(
    'Store.executeAsync: dispatches loading, data, and error states',
    () async {
      final store = Store<AsyncValue<String>>(const AsyncLoading());
      final states = <AsyncValue<String>>[];

      store.subscribe((state, prevState) {
        states.add(state);
      });

      // Test success
      await store.executeAsync<String>(
        () async => 'Success',
        (state, value) => value,
      );
      await Future.microtask(() {});

      expect(states.length, 2);
      expect(states[0], isA<AsyncLoading<String>>());
      expect(states[1], isA<AsyncData<String>>());
      expect(states[1].valueOrNull, 'Success');

      states.clear();

      // Test error
      await store.executeAsync<String>(
        () async => throw Exception('Failed'),
        (state, value) => value,
      );
      await Future.microtask(() {});

      expect(states.length, 2);
      expect(states[0], isA<AsyncLoading<String>>());
      expect(states[1], isA<AsyncError<String>>());

      states[1].when(
        data: (_) => fail('Should be error'),
        error: (err, stack) => expect(err, isA<Exception>()),
        loading: () => fail('Should be error'),
      );
    },
  );

  test('Store.removeListener: stops dispatching updates', () async {
    final store = Store<int>(0);
    int callCount = 0;

    final listener = TargetListener<int, int>(
      selector: (s) => s,
      onRebuild: () {
        callCount++;
      },
      initialState: store.state,
    );

    store.addListener(listener);

    store.set((s) => s + 1);
    await Future.microtask(() {});
    expect(callCount, 1);

    store.removeListener(listener);

    store.set((s) => s + 1);
    await Future.microtask(() {});
    expect(callCount, 1, reason: 'Should not increment after removeListener');
  });
}
