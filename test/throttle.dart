part of 'debouncing_test.dart';

void runThrottle() {
  group('Throttle', () {
    late Throttle throttle;
    const interval = Duration(milliseconds: 200);

    tearDown(() {
      throttle.dispose();
    });

    // Helper function to simulate calls with specific delays
    void simulateCalls(
      FakeAsync async,
      Throttle throttle,
      List<int> callTimesMs,
      Function(int) callback,
    ) {
      for (var i = 0; i < callTimesMs.length; i++) {
        async.elapse(Duration(milliseconds: callTimesMs[i]));
        throttle(() => callback(i + 1));
      }
    }

    test('should execute immediately with leading=true, trailing=false', () {
      fakeAsync((async) {
        throttle = Throttle(
          interval: interval,
          leading: true,
          trailing: false,
        );
        final calls = <int>[];

        simulateCalls(async, throttle, [0, 50, 100, 300, 350], calls.add);

        // Wait for any trailing calls to complete
        async.elapse(const Duration(milliseconds: 400));

        // Expected: calls at 0ms (1), 300ms (4) and 350ms (5)
        expect(calls, [1, 4, 5]);
      });
    });

    test('should execute at end of interval with leading=false, trailing=true', () {
      fakeAsync((async) {
        throttle = Throttle(
          interval: interval,
          leading: false,
          trailing: true,
        );
        final calls = <int>[];

        simulateCalls(async, throttle, [0, 50, 100, 300, 350], calls.add);

        // Wait for trailing calls to complete
        async.elapse(const Duration(milliseconds: 600));

        // Expected: calls at 200ms (3), 650ms (4) and 1000ms (5)
        expect(calls, [3, 4, 5]);
      });
    });

    test('should execute both leading and trailing with leading=true, trailing=true', () {
      fakeAsync((async) {
        throttle = Throttle(
          interval: interval,
          leading: true,
          trailing: true,
        );
        final calls = <int>[];

        simulateCalls(async, throttle, [0, 50, 100, 300, 350], calls.add);

        // Wait for trailing calls to complete
        async.elapse(const Duration(milliseconds: 600));

        // Expected: calls at 0ms (1), 200ms (3), 450ms (4), 800ms (5)
        expect(calls, [1, 3, 4, 5]);
      });
    });

    test('should not execute with leading=false, trailing=false', () {
      fakeAsync((async) {
        throttle = Throttle(
          interval: interval,
          leading: false,
          trailing: false,
        );
        final calls = <int>[];

        simulateCalls(async, throttle, [0, 50, 100, 300], calls.add);

        // Wait for any potential calls
        async.elapse(const Duration(milliseconds: 400));

        // Expected: no calls
        expect(calls, isEmpty);
      });
    });

    test('should reset timer and callback correctly', () {
      fakeAsync((async) {
        throttle = Throttle(
          interval: interval,
          leading: true,
          trailing: true,
        );
        final calls = <int>[];

        throttle(() => calls.add(1));
        async.elapse(const Duration(milliseconds: 50));
        throttle.reset();
        async.elapse(const Duration(milliseconds: 300));

        // Expected: only the first call, reset prevents trailing
        expect(calls, [1]);
      });
    });

    test('should flush pending callback immediately', () {
      fakeAsync((async) {
        throttle = Throttle(
          interval: interval,
          leading: false,
          trailing: true,
        );
        final calls = <int>[];

        throttle(() => calls.add(1));
        async.elapse(const Duration(milliseconds: 50));
        throttle(() => calls.add(2));
        throttle.flush();

        // Expected: second callback executed immediately
        expect(calls, [2]);
      });
    });

    test('should ignore calls after dispose', () {
      fakeAsync((async) {
        throttle = Throttle(
          interval: interval,
          leading: true,
          trailing: true,
        );
        final calls = <int>[];

        throttle.dispose();
        throttle(() => calls.add(1));
        async.elapse(const Duration(milliseconds: 300));

        // Expected: no calls after dispose
        expect(calls, isEmpty);
      });
    });

    test('should handle frequency-based constructors', () {
      fakeAsync((async) {
        throttle = Throttle.from60Hz(leading: true, trailing: false);
        final calls = <int>[];

        simulateCalls(async, throttle, [0, 10, 20, 30, 40], calls.add);

        // Wait for any potential calls (60Hz ~ 16.67ms interval)
        async.elapse(const Duration(milliseconds: 100));

        // Expected: calls at 0ms (1), 30ms (3), 60ms (4), and 70ms (5)
        expect(calls, [1, 3, 4, 5]);
      });
    });

    test('should throw assertion error for negative interval', () {
      expect(
        () => Throttle(interval: const Duration(milliseconds: -100)),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
