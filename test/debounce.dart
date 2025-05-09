part of 'debouncing_test.dart';

void runDebounce() {
  group('Debounce', () {
    late Debounce debounce;
    late int callCount;
    late VoidCallback callback;
    const delay = Duration(milliseconds: 100);

    setUp(() {
      callCount = 0;
      callback = () => callCount++;
    });

    tearDown(() {
      debounce.dispose();
    });

    test('should not call callback when leading and trailing are false', () {
      fakeAsync((async) {
        debounce = Debounce(
          delay: delay,
          leading: false,
          trailing: false,
        );

        debounce.call(callback);
        async.elapse(const Duration(milliseconds: 200));

        expect(callCount, equals(0));
        expect(debounce.isNotActive, isTrue);
      });
    });

    test('should call callback immediately with leading true', () {
      fakeAsync((async) {
        debounce = Debounce(
          delay: delay,
          leading: true,
          trailing: false,
        );

        debounce.call(callback);
        expect(callCount, equals(1));

        async.elapse(const Duration(milliseconds: 200));
        expect(callCount, equals(1));
      });
    });

    test('should call callback after delay with trailing true', () {
      fakeAsync((async) {
        debounce = Debounce(
          delay: delay,
          leading: false,
          trailing: true,
        );

        debounce.call(callback);
        expect(callCount, equals(0));

        async.elapse(const Duration(milliseconds: 150));
        expect(callCount, equals(1));
      });
    });

    test('should handle multiple rapid calls with leading true', () {
      fakeAsync((async) {
        debounce = Debounce(
          delay: delay,
          leading: true,
          trailing: false,
        );

        debounce.call(callback); // Immediate call
        debounce.call(callback); // Should be ignored
        debounce.call(callback); // Should be ignored
        expect(callCount, equals(1));

        async.elapse(const Duration(milliseconds: 150));
        expect(callCount, equals(1));
      });
    });

    test('should handle multiple rapid calls with trailing true', () {
      fakeAsync((async) {
        debounce = Debounce(
          delay: delay,
          leading: false,
          trailing: true,
        );

        debounce.call(callback);
        debounce.call(callback);
        debounce.call(callback);
        expect(callCount, equals(0));

        async.elapse(const Duration(milliseconds: 150));
        expect(callCount, equals(1));
      });
    });

    test('should handle leading and trailing together', () {
      fakeAsync((async) {
        debounce = Debounce(
          delay: delay,
          leading: true,
          trailing: true,
        );

        debounce.call(callback); // Immediate call (leading)
        expect(callCount, equals(1));

        debounce.call(callback); // Should reset timer
        debounce.call(callback); // Should reset timer
        async.elapse(const Duration(milliseconds: 150));
        expect(callCount, equals(2));
      }); // Trailing call
    });

    test('should reset correctly', () {
      fakeAsync((async) {
        debounce = Debounce(
          delay: delay,
          leading: false,
          trailing: true,
        );

        debounce.call(callback);
        expect(debounce.isTimerActive, isTrue);

        debounce.reset();
        expect(debounce.isTimerActive, isFalse);

        async.elapse(const Duration(milliseconds: 150));
        expect(callCount, equals(0));
      });
    });

    test('should flush correctly', () {
      fakeAsync((async) {
        debounce = Debounce(
          delay: delay,
          leading: false,
          trailing: true,
        );

        debounce.call(callback);
        expect(callCount, equals(0));

        debounce.flush();
        expect(callCount, equals(1));
        expect(debounce.isTimerActive, isFalse);

        async.elapse(const Duration(milliseconds: 150));
        expect(callCount, equals(1));
      });
    });

    test('should ignore calls after dispose', () {
      fakeAsync((async) {
        debounce = Debounce(
          delay: delay,
          leading: true,
          trailing: true,
        );

        debounce.dispose();
        expect(debounce.isNotActive, isTrue);

        debounce.call(callback);
        expect(callCount, equals(0));

        debounce.flush();
        expect(callCount, equals(0));

        async.elapse(const Duration(milliseconds: 150));
        expect(callCount, equals(0));
      });
    });

    test('should handle negative delay assertion', () {
      expect(
        () => Debounce(delay: const Duration(milliseconds: -100)),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should handle rapid sequential calls with leading and trailing', () {
      fakeAsync((async) {
        debounce = Debounce(
          delay: delay,
          leading: true,
          trailing: true,
        );

        debounce.call(callback); // Immediate call (leading)
        expect(callCount, equals(1));

        async.elapse(const Duration(milliseconds: 50));
        debounce.call(callback); // Should reset timer
        expect(callCount, equals(1));

        async.elapse(const Duration(milliseconds: 150));
        expect(callCount, equals(2));
      }); // Trailing call
    });
  });
}
