const { analyzeImage } = require('../services/geminiService');
const Scan = require('../models/Scan');

const scanImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No image uploaded' });
    }

    const imageBuffer = req.file.buffer;
    const mimeType = req.file.mimetype;
    
    // Parse the profile sent from the frontend
    let profileData = {};
    if (req.body.profile) {
      try {
        profileData = JSON.parse(req.body.profile);
      } catch (e) {
        console.error('Failed to parse profile JSON', e);
      }
    }
    const concern = req.body.concern || '';

    let profileText = "";
    if (profileData.age || profileData.weight || profileData.height) {
      profileText += `Age: ${profileData.age || 'Unknown'}, Height: ${profileData.height || 'Unknown'} cm, Weight: ${profileData.weight || 'Unknown'} kg.\n`;
    }
    if (profileData.hasDiabetes) {
      profileText += `Medical Condition: The user has diabetes. Please carefully analyze sugar and carb content.\n`;
    }
    if (profileData.additionalNotes) {
      profileText += `Additional Notes from User: ${profileData.additionalNotes}\n`;
    }
    if (concern) {
      profileText += `\nURGENT CONCERN FOR THIS SCAN: "${concern}"\nPlease explicitly address this concern in your summary.\n`;
    }

    // Call Gemini
    const analysisJson = await analyzeImage(imageBuffer, mimeType, profileText);

    // If Gemini determined it cannot read the image
    if (analysisJson.error) {
      return res.status(400).json({ error: analysisJson.error });
    }

    // Save to history only if user is logged in
    if (req.dbUserId) {
      const scanRecord = new Scan({
        userId: req.dbUserId,
        productName: analysisJson.productName || 'Unknown Product',
        overallHealthScore: analysisJson.overallHealthScore,
        overallIndicator: analysisJson.overallIndicator,
        summary: analysisJson.summary,
        analysisJson: analysisJson
      });
      await scanRecord.save();
    }

    res.status(200).json(analysisJson);
  } catch (error) {
    console.error('Scan Error:', error);
    res.status(500).json({ error: 'Failed to process scan', message: error.message });
  }
};

module.exports = { scanImage };

module.exports = { scanImage };
