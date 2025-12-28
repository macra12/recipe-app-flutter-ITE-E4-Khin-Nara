import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'favourite_screen.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    FavouriteScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();

    return Scaffold(
      body: IndexedStack(
        index: navProvider.selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: BottomNavigationBar(
              currentIndex: navProvider.selectedIndex,
              onTap: (index) => navProvider.setIndex(index),
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Colors.orange[800],
              unselectedItemColor: Colors.grey[400],
              type: BottomNavigationBarType.fixed,
              showUnselectedLabels: true,
              items: [
                _buildNavItem(Icons.home_rounded, Icons.home_outlined, 'Home', 0, navProvider.selectedIndex),
                _buildNavItem(Icons.explore_rounded, Icons.explore_outlined, 'Explore', 1, navProvider.selectedIndex),
                _buildNavItem(Icons.favorite_rounded, Icons.favorite_border_rounded, 'Favourite', 2, navProvider.selectedIndex),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData activeIcon, IconData inactiveIcon, String label, int index, int currentIndex) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(inactiveIcon),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(activeIcon),
        ),
      ),
      label: label,
    );
  }
}