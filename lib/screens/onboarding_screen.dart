import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'subtitle': 'Your Campus Marketplace',
      'image': 'assets/images/marketplace_vector.png',
      'description':
          'Welcome to your campus marketplace.\nDiscover a faster, smarter way to campus life.',
    },
    {
      'subtitle': 'Discover with MarketMap',
      'image': 'assets/images/Share_location.png',
      'description':
          'See vendor clusters around campus and\nfind what\'s near you.',
    },
    {
      'subtitle': 'Ready to get started?',
      'image': 'assets/images/Shopping_online.png',
      'description':
          'Order anything on campus such as food, \nessentials, and more all in one app.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // ── DESKTOP ADAPTATION START ──
    // Detect screen width to switch between mobile and desktop layouts
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 800;
    // ── DESKTOP ADAPTATION END ──

    return Scaffold(
      backgroundColor: AppColors.text,
      body: SafeArea(
        child: isDesktop
            // ── DESKTOP ADAPTATION START ──
            // Desktop: two-column layout (branding left, content right)
            ? _buildDesktopLayout()
            // ── DESKTOP ADAPTATION END ──
            : _buildMobileLayout(),
      ),
    );
  }

  // ── DESKTOP ADAPTATION START ──
  // Desktop layout: logo/branding on the left, page content on the right
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left panel — fixed branding sidebar
        Expanded(
          flex: 4,
          child: Container(
            color: AppColors.waveClr,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/swiftly-txt.png',
                  width: 160,
                  height: 160,
                ),
                const SizedBox(height: 24),
                Text(
                  'Campus life,\nsimplified.',
                  style: AppTypography.headline.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Order food, find vendors,\nand more — all in one place.',
                  style: AppTypography.body.copyWith(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        // Right panel — page content
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Page content area
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() => _currentPage = page);
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Illustration
                          SizedBox(
                            height: 240,
                            width: 240,
                            child: Image.asset(
                              _pages[index]['image']!,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Subtitle
                          Text(
                            _pages[index]['subtitle']!,
                            style: AppTypography.title.copyWith(
                              color: AppColors.primary,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          // Description
                          Text(
                            _pages[index]['description']!,
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Dots indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentPage == index
                            ? AppColors.accent
                            : AppColors.secondary.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Next / Get Started button
                SizedBox(
                  width: 280,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pushReplacementNamed(context, '/signup');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(
                        color: AppColors.prof,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Skip / Login links
                if (_currentPage < _pages.length - 1)
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/signup');
                    },
                    child: Text(
                      'Skip',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                if (_currentPage == _pages.length - 1) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text(
                          'Login',
                          style: AppTypography.body.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
  // ── DESKTOP ADAPTATION END ──

  // Original mobile layout — unchanged
  Widget _buildMobileLayout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/swiftly-txt.png',
                width: 120,
                height: 120,
              ),
            ],
          ),
        ),

        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _pages[index]['subtitle']!,
                      style: AppTypography.title.copyWith(
                        color: AppColors.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      height: 200,
                      width: 200,
                      child: Image.asset(
                        _pages[index]['image']!,
                        width: 200,
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 40),

                    Text(
                      _pages[index]['description']!,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == index
                          ? AppColors.accent
                          : AppColors.secondary.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pushReplacementNamed(context, '/signup');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      color: AppColors.prof,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (_currentPage < _pages.length - 1)
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/signup');
                  },
                  child: Text(
                    'Skip',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              if (_currentPage == _pages.length - 1) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                      child: Text(
                        'Login',
                        style: AppTypography.body.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
