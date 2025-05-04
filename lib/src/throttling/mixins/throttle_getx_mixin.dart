part of 'mixins.dart';

/// [ThrottleGetXMixin] for adding throttling (`throttle`) to classes inheriting from [GetLifeCycleBase], such as [GetxController] or [GetxService].
///
/// Useful when it is necessary to limit the frequency of function execution:
/// - for fast-repeating events (for example, scroll, drag);
/// - for frequent user input, when the reaction to the first or last event is important.
///
/// ---
///
/// ### Usage example:
///
/// ```dart
/// class MyController extends GetxController with ThrottleGetXMixin {
///
///   Use `throttleParams` if you need your `ThrottleParams`
///   @override
///   ThrottleParams get throttleParams => const ThrottleParams(interval: Duration(milliseconds: 300),leading: false,trailing: true);
///
///   void onScroll(double offset) {
///     throttle(() {
///       print('Scroll position: $offset');
///       update()
///     });
///   }
///
///   @override
///   void onClose() {
///     throttle.dispose(); // ❌ The dispose method is called automatically when the [GetxController] or [GetxService] is closed, it's not necessary to close it manually.
///     super.onClose();
///   }
///
/// }
/// ```
///
/// 🧼 The [onClose] method automatically calls [throttle.dispose()], which ensures that timers are cleared and memory leaks are prevented.
///
/*
mixin ThrottleGetXMixin on GetLifeCycleBase {
  /// Parameters defining the behavior of [Throttle].
  ///
  /// It can be overridden in the class that uses the mixin.
  @protected
  @visibleForTesting
  ThrottleParams get throttleParams => const ThrottleParams();

  /// An instance of [Throttle] used to limit the frequency of calls.
  @protected
  @nonVirtual
  @visibleForTesting
  late final Throttle throttle = Throttle(
    interval: throttleParams.interval,
    leading: throttleParams.leading,
    trailing: throttleParams.trailing,
  );

  /// Closes [throttle] when [GetxController] is shut down.
  ///
  /// It is called automatically at [GetLifeCycleBase.onClose].
  @override
  @protected
  @mustCallSuper
  void onClose() {
    throttle.dispose(); // 🧼 automatically triggers, safe cleaning
    super.onClose();
  }
}
*/
