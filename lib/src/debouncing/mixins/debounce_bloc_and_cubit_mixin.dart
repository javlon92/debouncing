part of 'mixins.dart';

/// [DebounceMixin] for adding debounce (`debounce') to [Block] or [Cubit].
///
/// Allows you to limit the frequency of actions, for example:
/// - when entering text in search
/// - when events are triggered frequently
/// - when updating the status with a delay
///
/// It is used in conjunction with [BlocBase], so it is suitable for both [Block] and [Cubit].
///
/// ### Usage example:
///
/// ```dart
/// class MyCubit extends Cubit<MyState> with DebounceMixin {
///   MyCubit() : super(const MyState());
///
///   Use `debounceParams` if you need your `DebounceParams`
///   @override
///   DebounceParams get debounceParams => const DebounceParams(delay: Duration(milliseconds: 300), leading: true, trailing: false);
///
///   void onTextChanged(String text) {
///     debounce(() {
///       emit(MyNewState());
///       // ...
///     });
///   }
///
///   @override
///   Future<void> close() {
///     debounce.dispose(); // ❌ The dispose method is called automatically when the [Cubit] is closed, it's not necessary to close it manually.
///     return super.close();
///   }
///
/// }
/// ```
/// ---
/// ```dart
/// class MyBloc extends Bloc<MyEvent, MyState> with DebounceMixin {
///   MyBloc() : super(MyState()) {
///     on<SearchTextChanged>(_onChanged);
///   }
///
///   Use `debounceParams` if you need your `DebounceParams`
///   @override
///   DebounceParams get debounceParams => const DebounceParams(delay: Duration(milliseconds: 300), leading: true, trailing: false);
///
///   void _onChanged(SearchTextChanged event, Emitter emit) {
///     debounce(() {
///       emit(MyNewState());
///       // ...
///     });
///   }
///
///   @override
///   Future<void> close() {
///     debounce.dispose(); // ❌ The dispose method is called automatically when the [Bloc] is closed, it's not necessary to close it manually.
///     return super.close();
///   }
///
/// }
/// ```
///
/// 🧼 The [close] method automatically calls [debounce.dispose()], which ensures that timers are cleared and resources are released.
///
/*
mixin DebounceMixin<T> on BlocBase<T> {
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

  /// Closes [debounce] when [Block] or [Cubit] is shut down.
  ///
  /// It is called automatically at [BlockBase.close].
  @override
  @protected
  @mustCallSuper
  Future<void> close() {
    debounce.dispose(); // 🧼 automatically triggers, safe cleaning
    return super.close();
  }
}
*/
