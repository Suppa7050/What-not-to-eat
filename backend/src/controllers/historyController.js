const Scan = require('../models/Scan');

const getHistory = async (req, res) => {
  try {
    const scans = await Scan.find({ userId: req.dbUserId })
      .sort({ createdAt: -1 });

    const formattedScans = scans.map(scan => {
      // Flatten so analysisJson properties are at root level
      return {
        ...scan.analysisJson,
        id: scan._id.toString(),
        createdAt: scan.createdAt
      };
    });

    res.status(200).json(formattedScans);
  } catch (error) {
    console.error('Error fetching history:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

const getScanById = async (req, res) => {
  try {
    const scan = await Scan.findOne({ _id: req.params.id, userId: req.dbUserId });
    
    if (!scan) {
      return res.status(404).json({ error: 'Scan not found' });
    }

    res.status(200).json({
      ...scan.analysisJson,
      id: scan._id.toString(),
      createdAt: scan.createdAt
    });
  } catch (error) {
    console.error('Error fetching scan details:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

const deleteScan = async (req, res) => {
  try {
    const scan = await Scan.findOneAndDelete({ _id: req.params.id, userId: req.dbUserId });
    
    if (!scan) {
      return res.status(404).json({ error: 'Scan not found' });
    }

    res.status(200).json({ message: 'Scan deleted successfully' });
  } catch (error) {
    console.error('Error deleting scan:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

module.exports = { getHistory, getScanById, deleteScan };
