import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'favourite_screen.dart';
import 'dart:ui';

class MainWrapper extends ConsumerWidget {
  const MainWrapper({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    FavouriteScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navigationProvider);
    return Scaffold(

      backgroundColor: const Color(0xFF0F0F0F),
      extendBody: true,

      body: IndexedStack(
        index: navState.selectedIndex,
        children: _screens,
      ),

      bottomNavigationBar: _buildInterestingBottomBar(ref, navState.selectedIndex),
    );
  }

  Widget _buildInterestingBottomBar(WidgetRef ref, int currentIndex) {
    return Container(
      height: 90,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      decoration: BoxDecoration(
        // 1. Set a semi-transparent background color
        color: const Color(0xFF1E1E1E).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(30),
        // 2. Add a very subtle light border to enhance the "glass" edge
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      // 3. Use ClipRRect to ensure the blur doesn't bleed outside the rounded corners
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        // 4. The BackdropFilter applies the blur to whatever is BEHIND this bar
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCoolNavItem(ref, Icons.home_rounded, "Home", 0, currentIndex),
              _buildCoolNavItem(ref, Icons.explore_rounded, "Explore", 1, currentIndex),
              _buildCoolNavItem(ref, Icons.favorite_rounded, "Favourite", 2, currentIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoolNavItem(WidgetRef ref, IconData icon, String label, int index, int currentIndex) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(navigationProvider.notifier).setIndex(index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF9800).withValues(alpha: 0.15) : Colors.transparent, // FIXED: withValues
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? const Color(0xFFFF9800) : Colors.white70,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}