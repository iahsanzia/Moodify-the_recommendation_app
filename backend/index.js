// index.js
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const helmet = require('helmet'); // Add security headers
const rateLimit = require('express-rate-limit'); // Add rate limiting
require('dotenv').config();
require('./Models/db');
const AuthRouter = require('./Routes/AuthRouter');
const moodRoutes = require('./Routes/moodRoutes');
const preferencesRoutes = require('./Routes/preferencesRoutes'); 
const recommendationRoutes = require('./Routes/recommendationRoutes'); 

const app = express();
const PORT = process.env.Port || 8000;

// Security Middleware
app.use(helmet()); // Security headers

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.'
});
app.use('/auth', limiter); // Apply rate limiting to auth routes

// CORS configuration
const corsOptions = {
  origin: process.env.NODE_ENV === 'production' 
    ? ['https://yourdomain.com'] // Replace with your actual domain
    : ['http://localhost:3000', 'http://127.0.0.1:3000'],
  credentials: true,
  optionsSuccessStatus: 200
};

// Middleware
app.use(bodyParser.json({ limit: '10mb' })); // Limit payload size
app.use(cors(corsOptions));

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
