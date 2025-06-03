const mongoose = require('mongoose');
const Schema = mongoose.Schema;

// Define a schema for mood entries
const MoodEntrySchema = new Schema({
  mood: {
    type: String,
    required: true,
  },
  confidence: {
    type: String,
    required: true,
  },
  timestamp: {
    type: Date,
    default: Date.now,
  },
});

// Define a schema for user preferences
const UserPreferencesSchema = new Schema({
  musicGenres: [String],
  movieGenres: [String],
  musicMoodMap: { type: Map, of: String },
  movieMoodMap: { type: Map, of: String },
  languages: [String],
  era: [String],
  actors: [String],
  actress: [String],
  directors: [String],
  singers: [String],
});

// Define the user schema
const UserSchema = new Schema({
  name: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
  },
  password: {
    type: String,
    required: true,
  },
  moodHistory: [MoodEntrySchema], // Store mood entries
  preferences: UserPreferencesSchema, // Store user preferences
});

const UserModel = mongoose.model('users', UserSchema);

module.exports = UserModel;
