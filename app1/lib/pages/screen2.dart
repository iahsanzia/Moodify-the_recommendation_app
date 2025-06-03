import 'package:app1/pages/login_screen.dart';
import 'package:app1/pages/signUp.dart';
import 'package:flutter/material.dart';

class Screen2 extends StatelessWidget {
  final bool showFooter;
  const Screen2({Key? key, this.showFooter = true}) : super(key: key);

  static const Color darkPurple = Color(0xFF1E0A2E);
  static const Color purple = Color(0xFF7B1FA2);
  static const Color white = Colors.white;
  @override
  Widget build(BuildContext context) {
    print('Screen2 is being built'); // Debugging print

    return Scaffold(
      backgroundColor: darkPurple,
      body: SafeArea(
        child: showFooter ? 
          // Layout with footer
          Column(
            children: [
              // Main content
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Text Section
                        const Text(
                          'Watch Movies That\nSuits Your Mood!!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Image Section
                        Container(
                          width: 260,
                          height: 260,
                          child: Image.asset(
                            'assets/screen2.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.red,
                                child: const Center(
                                  child: Text(
                                    'Image not found',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Footer Section
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip Button
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextButton(
                        onPressed: () {
                          print('Navigating to LoginPage');
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
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
                      children: List.generate(
                        2, // Number of screens
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                index == 1
                                    ? white
                                    : Color.fromRGBO(
                                      255,
                                      255,
                                      255,
                                      0.3,
                                    ),
                          ),
                        ),
                      ),
                    ),
                    // Next Button
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: ElevatedButton(
                        onPressed: () {
                          print('Navigating to RegPage');
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => Signup()),
                          );
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
          ) : 
          // Layout without footer - perfectly centered content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Text Section
                  const Text(
                    'Watch Movies That\nSuits Your Mood!!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Image Section
                  Container(
                    width: 260,
                    height: 260,
                    child: Image.asset(
                      'assets/screen2.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.red,
                          child: const Center(
                            child: Text(
                              'Image not found',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }
}
