import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Movie {
  final String title;
  final String character;
  final String posterPath;

  Movie({
    required this.title,
    required this.character,
    required this.posterPath,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'],
      character: json['character'] ?? 'Unknown Character',
      posterPath: json['poster_path'] ?? '',
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
  List<Movie> recommendedMovies = [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D0E3A),
      appBar: AppBar(
        title: const Text('Movie Recommendations'),
        backgroundColor: const Color(0xFF1D0E3A),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMovieSection("Recommended Movies", recommendedMovies),
                  ],
                ),
              ),
    );
  }

  Widget _buildMovieSection(String title, List<Movie> movies) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return _buildMovieCard(movie);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(
            "https://image.tmdb.org/t/p/w500${movie.posterPath}",
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "Character: ${movie.character}",
                style: TextStyle(color: Colors.white70, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
