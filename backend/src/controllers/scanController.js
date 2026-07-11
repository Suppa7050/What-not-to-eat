const { analyzeImage } = require('../services/geminiService');
const Scan = require('../models/Scan');
const User = require('../models/User');

const scanImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No image uploaded' });
    }

    const imageBuffer = req.file.buffer;
    const mimeType = req.file.mimetype;

    // Fetch user profile to pass to Gemini for personalization
    const user = await User.findById(req.dbUserId);
    let profileText = "";
    if (user && (user.age || user.weight || user.height)) {
      profileText = `Age: ${user.age || 'Unknown'}, Height: ${user.height || 'Unknown'} cm, Weight: ${user.weight || 'Unknown'} kg.`;
    }

    // Call Gemini
    const analysisJson = await analyzeImage(imageBuffer, mimeType, profileText);

    // If Gemini determined it cannot read the image
    if (analysisJson.error) {
      return res.status(400).json({ error: analysisJson.error });
    }

    // Save to history
    const scanRecord = new Scan({
      userId: req.dbUserId,
      productName: analysisJson.productName || 'Unknown Product',
      overallHealthScore: analysisJson.overallHealthScore,
      overallIndicator: analysisJson.overallIndicator,
      summary: analysisJson.summary,
      analysisJson: analysisJson
    });

    await scanRecord.save();

    res.status(200).json(analysisJson);
  } catch (error) {
    console.error('Scan Error:', error);
    res.status(500).json({ error: 'Failed to process scan', message: error.message });
  }
};

module.exports = { scanImage };
