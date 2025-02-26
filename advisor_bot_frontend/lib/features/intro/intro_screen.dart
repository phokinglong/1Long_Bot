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
    )..forward(); // 🚀 **Ensures first screen text animates immediately!**

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
                image: "assets/images/intro_1.png",
                title: "Tối Đa Hóa Tiềm Năng Tài Chính Của Bạn",
                description:
                    "Cộng sự AI của 1Long cá nhân hóa các giải pháp đầu tư tích lũy, theo tiềm lực tài chính và mục tiêu của bạn.",
                fadeAnimation: _fadeAnimation,
                forceVisible: true, // 🚀 **Ensures first page is always visible**
              ),
              IntroPage(
                image: "assets/images/intro_2.png",
                title: "Đầu Tư Thông Minh, Từ Phân Tích Chuyên Sâu",
                description:
                    "Vượt xa các dữ liệu bề nổi, Cộng sự AI của 1Long phân tích sâu thị trường, cân nhắc khả năng và mục tiêu tài chính của bạn để đưa ra các gợi ý đầu tư tối ưu nhất.",
                fadeAnimation: _fadeAnimation,
              ),
              IntroPage(
                image: "assets/images/intro_3.png",
                title: "Cập Nhật Tin Tức Tài Chính",
                description:
                    "Có cộng sự AI của 1Long liên tục tổng hợp tin tức tài chính, bạn sẽ dễ dàng nắm trọn mọi thông tin quan trọng trên thị trường.",
                fadeAnimation: _fadeAnimation,
              ),
              IntroPage(
                image: "assets/images/intro_4.png",
                title: "Thiết Kế Lộ Trình Tích Lũy Bền Vững",
                description:
                    "Gợi ý các giải pháp tích lũy linh hoạt, an toàn và tối ưu nhất, Cộng sự AI của 1Long giúp bạn vững vàng phát triển tài chính và giảm thiểu ảnh hưởng từ các biến động thị trường.",
                fadeAnimation: _fadeAnimation,
              ),
            ],
          ),

          /// ✅ **Smooth Page Indicator**
          Positioned(
            bottom: 110,
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                backgroundColor: const Color(0xFF1A73E8), // Modern blue color
              ),
              child: Text(
                currentPage == 3 ? "Bắt đầu" : "Tiếp theo",
                style: GoogleFonts.beVietnamPro(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
  final bool forceVisible;

  const IntroPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.fadeAnimation,
    this.forceVisible = false, // 🚀 Ensures first page always loads text!
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
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),

        /// 📜 **Animated Text Section**
        Align(
          alignment: Alignment.bottomCenter,
          child: FadeTransition(
            opacity: forceVisible ? AlwaysStoppedAnimation(1.0) : fadeAnimation,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              margin: const EdgeInsets.only(bottom: 140),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85), // Darker background for readability
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
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
