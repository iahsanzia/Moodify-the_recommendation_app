const multer = require('multer');

// Set up multer for in-memory file uploads
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

module.exports = {
  upload,
};
