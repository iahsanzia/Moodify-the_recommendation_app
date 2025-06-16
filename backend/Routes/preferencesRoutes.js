const express = require('express');
const router = express.Router();
const UserController = require('../Controllers/UserController'); // Ensure this path is correct

// Route to handle saving preferences
router.post('/save', UserController.savePreferences);

// Route to get user preferences
router.get('/get', UserController.getPreferences);

module.exports = router;
