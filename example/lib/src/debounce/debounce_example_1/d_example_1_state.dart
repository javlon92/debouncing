part of 'd_example_1_bloc.dart';

/*

@Freezed(
  equal: true,
  copyWith: true,
)
abstract class DebounceExample1State with _$DebounceExample1State {
  const factory DebounceExample1State({
    @Default(Status.initial) final Status withoutResettableTextStatus,
    @Default('') final String withoutResettableText,
    @Default(Status.initial) final Status withResettableTextStatus,
    @Default('') final String withResettableText,
  }) = _DebounceExample1State;
}

*/

class DebounceExample1State extends Equatable {
  final Status withoutResettableTextStatus;
  final String withoutResettableText;
  final Status withResettableTextStatus;
  final String withResettableText;

  const DebounceExample1State({
    this.withoutResettableTextStatus = Status.initial,
    this.withoutResettableText = '',
    this.withResettableTextStatus = Status.initial,
    this.withResettableText = '',
  });

  DebounceExample1State copyWith({
    Status? withoutResettableTextStatus,
    String? withoutResettableText,
    Status? withResettableTextStatus,
    String? withResettableText,
  }) {
    return DebounceExample1State(
      withoutResettableTextStatus: withoutResettableTextStatus ?? this.withoutResettableTextStatus,
      withoutResettableText: withoutResettableText ?? this.withoutResettableText,
      withResettableTextStatus: withResettableTextStatus ?? this.withResettableTextStatus,
      withResettableText: withResettableText ?? this.withResettableText,
    );
  }

  @override
  List<Object> get props => [
        withoutResettableTextStatus,
        withoutResettableText,
        withResettableTextStatus,
        withResettableText,
      ];
}
