import 'package:flutter_test/flutter_test.dart';
import 'package:pico/pico.dart';

void main() {
  group('TargetListener', () {
    test(
      'updateAndCheck returns true if slice changes using default equality',
      () {
        int rebuildCount = 0;
        final listener = TargetListener<({int a, int b}), int>(
          selector: (s) => s.a,
          initialState: (a: 1, b: 2),
          onRebuild: () {
            rebuildCount++;
          },
        );

        // Should return false because 'a' is still 1
        final changed1 = listener.updateAndCheck((a: 1, b: 3));
        expect(changed1, false);
        expect(listener.cachedSlice, 1);

        // Should return true because 'a' changed to 2
        final changed2 = listener.updateAndCheck((a: 2, b: 3));
        expect(changed2, true);
        expect(listener.cachedSlice, 2);

        // We have to call onRebuild manually in this test since we are testing
        // the TargetListener class directly.
        listener.onRebuild();
        expect(rebuildCount, 1);
      },
    );

    test(
      'updateAndCheck returns true if slice changes using custom equals',
      () {
        final listener = TargetListener<({List<int> list}), List<int>>(
          selector: (s) => s.list,
          initialState: (list: [1, 2, 3]),
          equals: (oldList, newList) {
            if (oldList.length != newList.length) return false;
            for (int i = 0; i < oldList.length; i++) {
              if (oldList[i] != newList[i]) return false;
            }
            return true;
          },
          onRebuild: () {},
        );

        // Same content but different list instance
        final changed1 = listener.updateAndCheck((list: [1, 2, 3]));
        expect(changed1, false); // custom equals says it's the same

        // Different content
        final changed2 = listener.updateAndCheck((list: [1, 2, 4]));
        expect(changed2, true); // custom equals says it changed
      },
    );
  });
}
