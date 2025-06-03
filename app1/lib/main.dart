// import 'package:app1/pages/home_page.dart';
import 'package:app1/pages/onBoarding_screen.dart';
import 'package:flutter/material.dart';

// import 'pages/preferenceChartScreen.dart';
// import 'pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recommendation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: OnboardingScreen(),
    );
  }
}
