import 'dart:io';
import 'package:app1/pages/recommend.dart';
import 'package:app1/pages/song_recommend.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:image/image.dart' as img;

class HomePage extends StatefulWidget {
  final String email;
  const HomePage({super.key, required this.email});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Color scheme matching onBoarding_screen.dart
  static const Color darkPurple = Color(0xFF1E0A2E);
  static const Color purple = Color(0xFF7B1FA2);
  static const Color white = Colors.white;

  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  CameraDescription? _camera;
  bool _isFrontCamera = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _camera = _cameras.firstWhere(
      (camera) =>
          camera.lensDirection ==
          (_isFrontCamera
              ? CameraLensDirection.front
              : CameraLensDirection.back),
    );
    _cameraController = CameraController(_camera!, ResolutionPreset.medium);
    await _cameraController?.initialize();
    setState(() {});
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      final image = await _cameraController!.takePicture();
      File fixedImage = File(image.path);

      if (_camera?.lensDirection == CameraLensDirection.front) {
        fixedImage = await _flipImageHorizontally(File(image.path));
      }

      String mood = await _uploadImage(fixedImage);
      await _saveMoodToBackend(mood);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MoodScreen(mood: mood, email: widget.email),
        ),
      );
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  Future<File> _flipImageHorizontally(File imageFile) async {
    final originalBytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(originalBytes);

    if (decodedImage == null) return imageFile;

    final flippedImage = img.flipHorizontal(decodedImage);
    final flippedBytes = img.encodeJpg(flippedImage);
    return await File(imageFile.path).writeAsBytes(flippedBytes);
  }

  void _switchCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    _initializeCamera();
  }

  Future<String> _uploadImage(File image) async {
    final uri = Uri.parse(
      'http://192.168.18.83:8000/mood/get-mood?email=${widget.email}',
    );
    var request = http.MultipartRequest('POST', uri);

    var pic = await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType('image', 'jpeg'),
    );

    request.files.add(pic);

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);
        return jsonResponse['predicted_mood'] ?? 'Unknown Mood';
      } else {
        return 'Failed to detect mood';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> _saveMoodToBackend(String mood) async {
    final uri = Uri.parse('http://192.168.18.83:8000/mood/save-mood');
    final body = jsonEncode({
      'email': widget.email,
      'mood': mood,
      'confidence': 'high',
    }); // Add confidence here

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print("Mood Saved Response: ${response.body}");
  }

  void _logout() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPurple,
      appBar: AppBar(
        backgroundColor: darkPurple,
        elevation: 0,
        title: Text(
          'Mood Detection',
          style: TextStyle(
            color: white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.person_outline, color: white),
          onPressed: () {},
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(Icons.logout, color: white),
              onPressed: _logout,
              style: IconButton.styleFrom(
                backgroundColor: purple.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [purple.withOpacity(0.3), purple.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      '👋 Welcome back!',
                      style: TextStyle(
                        color: white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Let\'s detect your mood and find perfect content for you',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Camera Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: purple.withOpacity(0.3), width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      '📸 Mood Camera',
                      style: TextStyle(
                        color: white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Camera Preview
                    if (_cameraController != null &&
                        _cameraController!.value.isInitialized)
                      Container(
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
                          child: SizedBox(
                            width: 280,
                            height: 350,
                            child: CameraPreview(_cameraController!),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 280,
                        height: 350,
                        decoration: BoxDecoration(
                          color: purple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: white, size: 60),
                              SizedBox(height: 16),
                              Text(
                                'Initializing Camera...',
                                style: TextStyle(color: white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 20),

                    // Camera Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCameraButton(
                          icon: Icons.flip_camera_android,
                          label: 'Switch',
                          onPressed: _switchCamera,
                        ),
                        _buildCameraButton(
                          icon: Icons.camera,
                          label: 'Capture',
                          onPressed: _captureImage,
                          isPrimary: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Actions Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: purple.withOpacity(0.3), width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      '🎯 Quick Actions',
                      style: TextStyle(
                        color: white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),

                    _buildActionButton(
                      icon: Icons.music_note,
                      title: 'Get Recommendations',
                      subtitle: 'Discover music & movies for you',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    RecommendationScreen(email: widget.email),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16),

                    _buildActionButton(
                      icon: Icons.history,
                      title: 'Mood History',
                      subtitle: 'View your past mood detections',
                      onPressed: () {
                        // TODO: Navigate to mood history
                      },
                    ),
                    SizedBox(height: 16),

                    _buildActionButton(
                      icon: Icons.settings,
                      title: 'Settings',
                      subtitle: 'Customize your preferences',
                      onPressed: () {
                        // TODO: Navigate to settings
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? purple : purple.withOpacity(0.3),
        foregroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: isPrimary ? 8 : 4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: purple.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: purple.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: purple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: white, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
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
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: purple, size: 16),
          ],
        ),
      ),
    );
  }
}

class MoodScreen extends StatelessWidget {
  final String mood;
  final String email;
  const MoodScreen({super.key, required this.mood, required this.email});

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
          'Detected Mood',
          style: TextStyle(
            color: white,
            fontSize: 20,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mood Result Container
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [purple.withOpacity(0.3), purple.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: purple.withOpacity(0.3), width: 2),
                ),
                child: Column(
                  children: [
                    // Mood Icon
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: purple.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.sentiment_satisfied_alt,
                        size: 60,
                        color: white,
                      ),
                    ),
                    SizedBox(height: 24),

                    Text(
                      'Your Mood',
                      style: TextStyle(
                        color: white.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),

                    Text(
                      mood,
                      style: TextStyle(
                        color: white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    Text(
                      'Great! We\'ve detected your mood. Now let\'s find perfect content for you.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purple.withOpacity(0.3),
                        foregroundColor: white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                      ),
                      child: Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => RecommendationScreen(email: email),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purple,
                        foregroundColor: white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        elevation: 8,
                      ),
                      child: Text(
                        'Get Recommendations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
