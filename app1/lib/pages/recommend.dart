import 'package:flutter/material.dart';
import 'song_recommend.dart';
import 'movie_recommend.dart';

class RecommendationScreen extends StatelessWidget {
  final String email;

  RecommendationScreen({required this.email});

  // Color scheme matching the app
  static const Color darkPurple = Color(0xFF1E0A2E);
  static const Color purple = Color(0xFF7B1FA2);
  static const Color white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPurple,
      appBar: AppBar(
        backgroundColor: darkPurple,
        elevation: 0,
        title: Text(
          'Choose Your Mood',
          style: TextStyle(
            color: white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Section
              Text(
                '🎯 What would you like to discover?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 40),
                // Music Recommendation Card
              Flexible(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SongRecommendationScreen(email: email),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          purple.withOpacity(0.3),
                          purple.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: purple.withOpacity(0.3), width: 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration without background
                        Flexible(
                          child: Image.asset(
                            'assets/illustration.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 12),
                        
                        Text(
                          '🎵 Music',
                          style: TextStyle(
                            color: white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        
                        Text(
                          'Songs for your mood',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),              
              // Movie Recommendation Card
              Flexible(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieRecommendationScreen(email: email),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          purple.withOpacity(0.3),
                          purple.withOpacity(0.1),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: purple.withOpacity(0.3), width: 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration without background
                        Flexible(
                          child: Image.asset(
                            'assets/screen2.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 12),
                        
                        Text(
                          '🎬 Movies',
                          style: TextStyle(
                            color: white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        
                        Text(
                          'Films for your mood',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
