part of 'mixins.dart';

/// [DebounceNotifierMixin] for adding debounce (`debounce') to classes inheriting [ChangeNotifier].
///
/// Allows you to limit the frequency of method calls, for example:
/// - when entering text in search;
/// - when processing interface events (for example, scrolling);
/// - when changing the state depending on user input.
///
/// Used in 'ViewModel', 'Provider` and other classes inherited from 'ChangeNotifier'.
///
/// ---
///
/// ### Usage example:
///
/// ```dart
/// class MyProvider with ChangeNotifier, DebounceNotifierMixin {
///
///   Use `debounceParams` if you need your `DebounceParams`
///   @override
///   DebounceParams get debounceParams => const DebounceParams(delay: Duration(milliseconds: 300), leading: true, trailing: false);
///
///   void onSearchChanged(String query) {
///     debounce(() {
///       // ...
///       notifyListeners();
///     });
///   }
///
///   @override
///   void dispose() {
///     debounce.dispose(); // ❌ The dispose method is called automatically when the [ChangeNotifier] is closed, it's not necessary to close it manually.
///     super.dispose();
///   }
///
/// }
/// ```
///
/// 🧼 The [dispose] method automatically calls [debounce.dispose()], which ensures that timers are cleared and resources are released.
///
mixin DebounceNotifierMixin on ChangeNotifier {
  /// Parameters defining the behavior of [Debounce].
  ///
  /// It can be overridden in the class that uses the mixin.
  @protected
  @visibleForTesting
  DebounceParams get debounceParams => const DebounceParams();

  /// An instance of [Debounce], which is used to implement the delay.
  @protected
  @nonVirtual
  @visibleForTesting
  late final Debounce debounce = Debounce(
    delay: debounceParams.delay,
    leading: debounceParams.leading,
    trailing: debounceParams.trailing,
  );

  /// An overridden [dispose] method that automatically calls [debounce.dispose()] to safely clean up resources.
  @override
  @protected
  @mustCallSuper
  void dispose() {
    debounce.dispose(); // 🧼 automatically triggers, safe cleaning
    super.dispose();
  }
}
