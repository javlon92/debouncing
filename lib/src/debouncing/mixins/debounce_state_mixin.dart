part of 'mixins.dart';

/// [DebounceStateMixin] for adding debounce (`debounce') to [StatefulWidget].
///
/// This mixin adds debounce support to the [State] widget state. It allows
/// you to limit the number of triggers of functions that process frequently occurring
/// events, such as text input or scrolling, using a delay.
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
/// class _MyWidgetState extends State<MyWidget> with DebounceStateMixin {
///
///   Use `debounceParams` if you need your `DebounceParams`
///   @override
///   DebounceParams get debounceParams => const DebounceParams(delay: Duration(milliseconds: 300), leading: true, trailing: false);
///
///   void _onTextChanged(String value) {
///     debounce(() {
///       // ...
///     });
///   }
///
///   @override
///   void dispose() {
///     debounce.dispose(); // ❌ The dispose method is called automatically when the [State] is closed, it's not necessary to close it manually.
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
/// 🧼 The [dispose] method automatically calls [debounce.dispose()], which ensures that timers are cleared and resources are released.
///
mixin DebounceStateMixin<T extends StatefulWidget> on State<T> {
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
