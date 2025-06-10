import 'package:app1/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PreferenceChartScreen extends StatefulWidget {
  final String email;
  PreferenceChartScreen({required this.email});

  @override
  _PreferenceChartScreenState createState() => _PreferenceChartScreenState();
}

class _PreferenceChartScreenState extends State<PreferenceChartScreen> {
  // Color scheme matching onBoarding_screen.dart
  static const Color darkPurple = Color(0xFF1E0A2E);
  static const Color purple = Color(0xFF7B1FA2);
  static const Color white = Colors.white;
  
  final List<String> musicGenres = [
    'Pop',
    'Rock',
    'Hip-Hop',
    'Chill',
    'Classical',
    'Electronic',
    'Jazz',
    'Metal',
    'Romantic',
    'Indie',
    'R&B',
  ];

  final List<String> movieGenres = [
    'Action',
    'Adventure',
    'Comedy',
    'Crime',
    'Drama',
    'Fantasy',
    'Horror',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Thriller',
  ];

  final List<String> moods = [
    'Happy',
    'Sad',
    'Angry',
    'Stressed',
    'Relaxed',
    'Energetic',
  ];

  final List<String> languages = [
    'English',
    'Hindi',
    'Urdu',
    'Spanish',
    'Korean',
    'French',
  ];

  final List<String> musicEras = ['1980s', '1990s', '2000s', '2010s', '2020s'];

  Set<String> selectedMusicGenres = {};
  Set<String> selectedMovieGenres = {};
  Map<String, String> musicMoodMap = {};
  Map<String, String> movieMoodMap = {};
  List<String> selectedLanguages = [];
  String? selectedEra;

  List<String> favoriteActors = [];
  List<String> favoriteActress = [];
  List<String> favoriteDirectors = [];
  List<String> favoriteSingers = [];

  void showSearchDialog(String type) async {
    TextEditingController _searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkPurple,
        title: Text(
          'Search $type',
          style: TextStyle(color: white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: purple.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: white),
                  decoration: InputDecoration(
                    hintText: 'Type name...',
                    hintStyle: TextStyle(color: white.withOpacity(0.7)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final query = _searchController.text;

                  List<String> results = [];

                  final response = await http.post(
                    Uri.parse('http://192.168.18.83:5000/search'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'type': type.toLowerCase(),
                      'query': query,
                    }),
                  );

                  final data = jsonDecode(response.body);
                  results = List<String>.from(data['results']);

                  Navigator.pop(context);

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: darkPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (ctx) => SafeArea(
                      child: Container(
                        height: MediaQuery.of(ctx).size.height * 0.6,
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Select $type',
                              style: TextStyle(
                                color: white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Expanded(
                              child: ListView(
                                children: results.map((name) {
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: purple.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        name,
                                        style: TextStyle(color: white),
                                      ),
                                      trailing: Icon(Icons.add, color: purple),
                                      onTap: () {
                                        setState(() {
                                          if (type == 'Actor') favoriteActors.add(name);
                                          if (type == 'Actress') favoriteActress.add(name);
                                          if (type == 'Director') favoriteDirectors.add(name);
                                          if (type == 'Singer') favoriteSingers.add(name);
                                        });
                                        Navigator.pop(ctx);
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text('Search', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submitPreferences() async {
    final userData = {
      'email': widget.email,
      'musicGenres': selectedMusicGenres.toList(),
      'movieGenres': selectedMovieGenres.toList(),
      'musicMoodMap': musicMoodMap,
      'movieMoodMap': movieMoodMap,
      'languages': selectedLanguages,
      'era': selectedEra,
      'actors': favoriteActors,
      'actress': favoriteActress,
      'directors': favoriteDirectors,
      'singers': favoriteSingers,
    };

    final response = await http.post(
      Uri.parse('http://192.168.18.83:8000/preferences/save'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(email: widget.email)),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to submit preferences.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPurple,
      appBar: AppBar(
        backgroundColor: darkPurple,
        elevation: 0,
        title: Text(
          'Preference Chart',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Text
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [purple.withOpacity(0.3), purple.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tell us your preferences',
                    style: TextStyle(
                      color: white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Help us personalize your experience',
                    style: TextStyle(
                      color: white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            
            // Music Genres Section
            _buildSectionTitle('🎵 Music Genres'),
            SizedBox(height: 12),
            _buildChipSelector(musicGenres, selectedMusicGenres),
            SizedBox(height: 24),
            
            // Movie Genres Section
            _buildSectionTitle('🎬 Movie Genres'),
            SizedBox(height: 12),
            _buildChipSelector(movieGenres, selectedMovieGenres),
            SizedBox(height: 24),
            
            // Music Mood Mapping
            _buildSectionTitle('🎶 Music for your Moods'),
            SizedBox(height: 12),
            ...moods.map((mood) => _buildMoodDropdown(mood, musicGenres, musicMoodMap)),
            SizedBox(height: 24),
            
            // Movie Mood Mapping
            _buildSectionTitle('🍿 Movies for your Moods'),
            SizedBox(height: 12),
            ...moods.map((mood) => _buildMoodDropdown(mood, movieGenres, movieMoodMap)),
            SizedBox(height: 24),
            
            // Languages Section
            _buildSectionTitle('🌍 Preferred Languages'),
            SizedBox(height: 12),
            _buildLanguageSelector(),
            SizedBox(height: 24),
            
            // Era Section
            _buildSectionTitle('📅 Preferred Era'),
            SizedBox(height: 12),
            _buildEraDropdown(),
            SizedBox(height: 24),
            
            // Favorites Section
            _buildSectionTitle('⭐ Add Your Favorites'),
            SizedBox(height: 12),
            _buildFavoritesSection(),
            SizedBox(height: 16),
            _buildSelectedFavorites(),
            SizedBox(height: 32),
            
            // Submit Button
            Container(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: submitPreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                ),
                child: Text(
                  'Submit Preferences',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildChipSelector(List<String> items, Set<String> selectedItems) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selectedItems.contains(item);
        return GestureDetector(
          onTap: () {
            setState(() {
              isSelected ? selectedItems.remove(item) : selectedItems.add(item);
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? purple : purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? purple : purple.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              item,
              style: TextStyle(
                color: white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMoodDropdown(String mood, List<String> genres, Map<String, String> moodMap) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: purple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: purple.withOpacity(0.3)),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: mood,
          labelStyle: TextStyle(color: white),
          border: InputBorder.none,
        ),
        dropdownColor: darkPurple,
        style: TextStyle(color: white),
        items: genres.map((g) => DropdownMenuItem(
          value: g,
          child: Text(g, style: TextStyle(color: white)),
        )).toList(),
        onChanged: (val) => setState(() => moodMap[mood] = val ?? ''),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: languages.map((lang) {
        final isSelected = selectedLanguages.contains(lang);
        return GestureDetector(
          onTap: () {
            setState(() {
              isSelected ? selectedLanguages.remove(lang) : selectedLanguages.add(lang);
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? purple : purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? purple : purple.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              lang,
              style: TextStyle(
                color: white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEraDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: purple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: purple.withOpacity(0.3)),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Select Era',
          labelStyle: TextStyle(color: white),
          border: InputBorder.none,
        ),
        dropdownColor: darkPurple,
        style: TextStyle(color: white),
        items: musicEras.map((era) => DropdownMenuItem(
          value: era,
          child: Text(era, style: TextStyle(color: white)),
        )).toList(),
        onChanged: (val) => setState(() => selectedEra = val),
      ),
    );
  }

  Widget _buildFavoritesSection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildFavoriteButton('👨‍🎭 Actor', 'Actor'),
        _buildFavoriteButton('👩‍🎭 Actress', 'Actress'),
        _buildFavoriteButton('🎬 Director', 'Director'),
        _buildFavoriteButton('🎤 Singer', 'Singer'),
      ],
    );
  }

  Widget _buildFavoriteButton(String label, String type) {
    return ElevatedButton(
      onPressed: () => showSearchDialog(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: purple.withOpacity(0.3),
        foregroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        side: BorderSide(color: purple.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSelectedFavorites() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (favoriteActors.isNotEmpty) _buildFavoritesList('👨‍🎭 Actors', favoriteActors),
        if (favoriteActress.isNotEmpty) _buildFavoritesList('👩‍🎭 Actresses', favoriteActress),
        if (favoriteDirectors.isNotEmpty) _buildFavoritesList('🎬 Directors', favoriteDirectors),
        if (favoriteSingers.isNotEmpty) _buildFavoritesList('🎤 Singers', favoriteSingers),
      ],
    );
  }

  Widget _buildFavoritesList(String title, List<String> items) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) => Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: purple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                item,
                style: TextStyle(color: white, fontSize: 14),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
