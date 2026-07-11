const twilio = require('twilio');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const client = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);

const sendOtp = async (req, res) => {
  try {
    const { phone_number } = req.body;
    if (!phone_number) return res.status(400).json({ error: 'Phone number is required' });

    await client.verify.v2.services(process.env.TWILIO_VERIFY_SERVICE_SID)
      .verifications
      .create({ to: phone_number, channel: 'sms' });

    res.status(200).json({ message: 'OTP sent successfully' });
  } catch (error) {
    console.error('Send OTP error:', error);
    res.status(500).json({ error: 'Failed to send OTP', message: error.message });
  }
};

const verifyOtp = async (req, res) => {
  try {
    const { phone_number, code } = req.body;
    if (!phone_number || !code) return res.status(400).json({ error: 'Phone number and code are required' });

    const verificationCheck = await client.verify.v2.services(process.env.TWILIO_VERIFY_SERVICE_SID)
      .verificationChecks
      .create({ to: phone_number, code: code });

    if (verificationCheck.status !== 'approved') {
      return res.status(401).json({ error: 'Invalid OTP' });
    }

    // Check if user already exists
    let user = await User.findOne({ phoneNumber: phone_number });
    
    if (!user) {
      // Create new user
      user = new User({
        phoneNumber: phone_number,
      });
      await user.save();
    }

    // Generate JWT
    const token = jwt.sign(
      { id: user._id, phone_number: user.phoneNumber },
      process.env.JWT_SECRET || 'your_super_secret_jwt_key',
      { expiresIn: '30d' }
    );

    res.status(200).json({
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        phoneNumber: user.phoneNumber,
        age: user.age,
        height: user.height,
        weight: user.weight,
      }
    });
  } catch (error) {
    console.error('Verify OTP error:', error);
    res.status(500).json({ error: 'Failed to verify OTP', message: error.message });
  }
};

module.exports = { sendOtp, verifyOtp };
