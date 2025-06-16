import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Movie {
  final String title;
  final String character;
  final String posterPath;
  final String overview;

  Movie({
    required this.title,
    required this.character,
    required this.posterPath,
    this.overview = '',
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'] ?? 'Unknown Title',
      character: json['character'] ?? 'Unknown Character',
      posterPath: json['poster_path'] ?? '',
      overview: json['overview'] ?? '',
    );
  }
}

class MovieRecommendationScreen extends StatefulWidget {
  final String email;

  MovieRecommendationScreen({required this.email});

  @override
  _MovieRecommendationScreenState createState() =>
      _MovieRecommendationScreenState();
}

class _MovieRecommendationScreenState extends State<MovieRecommendationScreen> {
  // Color scheme matching the app
  static const Color darkPurple = Color(0xFF1E0A2E);
  static const Color purple = Color(0xFF7B1FA2);
  static const Color white = Colors.white;

  List<Movie> recommendedMovies = [];
  List<Movie> likedMovies = [];
  List<Movie> lastViewedMovies = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadMovies();
  }

  Future<void> loadMovies() async {
    try {
      final response = await http.post(
        Uri.parse("http://141.147.115.222:8000/recommend"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': widget.email}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          recommendedMovies =
              (data['recommendedMovies'] as List<dynamic>)
                  .map((json) => Movie.fromJson(json))
                  .toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load movies");
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load movies: $e';
        isLoading = false;
      });
    }
  }

  void _addToLiked(Movie movie) {
    setState(() {
      if (!likedMovies.any((m) => m.title == movie.title)) {
        likedMovies.add(movie);
        HapticFeedback.mediumImpact();
        _showSnackBar(
          'Added "${movie.title}" to liked movies!',
          Icons.favorite,
        );
      }
    });
  }

  void _addToLastViewed(Movie movie) {
    setState(() {
      // Remove if already exists to avoid duplicates
      lastViewedMovies.removeWhere((m) => m.title == movie.title);
      // Add to beginning of list
      lastViewedMovies.insert(0, movie);
      // Keep only last 10 viewed
      if (lastViewedMovies.length > 10) {
        lastViewedMovies.removeLast();
      }
    });
  }

  void _showSnackBar(String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: purple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showMovieDetails(Movie movie) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: darkPurple,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: purple.withOpacity(0.3), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🎬 Movie Details',
                      style: TextStyle(
                        color: white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Movie Poster
                Container(
                  width: 150,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image:
                        movie.posterPath.isNotEmpty
                            ? DecorationImage(
                              image: NetworkImage(
                                'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                              ),
                              fit: BoxFit.cover,
                            )
                            : null,
                    color:
                        movie.posterPath.isEmpty
                            ? purple.withOpacity(0.3)
                            : null,
                  ),
                  child:
                      movie.posterPath.isEmpty
                          ? Center(
                            child: Icon(Icons.movie, color: white, size: 60),
                          )
                          : null,
                ),
                SizedBox(height: 20),

                // Movie Information
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: purple.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.movie, color: purple, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Movie Title',
                            style: TextStyle(
                              color: white.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        movie.title,
                        style: TextStyle(
                          color: white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      Row(
                        children: [
                          Icon(Icons.person, color: purple, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Main Character/Actor',
                            style: TextStyle(
                              color: white.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        movie.character,
                        style: TextStyle(
                          color: white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (movie.overview.isNotEmpty) ...[
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.description, color: purple, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Overview',
                              style: TextStyle(
                                color: white.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 120,
                          child: SingleChildScrollView(
                            child: Text(
                              movie.overview,
                              style: TextStyle(
                                color: white.withOpacity(0.9),
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _addToLiked(movie);
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.favorite, size: 20),
                        label: Text('Like'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.8),
                          foregroundColor: white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _addToLastViewed(movie);
                          Navigator.pop(context);
                          _showSnackBar(
                            'Added "${movie.title}" to recently viewed!',
                            Icons.visibility,
                          );
                        },
                        icon: Icon(Icons.visibility, size: 20),
                        label: Text('Viewed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: purple,
                          foregroundColor: white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPurple,
      appBar: AppBar(
        title: Text(
          'Movie Recommendations',
          style: TextStyle(
            color: white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: darkPurple,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(purple),
                ),
              )
              : errorMessage != null
              ? Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 60),
                      SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });
                          loadMovies();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: purple,
                          foregroundColor: white,
                        ),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
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
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.movie, color: white, size: 40),
                          SizedBox(height: 12),
                          Text(
                            '🎬 Movie Recommendations',
                            style: TextStyle(
                              color: white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Discover movies perfect for your mood',
                            style: TextStyle(
                              color: white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Recommended Movies Section
                    if (recommendedMovies.isNotEmpty)
                      _buildMovieSection(
                        "🎯 Recommended for You",
                        recommendedMovies,
                        "Based on your mood and preferences",
                      ),

                    // Liked Movies Section
                    if (likedMovies.isNotEmpty) ...[
                      SizedBox(height: 16),
                      _buildMovieSection(
                        "❤️ Liked Movies",
                        likedMovies,
                        "Your favorite movies",
                      ),
                    ],

                    // Last Viewed Movies Section
                    if (lastViewedMovies.isNotEmpty) ...[
                      SizedBox(height: 16),
                      _buildMovieSection(
                        "👁️ Recently Viewed",
                        lastViewedMovies,
                        "Movies you've recently checked out",
                      ),
                    ],
                  ],
                ),
              ),
    );
  }

  Widget _buildMovieSection(String title, List<Movie> movies, String subtitle) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: purple.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: white.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 300,
            child:
                movies.isEmpty
                    ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.movie_outlined,
                              size: 48,
                              color: white.withOpacity(0.5),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No movies yet',
                              style: TextStyle(
                                color: white.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return _buildMovieCard(movie);
                      },
                    ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        _showMovieDetails(movie);
      },
      onLongPress: () {
        _addToLiked(movie);
      },
      child: Container(
        width: 180,
        margin: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: purple.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Movie Poster
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image:
                      movie.posterPath.isNotEmpty
                          ? DecorationImage(
                            image: NetworkImage(
                              "https://image.tmdb.org/t/p/w500${movie.posterPath}",
                            ),
                            fit: BoxFit.cover,
                          )
                          : null,
                  color:
                      movie.posterPath.isEmpty ? purple.withOpacity(0.3) : null,
                ),
                child:
                    movie.posterPath.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.movie, color: white, size: 40),
                              SizedBox(height: 8),
                              Text(
                                'No Image',
                                style: TextStyle(color: white, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                        : null,
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.9),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),

              // Heart Icon for Liked
              if (likedMovies.any((m) => m.title == movie.title))
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite, color: white, size: 16),
                  ),
                ),

              // Movie Info
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: TextStyle(
                          color: white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      if (movie.character.isNotEmpty)
                        Text(
                          movie.character,
                          style: TextStyle(
                            color: white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),

              // Interaction Hint
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: purple.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Hold to ❤️',
                    style: TextStyle(
                      color: white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
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
