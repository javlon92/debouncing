part of 'debouncing_test.dart';

sealed class TestEvent {
  final String value;

  const TestEvent(this.value);
}

class TestUsualEvent extends TestEvent {
  const TestUsualEvent(super.value);
}

class TestResettableEvent extends TestEvent with ResettableEvent {
  @override
  final bool resetOnlyPreviousEvent;

  const TestResettableEvent(super.value, {this.resetOnlyPreviousEvent = false});
}

void runDebounceStreamTransformer() {
  group('DebounceStreamTransformer', () {
    late StreamController<TestEvent> controller;
    late List<TestEvent> results;
    const delay = Duration(milliseconds: 100);

    setUp(() {
      controller = StreamController<TestEvent>();
      results = [];
    });

    tearDown(() async {
      await controller.close();
    });

    test('emits trailing events after delay', () {
      fakeAsync((async) {
        final transformer = DebounceStreamTransformer<TestEvent>(
          delay: delay,
          leading: false,
          trailing: true,
        );

        controller.stream.transform(transformer).listen(results.add);

        controller.add(const TestUsualEvent('1'));
        controller.add(const TestUsualEvent('2'));
        controller.add(const TestUsualEvent('3'));

        async.elapse(const Duration(milliseconds: 150));

        expect(results.map((e) => e.value), equals(['3']));
      });
    });

    test('emits leading events immediately', () {
      fakeAsync((async) {
        final transformer = DebounceStreamTransformer<TestEvent>(
          delay: delay,
          leading: true,
          trailing: false,
        );

        controller.stream.transform(transformer).listen(results.add);

        controller.add(const TestUsualEvent('1'));
        controller.add(const TestUsualEvent('2'));

        async.elapse(const Duration(milliseconds: 150));

        expect(results.map((e) => e.value), equals(['1']));
      });
    });

    test('emits both leading and trailing events', () {
      fakeAsync((async) {
        final transformer = DebounceStreamTransformer<TestEvent>(
          delay: delay,
          leading: true,
          trailing: true,
        );

        controller.stream.transform(transformer).listen(results.add);

        controller.add(const TestUsualEvent('1'));
        controller.add(const TestUsualEvent('2'));
        async.elapse(const Duration(milliseconds: 120));
        controller.add(const TestUsualEvent('3'));

        async.elapse(const Duration(milliseconds: 150));

        expect(results.map((e) => e.value), equals(['1', '2', '3']));
      });
    });

    test('resets debounce with ResettableEvent', () {
      fakeAsync((async) {
        final transformer = DebounceStreamTransformer<TestEvent>(
          delay: delay,
          leading: false,
          trailing: true,
        );

        controller.stream.transform(transformer).listen(results.add);

        controller.add(const TestUsualEvent('1'));
        async.elapse(const Duration(milliseconds: 10));
        controller.add(const TestResettableEvent('reset', resetOnlyPreviousEvent: true));
        controller.add(const TestUsualEvent('2'));

        async.elapse(const Duration(milliseconds: 150));

        expect(results.map((e) => e.value), equals(['2']));
      });
    });

    test('ignores ResettableEvent with resetOnlyPreviousEvent', () {
      fakeAsync((async) {
        final transformer = DebounceStreamTransformer<TestEvent>(
          delay: delay,
          leading: false,
          trailing: true,
        );

        controller.stream.transform(transformer).listen(results.add);

        controller.add(const TestUsualEvent('1'));
        async.elapse(const Duration(milliseconds: 10));
        controller.add(const TestResettableEvent('reset', resetOnlyPreviousEvent: true));

        async.elapse(const Duration(milliseconds: 150));

        expect(results, isEmpty);
      });
    });

    test('handles empty stream', () {
      fakeAsync((async) {
        final transformer = DebounceStreamTransformer<TestEvent>(
          delay: delay,
          leading: false,
          trailing: true,
        );

        controller.stream.transform(transformer).listen(results.add);

        async.elapse(const Duration(milliseconds: 150));

        expect(results, isEmpty);
      });
    });

    test('cancels subscription properly', () {
      fakeAsync((async) {
        final transformer = DebounceStreamTransformer<TestEvent>(
          delay: delay,
          leading: false,
          trailing: true,
        );

        final subscription = controller.stream.transform(transformer).listen(results.add);

        controller.add(const TestUsualEvent('1'));
        subscription.cancel();
        controller.add(const TestUsualEvent('2'));

        async.elapse(const Duration(milliseconds: 150));

        expect(results, isEmpty);
      });
    });
  });
}
