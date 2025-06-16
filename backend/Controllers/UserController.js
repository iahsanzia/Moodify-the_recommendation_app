const UserModel = require('../Models/Users'); // Ensure this path is correct

const savePreferences = async (req, res) => {
  try {
    const { email, musicGenres, movieGenres, musicMoodMap, movieMoodMap, languages, era, actors, actress, directors, singers } = req.body;

    // Retrieve user by email
    const user = await UserModel.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Save preferences to the user's record, including mood maps
    user.preferences = {
      musicGenres,
      movieGenres,
      musicMoodMap, // Add mood map for music
      movieMoodMap, // Add mood map for movies
      languages,
      era,
      actors,
      actress,
      directors,
      singers,
    };

    await user.save();

    return res.status(200).json({ message: 'Preferences saved successfully' });
  } catch (error) {
    return res.status(500).json({ message: 'Error saving preferences', error });
  }
};

// Get user preferences
const getPreferences = async (req, res) => {
  try {
    const { email } = req.query;

    // Retrieve user by email
    const user = await UserModel.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    return res.status(200).json({ 
      preferences: user.preferences || {},
      message: 'Preferences retrieved successfully' 
    });
  } catch (error) {
    return res.status(500).json({ message: 'Error retrieving preferences', error });
  }
};

// Get user mood history
const getMoodHistory = async (req, res) => {
  try {
    const { email } = req.query;

    // Retrieve user by email
    const user = await UserModel.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Sort mood history by timestamp (newest first)
    const sortedMoodHistory = (user.moodHistory || []).sort((a, b) => 
      new Date(b.timestamp) - new Date(a.timestamp)
    );

    return res.status(200).json({ 
      moods: sortedMoodHistory,
      message: 'Mood history retrieved successfully' 
    });
  } catch (error) {
    return res.status(500).json({ message: 'Error retrieving mood history', error });
  }
};

module.exports = { savePreferences, getPreferences, getMoodHistory };
