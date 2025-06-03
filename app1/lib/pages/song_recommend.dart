import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Song {
  final String name;
  final String artist;
  final String url;
  final String image;

  Song({
    required this.name,
    required this.artist,
    required this.url,
    required this.image,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      name: json['name'],
      artist: json['artist'],
      url: json['url'],
      image: json['image'],
    );
  }
}

class SongRecommendationScreen extends StatefulWidget {
  final String email;

  SongRecommendationScreen({required this.email});

  @override
  _SongRecommendationScreenState createState() =>
      _SongRecommendationScreenState();
}

class _SongRecommendationScreenState extends State<SongRecommendationScreen> {
  List<Song> moodRecommendations = [];
  List<Song> likedSongs = [];
  List<Song> lastViewedSongs = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  Future<void> loadSongs() async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.18.83:8000/recommend"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': widget.email}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          moodRecommendations =
              (data['recommendedSongs'] as List<dynamic>)
                  .map((json) => Song.fromJson(json))
                  .toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load songs");
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load songs: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D0E3A),
      appBar: AppBar(
        title: const Text('Song Recommendations'),
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
                    _buildSongSection(
                      "Mood Recommendations",
                      moodRecommendations,
                    ),
                    _buildSongSection("Liked Songs", likedSongs),
                    _buildSongSection("Last Viewed Songs", lastViewedSongs),
                  ],
                ),
              ),
    );
  }

  Widget _buildSongSection(String title, List<Song> songs) {
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
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return _buildSongCard(song);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongCard(Song song) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          if (!lastViewedSongs.contains(song)) {
            lastViewedSongs.add(song);
          }
        });

        final Uri uri = Uri.parse(song.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          print('Could not launch ${song.url}');
        }
      },
      child: Container(
        width: 130,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(song.image),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
