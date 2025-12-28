import 'package:flutter/material.dart';
import 'main_wrapper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (int page) => setState(() => _currentPage = page),
            children: [
              _buildFancyPage(
                gradient: const [Color(0xFFFF9800), Color(0xFFFF5722)],
                icon: Icons.restaurant_menu,
                title: "Discover Recipes",
                desc: "Explore a world of flavors with our curated list of global meals.",
              ),
              _buildFancyPage(
                gradient: const [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                icon: Icons.kitchen,
                title: "Cook with Ease",
                desc: "Follow simple, step-by-step instructions for a perfect meal.",
              ),
              _buildLastFancyPage(),
            ],
          ),
          Positioned(
            bottom: 40, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: List.generate(3, (index) => _buildIndicator(index))),
                _currentPage == 2
                    ? const SizedBox.shrink()
                    : TextButton(
                  onPressed: () => _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
                  child: const Text("NEXT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFancyPage({required List<Color> gradient, required IconData icon, required String title, required String desc}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: gradient)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(height: 40),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text(desc, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.white.withValues(alpha: 0.8), height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildLastFancyPage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2196F3), Color(0xFF1565C0)])),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite, size: 100, color: Colors.white),
          const SizedBox(height: 40),
          const Text("Get Cooking!", style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainWrapper())),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue[800], padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: const Text("GET STARTED", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 10, width: _currentPage == index ? 24 : 10,
      decoration: BoxDecoration(color: _currentPage == index ? Colors.white : Colors.white.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(5)),
    );
  }
}