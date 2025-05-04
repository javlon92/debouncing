part of 'mixins.dart';

/// [ThrottleStateMixin] for adding throttling (`throttle`) to [StatefulWidget].
///
/// Allows you to limit the frequency of actions, for example:
/// - when scrolling
/// - when entering text
/// - when making calls that require rare UI updates
///
/// ### Usage example:
///
/// ```dart
/// class MyWidget extends StatefulWidget {
///   const MyWidget({super.key});
///
///   @override
///   State<MyWidget> createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget> with ThrottleStateMixin {
///
///   Use `throttleParams` if you need your `ThrottleParams`
///   @override
///   ThrottleParams get throttleParams => const ThrottleParams(interval: Duration(milliseconds: 300),leading: false,trailing: true);
///
///   void onScroll() {
///     throttle(() {
///       // ...
///     });
///   }
///
///   @override
///   void dispose() {
///     throttle.dispose(); // ❌ The dispose method is called automatically when the [State] is closed, it's not necessary to close it manually.
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     // ...
///   }
///
/// }
/// ```
///
/// 🧼 The [dispose] method automatically calls [throttle.dispose()], which ensures that timers are cleared and resources are released.
///
mixin ThrottleStateMixin<T extends StatefulWidget> on State<T> {
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
