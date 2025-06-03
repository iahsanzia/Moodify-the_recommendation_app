import 'package:app1/pages/screen2.dart';
import 'package:app1/pages/signUp.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  final PageController _pageController = PageController();

  // Color scheme
  static const Color darkPurple = Color(0xFF1E0A2E);
  static const Color purple = Color(0xFF7B1FA2);
  static const Color white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPurple,
      body: SafeArea(
        child: Column(
          children: [
            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    currentPage = page;
                  });
                  print('Current Page: $currentPage'); // Debugging
                },                children: [
                  buildOnboardingPage(), // First Page
                  Screen2(showFooter: false), // Second Page - no footer to prevent duplication
                ],
              ),
            ),

            // Footer: Skip, Page Indicators, Next Button
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip Button
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),                    child: TextButton(
                      onPressed: () {
                        print('Navigating to Signup via Skip button');
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => Signup(),
                          ),
                        );
                      },
                      child: const Text(
                        'skip',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ),

                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildPageIndicator(),
                  ),

                  // Next Button
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: ElevatedButton(                      onPressed: () {
                        if (currentPage < 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                          print('Navigating to Next Page');
                        } else {
                          print('Navigating to Signup');
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => Signup(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purple,
                        foregroundColor: white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'NEXT',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOnboardingPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Text(
            'Enjoy Music That\nSuits Your Mood!!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 40),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/illustration.png',
                width: 260,
                height: 260,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < 2; i++) {
      indicators.add(
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                i == currentPage
                    ? white
                    : Color.fromRGBO(
                      255,
                      255,
                      255,
                      0.3,
                    ), // Alternative to withOpacity
          ),
        ),
      );
    }
    return indicators;
  }
}
