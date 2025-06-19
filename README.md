# 🎵 Moodify - The Recommendation App

A Flutter-based mood detection application that uses machine learning to analyze user emotions and provide personalized music and movie recommendations based on detected moods.

## 📱 Features

### 🎯 Core Functionality
- **Real-time Mood Detection** - Uses camera to capture and analyze facial expressions
- **ML-Powered Analysis** - TensorFlow Lite model for accurate emotion recognition
- **Smart Recommendations** - Personalized music and movie suggestions based on detected mood
- **User Profiles** - Secure authentication and personalized preferences
- **Mood History** - Track your emotional journey over time

### 🎨 User Interface
- **Modern Design** - Clean, dark purple theme with gradient effects
- **Interactive Cards** - Tap for details, long-press to like content
- **Responsive Layout** - Optimized for various screen sizes
- **Smooth Animations** - Enhanced user experience with haptic feedback
- **Intuitive Navigation** - Easy-to-use interface with clear visual hierarchy

### 🎵 Music Recommendations
- **Spotify Integration** - Direct links to songs on Spotify
- **Detailed Song Info** - Artist names, album art, and clickable URLs
- **Personal Collection** - Like songs and view recently played tracks
- **Genre Diversity** - Recommendations across multiple music genres

### 🎬 Movie Recommendations
- **Rich Movie Data** - Posters, overviews, cast information
- **Scrollable Content** - Full movie descriptions with smooth scrolling
- **Watch History** - Track recently viewed movies
- **Interactive Details** - Comprehensive movie information dialogs

## 🏗️ Architecture

### Frontend (Flutter)
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: StatefulWidget with local state
- **Navigation**: Material Design navigation patterns
- **Camera**: Flutter Camera plugin for image capture
- **HTTP**: Dio/HTTP package for API communication

### Backend Services
- **Node.js API** - RESTful endpoints for user management and recommendations
- **Flask ML Service** - Python-based machine learning model serving
- **MongoDB** - User data and preferences storage
- **Express.js** - Web framework for API development

### Machine Learning
- **Model**: Custom trained emotion detection model
- **Framework**: TensorFlow Lite for mobile deployment
- **Input**: Real-time camera feed processing
- **Output**: Emotion classification (Happy, Sad, Angry, etc.)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Node.js 16+
- Python 3.8+
- MongoDB

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/iahsanzia/Moodify-the_recommendation_app.git
   cd Moodify-the_recommendation_app
   ```

2. **Install Flutter dependencies**
   ```bash
   cd app1
   flutter pub get
   ```

3. **Set up backend services**
   ```bash
   cd ../backend
   npm install
   ```

4. **Configure environment variables**
   ```bash
   # Create .env file in backend directory
   MONGODB_URI=your_mongodb_connection_string
   SPOTIFY_CLIENT_ID=your_spotify_client_id
   SPOTIFY_CLIENT_SECRET=your_spotify_client_secret
   ```

5. **Start the services**
   ```bash
   # Start Node.js backend
   cd backend
   npm start
   
   # Start Flask ML service
   cd ../API/flask
   python app.py
   
   # Run Flutter app
   cd ../../app1
   flutter run
   ```

## 📁 Project Structure

```
moodify-flutter-main/
├── app1/                          # Flutter application
│   ├── lib/
│   │   ├── auth/                  # Authentication services
│   │   ├── pages/                 # App screens
│   │   │   ├── home_page.dart     # Main camera interface
│   │   │   ├── song_recommend.dart # Music recommendations
│   │   │   ├── movie_recommend.dart # Movie recommendations
│   │   │   ├── mood_history.dart  # Mood tracking
│   │   │   └── ...
│   │   ├── utils/                 # Utility functions
│   │   └── widgets/               # Reusable components
│   ├── assets/                    # Images and ML models
│   └── android/ios/web/           # Platform-specific code
├── backend/                       # Node.js API server
│   ├── Controllers/               # API route handlers
│   ├── Models/                    # Database models
│   ├── Routes/                    # API endpoints
│   └── Middlewares/               # Authentication & validation
├── API/                          # Python ML services
│   └── flask/                    # TensorFlow model serving
└── README.md
```

## 🔧 API Endpoints

### Authentication
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `GET /auth/verify` - Token verification

### Mood Detection
- `POST /mood/get-mood` - Upload image for mood analysis
- `POST /mood/save-mood` - Save detected mood to history
- `GET /mood/history` - Retrieve user's mood history

### Recommendations
- `POST /recommend` - Get personalized recommendations
- `GET /preferences/get` - Retrieve user preferences
- `POST /preferences/save` - Save user preferences

## 🎨 Design System

### Color Palette
- **Primary**: Deep Purple (`#1E0A2E`)
- **Secondary**: Purple (`#7B1FA2`)
- **Accent**: White (`#FFFFFF`)
- **Gradients**: Purple variations with opacity

### Typography
- **Headers**: Bold, 20-24px
- **Body**: Regular, 14-16px
- **Captions**: Light, 12-14px

### Components
- **Cards**: Rounded corners (20px), subtle shadows
- **Buttons**: Gradient backgrounds, haptic feedback
- **Dialogs**: Modal overlays with blur effects

## 🤖 Machine Learning Model

### Emotion Detection
- **Input**: 224x224 RGB images
- **Architecture**: Convolutional Neural Network
- **Classes**: Happy, Sad, Angry, Neutral, Surprised, Fear, Disgust
- **Accuracy**: ~85% on validation dataset

### Recommendation Algorithm
- **Content-Based Filtering**: Mood-to-genre mapping
- **Collaborative Filtering**: User behavior analysis
- **Hybrid Approach**: Combines multiple recommendation strategies

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (iOS 11+)
- 🔄 Web (Beta)
- 🔄 Desktop (Windows/macOS/Linux)

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run widget tests
flutter test test/widget_test.dart
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Authors

- **[Your Name]** - *Initial work* - [iahsanzia](https://github.com/iahsanzia)

## 🙏 Acknowledgments

- TensorFlow team for the ML framework
- Flutter team for the amazing mobile framework
- Spotify for music API integration
- The Movie Database (TMDb) for movie data

## 📞 Support

If you have any questions or need help, please:
- Open an issue on GitHub
- Contact: [your-email@example.com]

---

**Made with ❤️ using Flutter & TensorFlow**