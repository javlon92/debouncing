# Debounce, Throttle, BackOff

A lightweight Flutter package providing a simple [debounce, throttle, back off] utility to function calls, ideal for optimizing performance in event-driven application.

## Demo

| <img height=500 src="https://github.com/javlon92/debouncing/blob/master/example/assets/debounce_example.gif?raw=true"/> | <img height=500 src="https://github.com/javlon92/debouncing/blob/master/example/assets/throttle_example.gif?raw=true"/> |
|-------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|

## Features

- Simple and easy-to-use functionality with (`ThrottleMixins`, `DebounceMixins`). Mixins help you to close `Throttle` and `Debounce` automatically, and it's `not necessary` to close it manually.
- When using `debounceTransform` or `throttleTransform` in `Bloc`, you can now cancel the previous event using `ResettableEvent`.
- Configurable [`duration`, `leading`, `trailing`] in `Debounce` and `Throttle`.
- Configurable [`percentageRandomization`, `initialDelay`, `maxDelay`, `maxAttempts`, `retryIf`] in `BackOff`.
- Ideal for Flutter applications to handle rapid user inputs (e.g., search fields, button clicks).

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  debouncing: ^[latest_version]
```

Then run:

```bash
flutter pub get
```

## Usage Example


### event transformers for [Bloc]

```dart
import 'package:debouncing/debouncing.dart';

/// 👉 Usual example of event:
sealed class MyEvent {
  const MyEvent();
}

// final class OnSearchEvent extends MyEvent { 👉 // ⚠️ you can write without `ResettableEvent`
final class OnSearchEvent extends MyEvent with ResettableEvent { 👉 // ⚠️ ... with ResettableEvent, ... extends ResettableEvent, ... implements ResettableEvent
  @override
  final bool resetOnlyPreviousEvent;
  final String text;

  const OnSearchEvent({required this.text, this.resetOnlyPreviousEvent = false});
}

// final class OnScrollEvent extends MyEvent { 👉 // ⚠️ you can write without `ResettableEvent`
final class OnScrollEvent extends MyEvent with ResettableEvent { 👉 // ⚠️ ... with ResettableEvent, ... extends ResettableEvent, ... implements ResettableEvent
  @override
  final bool resetOnlyPreviousEvent;

  const OnScrollEvent({this.resetOnlyPreviousEvent = false});
}

----------------------------------------------------------------------------------------------------

/// 👉 Freezed example of event:
@freezed
abstract class MyEvent with _$MyEvent {

  // const factory MyEvent.onSearchEvent({ 👉 // ⚠️ you can write without `@Implements<ResettableEvent>()`
  @Implements<ResettableEvent>()
  const factory MyEvent.onSearchEvent({
    required String text,
    @Default(false) bool resetOnlyPreviousEvent,
  }) = OnSearchEvent;

  // const factory MyEvent.onScroll({ 👉 // ⚠️ you can write without `@Implements<ResettableEvent>()`
  @Implements<ResettableEvent>()
  const factory MyEvent.onScroll({
    @Default(false) bool resetOnlyPreviousEvent,
  }) = OnScrollEvent;
}

----------------------------------------------------------------------------------------------------

class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() : super(MyStateInitial()) {
    on<OnSearchEvent>(
      _onSearch,
      transformer: debounceTransform(
        delay: const Duration(milliseconds: 300),
        leading: false,
        trailing: true,
      ),
    );
    on<OnScrollEvent>(
      _onScroll,
      transformer: throttleTransform(
        interval: const Duration(milliseconds: 300),
        leading: true,
        trailing: false,
      ),
    );
  }

  void _onScroll(OnScroll event, Emitter emit) {
    // ...
  }

  void _onSearch(OnTextChanged event, Emitter emit) {
    // ...
  }
}
```

### mixin for [Bloc and Cubit]

```dart
import 'package:debouncing/debouncing.dart';

class MyBloc extends Bloc<MyEvent, MyState> with DebounceMixin, ThrottleMixin {
  MyBloc() : super(MyState()) {
    on<OnScroll>(_onScroll);
    on<OnTextChanged>(_onTextChanged);
  }

  void _onScroll(OnScroll event, Emitter emit) {
    throttle(() {
      emit(MyNewState());
      // ...
    });
  }

  void _onSearch(OnTextChanged event, Emitter emit) {
    debounce(() {
      emit(MyNewState());
      // ...
    });
  }
}

-------------------------------------------------------------------------------------------

class MyCubit extends Cubit<MyState> with DebounceMixin, ThrottleMixin {
  MyCubit() : super(const MyState());

  void onSearch(String text) {
    debounce(() {
      emit(MyNewState());
      // ...
    });
  }

  void onScroll() {
    throttle(() {
      emit(MyNewState());
      // ...
    });
  }
}

-------------------------------------------------------------------------------------------

/// 👉 You can write mixin for [Bloc] and [Cubit] like this.
/// If you need full version mixin with [Documentation] and [Usage example] for your project,
/// you can take it from file (lib/src/debouncing/mixins/debounce_bloc_and_cubit_mixin.dart)

mixin DebounceMixin<T> on BlocBase<T> {
  @protected
  @visibleForTesting
  DebounceParams get debounceParams => const DebounceParams();

  @protected
  @nonVirtual
  @visibleForTesting
  late final Debounce debounce = Debounce(
    delay: debounceParams.delay,
    leading: debounceParams.leading,
    trailing: debounceParams.trailing,
  );

  @override
  @protected
  @mustCallSuper
  Future<void> close() {
    debounce.dispose();
    return super.close();
  }
}

/// 👉 You can write mixin for [Bloc] and [Cubit] like this.
/// If you need full version mixin with [Documentation] and [Usage example] for your project,
/// you can take it from file (lib/src/throttling/mixins/throttle_bloc_and_cubit_mixin.dart)

mixin ThrottleMixin<T> on BlocBase<T> {
  @protected
  @visibleForTesting
  ThrottleParams get throttleParams => const ThrottleParams();

  @protected
  @nonVirtual
  @visibleForTesting
  late final Throttle throttle = Throttle(
    interval: throttleParams.interval,
    leading: throttleParams.leading,
    trailing: throttleParams.trailing,
  );

  @override
  @protected
  @mustCallSuper
  Future<void> close() {
    throttle.dispose();
    return super.close();
  }
}
```


### mixin for [Provider] and other classes inherited from 'ChangeNotifier'

```dart
import 'package:debouncing/debouncing.dart';

class MyProvider with ChangeNotifier, ThrottleNotifierMixin, DebounceNotifierMixin {

  void onScroll() {
    throttle(() {
      // ...
      notifyListeners();
    });
  }

  void onSearch(String query) {
    debounce(() {
      // ...
      notifyListeners();
    });
  }
}
```

### mixin for [StatefulWidget]

```dart
import 'package:flutter/material.dart';
import 'package:debouncing/debouncing.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with ThrottleStateMixin, DebounceStateMixin {

  void onScroll() {
    throttle(() {
      // ...
    });
  }

  void _onSearch(String value) {
    debounce(() {
      // ...
    });
  }

  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

### mixin for [GetX]

```dart
import 'package:debouncing/debouncing.dart';
import 'package:get/get.dart' hide debounce;

class MyController extends GetxController with DebounceGetXMixin, ThrottleGetXMixin {

  void onSearch(String query) {
    debounce(() {
      // ...
      update();
    });
  }

  void onScroll(String query) {
    throttle(() {
      // ...
      update();
    });
  }

}

/// 👉 You can write mixin for [GetxController] and [GetxService] like this.
/// If you need full version mixin with [Documentation] and [Usage example] for your project,
/// you can take it from file (lib/src/debouncing/mixins/debounce_getx_mixin.dart)

mixin DebounceGetXMixin on GetLifeCycleBase {
  @protected
  @visibleForTesting
  DebounceParams get debounceParams => const DebounceParams();

  @protected
  @nonVirtual
  @visibleForTesting
  late final Debounce debounce = Debounce(
    delay: debounceParams.delay,
    leading: debounceParams.leading,
    trailing: debounceParams.trailing,
  );

  @override
  @protected
  @mustCallSuper
  void onClose() {
    debounce.dispose();
    super.onClose();
  }
}

/// 👉 You can write mixin for [GetxController] and [GetxService] like this.
/// If you need full version mixin with [Documentation] and [Usage example] for your project,
/// you can take it from file (lib/src/throttling/mixins/throttle_getx_mixin.dart)

mixin ThrottleGetXMixin on GetLifeCycleBase {
  @protected
  @visibleForTesting
  ThrottleParams get throttleParams => const ThrottleParams();
  
  @protected
  @nonVirtual
  @visibleForTesting
  late final Throttle throttle = Throttle(
    interval: throttleParams.interval,
    leading: throttleParams.leading,
    trailing: throttleParams.trailing,
  );
  
  @override
  @protected
  @mustCallSuper
  void onClose() {
    throttle.dispose();
    super.onClose();
  }
}
```

## Reference

### `Debounce`, `Throttle` and EventTransformers [`debounceTransform`, `throttleTransform`] for `Bloc`

```dart
///     source.debounceTransform(delay: Duration(seconds: 1), leading: false, trailing: true); ✅ Good!
///     Config: leading: false, trailing: true
///     Input:  1-2-3---4---5-6-|
///     Output: ------3---4-----6|
///
///     source.debounceTransform(delay: Duration(seconds: 1), leading: true, trailing: false); ✅ Good!
///     Config: leading: true, trailing: false
///     Input:  1-2-3---4---5-6-|
///     Output: 1-------4---5---|
///
///     source.debounceTransform(delay: Duration(seconds: 1), leading: true, trailing: true); ✅ Good!
///     Config: leading: true, trailing: true
///     Input:  1-2-3---4---5-6-|
///     Output: 1-----3-4---5---6|
///
///     source.debounceTransform(delay: Duration(seconds: 1), leading: false, trailing: false); ❌ Bad! Output empty!
///     Config: leading: false, trailing: false
///     Input:  1-2-3---4---5-6-|
///     Output: ----------------|

    on<OnSearchEvent>(
      _onSearchEvent,
      transformer: debounceTransform(
        delay: const Duration(seconds: 1),
        leading: false,
        trailing: true,
      ),
    );

-----------------------------------------------------------------------------------------------------------------------

///     source.throttleTransform(interval: const Duration(seconds: 6), leading: true, trailing: false); ✅ Good!
///     Config: leading: true, trailing: false
///     Input:  1-2-3---4-5-6---7-8-|
///     Output: 1-------4-------7---|
///
///     source.throttleTransform(interval: const Duration(seconds: 6), leading: false, trailing: true); ✅ Good!
///     Config: leading: false, trailing: true
///     Input:  1-2-3---4-5----6--|
///     Output: ------3-----5-----6|
///
///     source.throttleTransform(interval: const Duration(seconds: 6),  leading: true, trailing: true); ✅ Good!
///     Config: leading: true, trailing: true
///     Input:  1-2-----3-----4|
///     Output: 1-----2-----3--|
///
///     source.throttleTransform(interval: const Duration(seconds: 6), leading: false, trailing: false); ❌ Bad! Output empty!
///     Config: leading: false, trailing: false
///     Input:  1-2-3---4-5----6--|
///     Output: -------------------|

    on<OnScrollEvent>(
      _onScrollEvent,
      transformer: throttleTransform(
        interval: const Duration(seconds: 6),
        leading: true,
        trailing: false,
      ),
    );

```

```dart
///     final _debounce = Debounce(delay: Duration(seconds: 1), leading: false, trailing: true); ✅ Good!
///     Config: leading: false, trailing: true
///     Input:  1-2-3---4---5-6-|
///     Output: ------3---4-----6|
///
///     final _debounce = Debounce(delay: Duration(seconds: 1), leading: true, trailing: false); ✅ Good!
///     Config: leading: true, trailing: false
///     Input:  1-2-3---4---5-6-|
///     Output: 1-------4---5---|
///
///     final _debounce = Debounce(delay: Duration(seconds: 1), leading: true, trailing: true); ✅ Good!
///     Config: leading: true, trailing: true
///     Input:  1-2-3---4---5-6-|
///     Output: 1-----3-4---5---6|
///
///     final _debounce = Debounce(delay: Duration(seconds: 1), leading: false, trailing: false); ❌ Bad! Output empty!
///     Config: leading: false, trailing: false
///     Input:  1-2-3---4---5-6-|
///     Output: ----------------|

final _debounce = Debounce();

-----------------------------------------------------------------------------------------------------------------------

///     final _throttle = Throttle(interval: const Duration(seconds: 6), leading: true, trailing: false); ✅ Good!
///     Config: leading: true, trailing: false
///     Input:  1-2-3---4-5-6---7-8-|
///     Output: 1-------4-------7---|
///
///     final _throttle = Throttle(interval: const Duration(seconds: 6), leading: false, trailing: true); ✅ Good!
///     Config: leading: false, trailing: true
///     Input:  1-2-3---4-5----6--|
///     Output: ------3-----5-----6|
///
///     final _throttle = Throttle(interval: const Duration(seconds: 6),  leading: true, trailing: true); ✅ Good!
///     Config: leading: true, trailing: true
///     Input:  1-2-----3-----4|
///     Output: 1-----2-----3--|
///
///     final _throttle = Throttle(interval: const Duration(seconds: 6), leading: false, trailing: false); ❌ Bad! Output empty!
///     Config: leading: false, trailing: false
///     Input:  1-2-3---4-5----6--|
///     Output: -------------------|

final _throttle = Throttle();

```

- `callback`: — The function to debounce or throttle.
- `interval`, `delay`: — the interval at which the function can be called
- `leading`: — If `true`, [callback] will be called on the first call before the interval expires.
- `trailing`: — If `true`, [callback] will be called after the interval ends
- `leading` && `trailing`: If both are `true`, [leading] `callback` will be called immediately before the interval expires and [trailing] `callback` will be called after the interval ends (if there were repeated calls)

### `BackOff`

[BackOff] is used for holding options for retrying a function.

```dart
/// With the default configuration functions will be retried up-to 7 times
/// (8 attempts in total), sleeping 1st, 2nd, 3rd, ..., 7th attempt:
///  1. 400 ms ± 25%
///  2. 800 ms ± 25%
///  3. 1600 ms ± 25%
///  4. 3200 ms ± 25%
///  5. 6400 ms ± 25%
///  6. 12800 ms ± 25%
///  7. 25600 ms ± 25%


  final response = await BackOff(
    () => http.get('https://google.com').timeout(
        const Duration(seconds: 10),
        ),
    retryIf: (error, stackTrace, attempt) => error is SocketException || error is TimeoutException,
    initialDelay: const Duration(milliseconds: 200),
    maxAttempts: 8,
    percentageRandomization: 0.25,
    maxDelay: const Duration(seconds: 30),
  ).call();

```

- `initialDelay`: — Defaults to 200 ms, which results in the following delays. Delay factor to double after every attempt.
- `percentageRandomization`: — Percentage the delay should be randomized, given as fraction between 0 and 1, (0.0 to 1.0 recommended). If [percentageRandomization] is `0.25` (default) this indicates 25 % of the delay should be increased or decreased by 25 %.
- `maxDelay`: — Maximum delay between retries, defaults to 30 seconds.
- `maxAttempts`: — Maximum number of attempts before giving up, defaults to 8.
- `retryIf`: — Function to determine if a retry should be attempted. If `null` (default) all errors will be retried.


## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Commit your changes (`git commit -m 'Add your feature'`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a Pull Request.


## Contacts

<a href="https://t.me/+998934505292"><img src="https://img.shields.io/badge/Telegram-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white" /></a>
<a href="https://www.linkedin.com/in/javlon-nurullayev-138219248/"><img src="https://img.shields.io/badge/linkedin-%230077B5.svg?style=for-the-badge&logo=linkedin&logoColor=white" /></a>
<a href="https://www.instagram.com/javlon_nurullayev"><img src="https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white" /></a>


For issues or suggestions, please open an issue on the [GitHub repository](https://github.com/javlon92/debouncing).

