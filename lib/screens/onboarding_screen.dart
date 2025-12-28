import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'main_wrapper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // DATA DEFINITION (Fixed: Removed the 'null' getter)
  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Discover\nFlavors",
      "subtitle": "Explore 60k+ premium recipes from\naround the world.",
      "image": "https://images.pexels.com/photos/1109197/pexels-photo-1109197.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    },
    {
      "title": "Master\nYour Kitchen",
      "subtitle": "Step-by-step guides to make you\nfeel like a professional chef.",
      "image": "https://images.pexels.com/photos/2403391/pexels-photo-2403391.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    },
    {
      "title": "Let's\nCooking",
      "subtitle": "Find the best recipes and start\nyour culinary journey today.",
      "image": "https://images.unsplash.com/photo-1572715376701-98568319fd0b?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8Y2hlZnxlbnwwfHwwfHx8MA%3D%3D",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Stack allows the background to be truly full-screen
      body: Stack(
        children: [
          // 1. FULL SCREEN BACKGROUND (Hamburger Style)
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: CachedNetworkImage(
                imageUrl: _onboardingData[_currentIndex]["image"]!,
                key: ValueKey<int>(_currentIndex),
                fit: BoxFit.cover, // Ensures it fills the phone screen
                height: double.infinity,
                width: double.infinity,
              ),
            ),
          ),

          // 2. GRADIENT OVERLAY
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 0.95],
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),

          // 3. UI LAYER (Interactive text and buttons)
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildPremiumTag(),
                const Spacer(),

                SizedBox(
                  height: 280,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentIndex = index),
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) => _buildPageText(index),
                  ),
                ),

                const SizedBox(height: 20),
                _buildIndicators(),
                const SizedBox(height: 40),

                _buildActionButton(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumTag() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.star, color: Colors.orange, size: 20),
      const SizedBox(width: 8),
      Text("60k+ Premium recipes", style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16)),
    ]);
  }

  Widget _buildPageText(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(children: [
        Text(_onboardingData[index]["title"]!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 54, fontWeight: FontWeight.bold, height: 1.1)),
        const SizedBox(height: 15),
        Text(_onboardingData[index]["subtitle"]!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 18)),
      ]),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 6, width: _currentIndex == index ? 28 : 8,
        decoration: BoxDecoration(
            color: _currentIndex == index ? const Color(0xFFE54646) : Colors.white38,
            borderRadius: BorderRadius.circular(10)),
      )),
    );
  }

  Widget _buildActionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        width: double.infinity, height: 65,
        child: ElevatedButton(
          onPressed: () {
            if (_currentIndex < 2) {
              _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
            } else {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainWrapper()));
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE54646),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_currentIndex == 2 ? "Start cooking" : "Next Step",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}