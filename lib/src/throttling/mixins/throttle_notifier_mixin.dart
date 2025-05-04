part of 'mixins.dart';

/// [ThrottleNotifierMixin] for adding throttling (`throttle`) to [ChangeNotifier].
///
/// Used to limit the frequency of actions, for example:
/// - when events are triggered frequently
/// - when updating the state with a frequency limit
///
/// Used in 'ViewModel', 'Provider` and other classes inherited from 'ChangeNotifier'
///
/// ### Usage example:
///
/// ```dart
/// class MyProvider with ChangeNotifier, ThrottleNotifierMixin {
///
///   Use `throttleParams` if you need your `ThrottleParams`
///   @override
///   ThrottleParams get throttleParams => const ThrottleParams(interval: Duration(milliseconds: 300),leading: false,trailing: true);
///
///   void onUserAction() {
///     throttle(() {
///       // ...
///       notifyListeners();
///     });
///   }
///
///   @override
///   void dispose() {
///     throttle.dispose(); // ❌ The dispose method is called automatically when the [ChangeNotifier] is closed, it's not necessary to close it manually.
///     super.close();
///   }
///
/// }
/// ```
///
/// 🧼 The [dispose] method automatically calls [throttle.dispose()], which ensures that timers are cleared and resources are released.
///
mixin ThrottleNotifierMixin on ChangeNotifier {
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

  /// Automatically cleans up resources at [dispose].
  @override
  @protected
  @mustCallSuper
  void dispose() {
    throttle.dispose(); // 🧼 automatically triggers, safe cleaning
    super.dispose();
  }
}
