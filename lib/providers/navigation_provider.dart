import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationProvider = StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});

class NavigationState {
  final int selectedIndex;
  final String categoryFilter;
  final String areaFilter;

  NavigationState({
    required this.selectedIndex,
    required this.categoryFilter,
    required this.areaFilter,
  });

  NavigationState copyWith({
    int? selectedIndex,
    String? categoryFilter,
    String? areaFilter,
  }) {
    return NavigationState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      areaFilter: areaFilter ?? this.areaFilter,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier()
      : super(NavigationState(
    selectedIndex: 0,
    categoryFilter: "All",
    areaFilter: "All",
  ));

  void setIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }

  void setCategoryAndNavigate(String category) {
    state = state.copyWith(
      categoryFilter: category,
      areaFilter: "All",
      selectedIndex: 1,
    );
  }

  void setAreaAndNavigate(String area) {
    state = state.copyWith(
      areaFilter: area,
      categoryFilter: "All",
      selectedIndex: 1,
    );
  }

  void resetFilters() {
    state = state.copyWith(categoryFilter: "All", areaFilter: "All");
  }
}