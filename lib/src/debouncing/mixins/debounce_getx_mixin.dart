part of 'mixins.dart';

/// [DebounceGetXMixin] for adding debounce (`debounce') to classes inheriting [GetLifeCycleBase], for example [GetxController] or [GetxService].
///
/// Allows you to limit the frequency of function calls:
/// - when entering text (for example, in search);
/// - when state changes depend on user input;
/// - when responding to interface events (scroll, drag, etc.).
///
/// ---
///
/// ### Usage example:
///
/// ```dart
/// import 'package:get/get.dart' hide debounce;
///
/// class MyController extends GetxController with DebounceGetXMixin {
///
///   Use `debounceParams` if you need your `DebounceParams`
///   @override
///   DebounceParams get debounceParams => const DebounceParams(delay: Duration(milliseconds: 300), leading: true, trailing: false);
///
///   void onQueryChanged(String query) {
///     debounce(() {
///       // ...
///       update();
///     });
///   }
///
///   @override
///   void onClose() {
///     debounce.dispose(); // ❌ The dispose method is called automatically when the [GetxController] or [GetxService] is closed, it's not necessary to close it manually.
///     super.onClose();
///   }
///
/// }
/// ```
///
/// 🧼 The [onClose] method automatically calls [debounce.dispose()], which ensures that timers are cleared and resources are released at the end of the controller lifecycle.
///
/*
mixin DebounceGetXMixin on GetLifeCycleBase {
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

  /// Closes [debounce] when [GetxController] is shut down.
  ///
  /// It is called automatically at [GetLifeCycleBase.onClose].
  @override
  @protected
  @mustCallSuper
  void onClose() {
    debounce.dispose(); // 🧼 automatically triggers, safe cleaning
    super.onClose();
  }
}
*/
