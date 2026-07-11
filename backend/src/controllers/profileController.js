const User = require('../models/User');

const getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.dbUserId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.status(200).json({
      id: user._id,
      username: user.username,
      phoneNumber: user.phoneNumber,
      age: user.age,
      height: user.height,
      weight: user.weight,
    });
  } catch (error) {
    console.error('Error fetching profile:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

const updateProfile = async (req, res) => {
  try {
    const { username, age, height, weight } = req.body;
    
    // Build update object
    const updateData = { age, height, weight };
    if (username !== undefined) {
      updateData.username = username;
    }

    const user = await User.findByIdAndUpdate(
      req.dbUserId,
      updateData,
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.status(200).json({
      id: user._id,
      username: user.username,
      phoneNumber: user.phoneNumber,
      age: user.age,
      height: user.height,
      weight: user.weight,
    });
  } catch (error) {
    if (error.code === 11000 && error.keyPattern && error.keyPattern.username) {
      return res.status(409).json({ error: 'Username already taken' });
    }
    console.error('Error updating profile:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

module.exports = { getProfile, updateProfile };
