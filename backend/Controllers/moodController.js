// moodController.js

const User = require('../Models/Users'); // Import your user model
const axios = require('axios');
const FormData = require('form-data');

// Handle the mood prediction from the Flask API
const getMood = async (req, res) => {
  if (!req.file) {
    return res.status(400).send({ error: 'No image uploaded' });
  }

  try {
    // Prepare image data for Flask API
    const formData = new FormData();
    formData.append('image', req.file.buffer, {
      filename: 'image.jpg',
      contentType: req.file.mimetype,
    });

    // Send the image to Flask for mood prediction
    const flaskResponse = await axios.post('http://127.0.0.1:5000/predict', formData, {
      headers: formData.getHeaders(),
    });

    const { predicted_mood, confidence } = flaskResponse.data;

    res.status(200).send({
      predicted_mood,
      confidence,
      message: 'Mood detected successfully',
    });
  } catch (error) {
    console.error('Error communicating with Flask API:', error.response ? error.response.data : error.message);
    res.status(500).send({
      error: 'Failed to get mood prediction from Flask API',
      details: error.response ? error.response.data : error.message,
    });
  }
};

// Handle saving mood to user's history
const saveMood = async (req, res) => {
  try {
    const { email, mood, confidence } = req.body; // 'email' instead of 'userEmail'

    // Find the user by email
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Add mood to the user's history
    user.moodHistory.push({ mood, confidence, timestamp: new Date() });

    // Ensure the history doesn't grow too large
    if (user.moodHistory.length > 10) {
      user.moodHistory.splice(0, 5);
    }

    await user.save();
    return res.status(200).send({ message: 'Mood saved successfully', user });
  } catch (error) {
    console.error('Error saving mood:', error.message);
    return res.status(500).send({ error: 'Failed to save mood' });
  }
};

module.exports = {
  getMood,
  saveMood,
};
