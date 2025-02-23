import 'package:flutter/material.dart';
import 'package:advisor_bot/features/onboarding/onboarding_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  IntroScreenState createState() => IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    /// 🟢 **Initialize Animation Controller**
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    /// 🔵 **Fade-In Animation**
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// ✅ **Animated PageView for Intro Screens**
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              _animationController.reset();
              _animationController.forward();
              setState(() {
                currentPage = index;
              });
            },
            children: [
              IntroPage(
                image: "assets/images/intro_1.webp",
                title: "Cộng sự Chi tiêu",
                description: "Quản lý chi tiêu cá nhân và gia đình",
                fadeAnimation: _fadeAnimation,
              ),
              IntroPage(
                image: "assets/images/intro_2.webp",
                title: "Cộng sự Tích lũy",
                description: "Tích lũy và bảo hiểm cá nhân",
                fadeAnimation: _fadeAnimation,
              ),
              IntroPage(
                image: "assets/images/intro_3.webp",
                title: "Cộng sự Đầu tư",
                description: "Tư duy, chiến lược đầu tư tài chính",
                fadeAnimation: _fadeAnimation,
              ),
              IntroPage(
                image: "assets/images/intro_1.webp",
                title: "Cộng sự Tin tức",
                description: "Phân tích tin tức tài chính, thị trường",
                fadeAnimation: _fadeAnimation,
              ),
            ],
          ),

          /// ✅ **Smooth Page Indicator**
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 4,
                effect: ExpandingDotsEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.grey.shade600,
                  dotHeight: 10,
                  dotWidth: 10,
                ),
              ),
            ),
          ),

          /// ✅ **"Get Started" Button (Now on every page)**
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                if (currentPage == 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                  );
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                currentPage == 3 ? "Get Started" : "Next",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ **Refactored Intro Page with Improved UI**
class IntroPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final Animation<double> fadeAnimation;

  const IntroPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// 🖼️ **Full-Screen Background Image**
        Positioned.fill(
          child: Image.asset(
            image,
            fit: BoxFit.cover,
          ),
        ),

        /// 🔳 **Gradient Overlay for better text readability**
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ),

        /// 📜 **Animated Text Section**
        Align(
          alignment: Alignment.bottomCenter,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              margin: const EdgeInsets.only(bottom: 130), // ✅ Adjusted for better placement
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
