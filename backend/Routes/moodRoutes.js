const express = require('express');
const multerConfig = require('../Middlewares/multerConfig');
const moodController = require('../Controllers/moodController');

const router = express.Router();

// POST route to handle the uploaded image for mood detection
router.post('/get-mood', multerConfig.upload.single('image'), moodController.getMood);

// POST route to save the detected mood to user's history
router.post('/save-mood', moodController.saveMood);

module.exports = router;
