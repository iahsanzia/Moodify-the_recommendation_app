// Routes/recommendationRoutes.js
const express = require('express');
const router = express.Router();
const { getRecommendation } = require('../Controllers/RecommendationController');

router.post('/', getRecommendation);

module.exports = router;
