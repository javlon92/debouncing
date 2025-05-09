part of 'debouncing_test.dart';

void runThrottleStreamTransformer() {
  group('ThrottleStreamTransformer', () {
    late StreamController<int> controller;
    late List<int> results;
    late Duration interval;

    setUp(() {
      controller = StreamController<int>();
      results = [];
      interval = const Duration(milliseconds: 500);
    });

    tearDown(() async {
      await controller.close();
    });

    test('emits only leading event (leading: true, trailing: false)', () {
      fakeAsync((async) {
        final transformer = ThrottleStreamTransformer<int>(
          interval: interval,
          leading: true,
          trailing: false,
        );

        controller.stream.transform(transformer).listen(results.add);

        controller.add(1);
        async.elapse(const Duration(milliseconds: 100));
        controller.add(2);
        controller.add(3);
        async.elapse(const Duration(milliseconds: 500));
        controller.add(4);
        async.elapse(const Duration(milliseconds: 100));
        controller.add(5);
        async.elapse(const Duration(milliseconds: 500));
        controller.add(6);
        async.elapse(const Duration(milliseconds: 100));

        async.elapse(const Duration(seconds: 1));

        expect(results, [1, 4, 6]);
      });
    });

    test('emits only trailing event (leading: false, trailing: true)', () {
      fakeAsync((async) {
        final transformer = ThrottleStreamTransformer<int>(
          interval: interval,
          leading: false,
          trailing: true,
        );

        controller.stream.transform(transformer).listen(results.add);

        controller.add(1);
        controller.add(2);
        async.elapse(const Duration(milliseconds: 300));
        controller.add(3);
        async.elapse(const Duration(milliseconds: 500));
        controller.add(4);
        async.elapse(const Duration(milliseconds: 100));
        controller.add(5);
        async.elapse(const Duration(milliseconds: 500));
        controller.add(6);
        async.elapse(const Duration(milliseconds: 600));

        async.elapse(const Duration(seconds: 1));

        expect(results, [3, 5, 6]);
      });
    });

    test('emits both leading and trailing events (leading: true, trailing: true)', () {
      fakeAsync((async) {
        final transformer = ThrottleStreamTransformer<int>(
          interval: interval,
          leading: true,
          trailing: true,
        );

        controller.stream.transform(transformer).listen(results.add);

        controller.add(1);
        async.elapse(const Duration(milliseconds: 100));
        controller.add(2);
        async.elapse(const Duration(milliseconds: 500));
        controller.add(3);
        async.elapse(const Duration(milliseconds: 100));
        controller.add(4);

        async.elapse(const Duration(seconds: 1));

        expect(results, [1, 2, 4]);
      });
    });

    test('emits nothing if leading: false and trailing: false', () {
      fakeAsync((async) {
        final transformer = ThrottleStreamTransformer<int>(
          interval: interval,
          leading: false,
          trailing: false,
        );

        controller.stream.transform(transformer).listen(results.add);

        controller.add(1);
        controller.add(2);
        async.elapse(const Duration(milliseconds: 500));
        controller.add(3);
        async.elapse(const Duration(milliseconds: 500));

        async.elapse(const Duration(seconds: 1));

        expect(results, isEmpty);
      });
    });
  });
}
