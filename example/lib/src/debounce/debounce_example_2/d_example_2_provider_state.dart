part of 'd_example_2_provider.dart';

class DebounceExample2State extends Equatable {
  final Status withoutResettableTextStatus;
  final String withoutResettableText;
  final Status withResettableTextStatus;
  final String withResettableText;

  const DebounceExample2State({
    this.withoutResettableTextStatus = Status.initial,
    this.withoutResettableText = '',
    this.withResettableTextStatus = Status.initial,
    this.withResettableText = '',
  });

  DebounceExample2State copyWith({
    Status? withoutResettableTextStatus,
    String? withoutResettableText,
    Status? withResettableTextStatus,
    String? withResettableText,
  }) {
    return DebounceExample2State(
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
