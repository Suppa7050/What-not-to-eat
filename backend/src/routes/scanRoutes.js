const express = require('express');
const router = express.Router();
const multer = require('multer');
const { scanImage } = require('../controllers/scanController');
const { optionalVerifyToken } = require('../middlewares/authMiddleware');

// Setup multer for memory storage (we don't save the image to disk as per requirements)
const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10 MB limit
  }
});

router.post('/', optionalVerifyToken, upload.single('image'), scanImage);

module.exports = router;
