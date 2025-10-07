import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Discover Thousands\nof Books',
      description: 'Explore a vast collection of e-books across all genres and find your next favorite read.',
      icon: Icons.library_books_rounded,
      color: Color(0xFF64B5F6),
      backgroundColor: Color(0xFFE3F2FD),
    ),
    OnboardingData(
      title: 'Buy & Own\nForever',
      description: 'Purchase your favorite books and access them anytime, anywhere on any device.',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFF81C784),
      backgroundColor: Color(0xFFE8F5E9),
    ),
    OnboardingData(
      title: 'Read On\nAny Device',
      description: 'Sync your library across all your devices and continue reading seamlessly.',
      icon: Icons.devices_rounded,
      color: Color(0xFFFF8A65),
      backgroundColor: Color(0xFFFFE0B2),
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skipOnboarding() {
    _finishOnboarding();
  }

  void _finishOnboarding() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: _currentPage == index ? 32 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? _pages[_currentPage].color
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ),

            // Next/Get Started Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentPage].color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with background
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: data.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 100,
              color: data.color,
            ),
          ),

          const SizedBox(height: 60),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
              height: 1.3,
            ),
          ),

          const SizedBox(height: 20),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}