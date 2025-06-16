const axios = require('axios');
const User = require('../Models/Users');

// Normalize mood into 4 buckets
const normalizeMood = (mood) => {
  const moodMap = {
    Happy: 'happy',
    Relaxed: 'happy',
    Sad: 'sad',
    Stressed: 'sad',
    Angry: 'angry',
    Energetic: 'angry'
  };
  return moodMap[mood] || 'neutral';
};

exports.getRecommendation = async (req, res) => {
  const { email } = req.body;

  try {
    console.log('🎬 Getting recommendations for email:', email);
    
    const user = await User.findOne({ email });
    if (!user || !user.preferences) {
      console.log('❌ User not found or no preferences set for:', email);
      return res.status(404).json({ error: 'User not found or no preferences set.' });
    }

    const prefs = user.preferences;
    const recentMood = user.moodHistory?.slice(-1)[0] || 'Happy';
    const normalizedMood = normalizeMood(recentMood);

    console.log('🎭 User preferences:', prefs);
    console.log('😊 Recent mood:', recentMood, '-> normalized:', normalizedMood);

    const payload = {
      mood: normalizedMood,
      musicGenre: prefs.musicMoodMap[recentMood] || prefs.musicGenres[0] || 'Pop',
      movieGenre: prefs.movieMoodMap[recentMood] || prefs.movieGenres[0] || 'Action',
      language: prefs.languages[0]?.toLowerCase().slice(0, 2) || 'en',
      era: prefs.era[0] || '2020s',
      actors: prefs.actors || [],
      actress: prefs.actress || [],
      directors: prefs.directors || [],
      singers: prefs.singers || []
    };

    console.log('🚀 Sending payload to Flask:', payload);
    
    const flaskRes = await axios.post('http://141.147.115.222:5000/recommendation', payload);
    console.log('✅ Flask response received:', flaskRes.data);
    return res.json(flaskRes.data);

  } catch (err) {
    console.error('❌ RecommendationController error:', err.message);
    if (err.response) {
      console.error('❌ Flask API error response:', err.response.status, err.response.data);
    }
    return res.status(500).json({ error: 'Failed to get recommendations.', details: err.message });
  }
};
