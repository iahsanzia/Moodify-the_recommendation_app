const express = require('express');
const router = express.Router();
const UserController = require('../Controllers/UserController'); // Ensure this path is correct

// Route to handle saving preferences
router.post('/save', UserController.savePreferences);

module.exports = router;
