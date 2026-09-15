class ExploreGroupState {
  final bool isExpanded;

  ExploreGroupState({required this.isExpanded});

  ExploreGroupState copyWith({bool? isExpanded}) {
    return ExploreGroupState(isExpanded: isExpanded ?? this.isExpanded);
  }
}
