import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;
  String _categoryFilter = "All";
  String _areaFilter = "All";


  int get selectedIndex => _selectedIndex;
  String get categoryFilter => _categoryFilter;
  String get areaFilter => _areaFilter;

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setCategoryAndNavigate(String category) {
    _categoryFilter = category;
    _areaFilter = "All";
    _selectedIndex = 1; // Go to Explore tab
    notifyListeners();
  }

  void setAreaAndNavigate(String area) {
    _areaFilter = area;
    _categoryFilter = "All";
    _selectedIndex = 1; // Go to Explore tab
    notifyListeners();
  }

  void resetFilters() {
    _categoryFilter = "All";
    _areaFilter = "All";
    notifyListeners();
  }
}