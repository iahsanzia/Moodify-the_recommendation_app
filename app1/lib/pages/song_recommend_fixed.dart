import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      name: json['name'] ?? 'Unknown Song',
      artist: json['artist'] ?? 'Unknown Artist',
      url: json['url'] ?? '',
      image: json['image'] ?? '',
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
  // Color scheme matching the app
  static const Color darkPurple = Color(0xFF1E0A2E);
  static const Color purple = Color(0xFF7B1FA2);
  static const Color white = Colors.white;

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
      print('🎵 Loading songs for email: ${widget.email}');
      final response = await http.post(
        Uri.parse("http://141.147.115.222:8000/recommend"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': widget.email}),
      );

      print('🎵 Response status code: ${response.statusCode}');
      print('🎵 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🎵 Parsed data: $data');

        if (data['recommendedSongs'] != null) {
          setState(() {
            moodRecommendations =
                (data['recommendedSongs'] as List<dynamic>)
                    .map((json) => Song.fromJson(json))
                    .toList();
            isLoading = false;
          });
          print('🎵 Successfully loaded ${moodRecommendations.length} songs');
        } else {
          throw Exception("No recommended songs in response");
        }
      } else {
        throw Exception(
          "Failed to load songs. Status: ${response.statusCode}, Body: ${response.body}",
        );
      }
    } catch (e) {
      print('🎵 Error loading songs: $e');
      setState(() {
        errorMessage = 'Failed to load songs: $e';
        isLoading = false;
      });
    }
  }

  void _addToLiked(Song song) {
    setState(() {
      if (!likedSongs.any(
        (s) => s.name == song.name && s.artist == song.artist,
      )) {
        likedSongs.add(song);
        HapticFeedback.mediumImpact();
        _showSnackBar('Added "${song.name}" to liked songs!', Icons.favorite);
      }
    });
  }

  void _addToLastViewed(Song song) {
    setState(() {
      // Remove if already exists to avoid duplicates
      lastViewedSongs.removeWhere(
        (s) => s.name == song.name && s.artist == song.artist,
      );
      // Add to beginning of list
      lastViewedSongs.insert(0, song);
      // Keep only last 10 viewed
      if (lastViewedSongs.length > 10) {
        lastViewedSongs.removeLast();
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

  void _showSongDetails(Song song) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: darkPurple,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: purple.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: purple.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Song Details',
                          style: TextStyle(
                            color: white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: white),
                          onPressed: () => Navigator.of(context).pop(),
                          style: IconButton.styleFrom(
                            backgroundColor: purple.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Album Art
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: purple.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child:
                            song.image.isNotEmpty
                                ? Image.network(
                                  song.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: purple.withOpacity(0.3),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.music_note,
                                              color: white,
                                              size: 60,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'No Image',
                                              style: TextStyle(
                                                color: white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                                : Container(
                                  color: purple.withOpacity(0.3),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.music_note,
                                          color: white,
                                          size: 60,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'No Image',
                                          style: TextStyle(
                                            color: white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Song Information
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: purple.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Song Name
                          Row(
                            children: [
                              Icon(Icons.music_note, color: purple, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Song Title',
                                style: TextStyle(
                                  color: white.withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            song.name,
                            style: TextStyle(
                              color: white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Artist Name
                          Row(
                            children: [
                              Icon(Icons.person, color: purple, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Artist',
                                style: TextStyle(
                                  color: white.withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            song.artist,
                            style: TextStyle(
                              color: white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 16),

                          // URL Information
                          if (song.url.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.link, color: purple, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Streaming Link',
                                  style: TextStyle(
                                    color: white.withOpacity(0.7),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final Uri uri = Uri.parse(song.url);
                                try {
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                    _showSnackBar(
                                      'Opening "${song.name}"...',
                                      Icons.open_in_new,
                                    );
                                  } else {
                                    _showSnackBar(
                                      'Could not open song link',
                                      Icons.error,
                                    );
                                  }
                                } catch (e) {
                                  _showSnackBar(
                                    'Error opening song link',
                                    Icons.error,
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: purple.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: purple.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.open_in_new,
                                      color: purple,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        song.url.length > 40
                                            ? '${song.url.substring(0, 40)}...'
                                            : song.url,
                                        style: TextStyle(
                                          color: purple,
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.link_off,
                                  color: white.withOpacity(0.5),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'No streaming link available',
                                  style: TextStyle(
                                    color: white.withOpacity(0.5),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _addToLiked(song);
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              likedSongs.any(
                                    (s) =>
                                        s.name == song.name &&
                                        s.artist == song.artist,
                                  )
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: white,
                            ),
                            label: Text(
                              likedSongs.any(
                                    (s) =>
                                        s.name == song.name &&
                                        s.artist == song.artist,
                                  )
                                  ? 'Liked'
                                  : 'Like',
                              style: TextStyle(
                                color: white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  likedSongs.any(
                                        (s) =>
                                            s.name == song.name &&
                                            s.artist == song.artist,
                                      )
                                      ? Colors.red.withOpacity(0.8)
                                      : purple.withOpacity(0.3),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        if (song.url.isNotEmpty)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final Uri uri = Uri.parse(song.url);
                                try {
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                    Navigator.of(context).pop();
                                    _showSnackBar(
                                      'Opening "${song.name}"...',
                                      Icons.play_arrow,
                                    );
                                  } else {
                                    _showSnackBar(
                                      'Could not open song link',
                                      Icons.error,
                                    );
                                  }
                                } catch (e) {
                                  _showSnackBar(
                                    'Error opening song link',
                                    Icons.error,
                                  );
                                }
                              },
                              icon: Icon(Icons.play_arrow, color: white),
                              label: Text(
                                'Play',
                                style: TextStyle(
                                  color: white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: purple,
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
          'Song Recommendations',
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
                          loadSongs();
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
                          Icon(Icons.music_note, color: white, size: 40),
                          SizedBox(height: 12),
                          Text(
                            '🎵 Song Recommendations',
                            style: TextStyle(
                              color: white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Discover music perfect for your mood',
                            style: TextStyle(
                              color: white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Mood Recommendations Section
                    if (moodRecommendations.isNotEmpty)
                      _buildSongSection(
                        "🎯 Recommended for You",
                        moodRecommendations,
                        "Based on your mood and preferences",
                      ),

                    // Liked Songs Section
                    if (likedSongs.isNotEmpty) ...[
                      SizedBox(height: 16),
                      _buildSongSection(
                        "❤️ Liked Songs",
                        likedSongs,
                        "Your favorite songs",
                      ),
                    ],

                    // Last Viewed Songs Section
                    if (lastViewedSongs.isNotEmpty) ...[
                      SizedBox(height: 16),
                      _buildSongSection(
                        "👁️ Recently Played",
                        lastViewedSongs,
                        "Songs you've recently listened to",
                      ),
                    ],
                  ],
                ),
              ),
    );
  }

  Widget _buildSongSection(String title, List<Song> songs, String subtitle) {
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
            height: 220,
            child:
                songs.isEmpty
                    ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.music_off_outlined,
                              size: 48,
                              color: white.withOpacity(0.5),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No songs yet',
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
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return _buildSongCard(song);
                      },
                    ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSongCard(Song song) {
    return GestureDetector(
      onTap: () {
        _addToLastViewed(song);
        _showSongDetails(song);
      },
      onLongPress: () {
        _addToLiked(song);
      },
      child: Container(
        width: 160,
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
              // Album Art
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image:
                      song.image.isNotEmpty
                          ? DecorationImage(
                            image: NetworkImage(song.image),
                            fit: BoxFit.cover,
                          )
                          : null,
                  color: song.image.isEmpty ? purple.withOpacity(0.3) : null,
                ),
                child:
                    song.image.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.music_note, color: white, size: 40),
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
              if (likedSongs.any(
                (s) => s.name == song.name && s.artist == song.artist,
              ))
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

              // Play Icon Overlay
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: purple.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.play_arrow, color: white, size: 24),
                  ),
                ),
              ),

              // Song Info
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
                        song.name,
                        style: TextStyle(
                          color: white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        song.artist,
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
