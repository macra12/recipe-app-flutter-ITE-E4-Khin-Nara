import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Define the global provider variable (This fixes your error)
final navigationProvider = StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});

// 2. Define a State class to hold your navigation data
class NavigationState {
  final int selectedIndex;
  final String categoryFilter;
  final String areaFilter;

  NavigationState({
    required this.selectedIndex,
    required this.categoryFilter,
    required this.areaFilter,
  });

  // Helper method to update the state easily
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

// 3. The Notifier class (Replaces ChangeNotifier)
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
      selectedIndex: 1, // requirement: Navigate to corresponding meal list [cite: 93]
    );
  }

  void setAreaAndNavigate(String area) {
    state = state.copyWith(
      areaFilter: area,
      categoryFilter: "All",
      selectedIndex: 1, // requirement: Go to Explore tab [cite: 94]
    );
  }

  void resetFilters() {
    state = state.copyWith(categoryFilter: "All", areaFilter: "All");
  }
}