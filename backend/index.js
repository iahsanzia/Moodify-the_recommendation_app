// index.js
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
require('dotenv').config();
require('./Models/db');
const AuthRouter = require('./Routes/AuthRouter');
const moodRoutes = require('./Routes/moodRoutes');
const preferencesRoutes = require('./Routes/preferencesRoutes'); 
const recommendationRoutes = require('./Routes/recommendationRoutes'); 

const app = express();
const PORT = process.env.Port || 8000;

// Middleware
app.use(bodyParser.json());
app.use(cors());

// Routes
app.use('/auth', AuthRouter);
app.use('/mood', moodRoutes);
app.use('/preferences', preferencesRoutes);
app.use('/recommend', recommendationRoutes);


app.get('/ping', (req, res) => {
  res.send('PONG');
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
});
