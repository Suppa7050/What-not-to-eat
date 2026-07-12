const nodemailer = require('nodemailer');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Simple in-memory OTP store (email -> { code, expiresAt })
// In a large production app, use Redis or a MongoDB collection for this.
const otpStore = new Map();

// Configure Nodemailer transporter
// using a generic Ethereal test account or Gmail if provided
const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || 'smtp.ethereal.email',
  port: process.env.SMTP_PORT || 587,
  secure: process.env.SMTP_SECURE === 'true', 
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

const sendOtp = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ error: 'Email is required' });

    // Generate a 6-digit OTP
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Set expiration to 5 minutes from now
    otpStore.set(email.toLowerCase(), {
      code,
      expiresAt: Date.now() + 5 * 60 * 1000,
    });

    // We only attempt to send the email if SMTP credentials are provided,
    // otherwise we just log it (useful for local development).
    if (process.env.SMTP_USER) {
      await transporter.sendMail({
        from: '"What Not To Eat" <noreply@whatnottoeat.com>',
        to: email,
        subject: 'Your Login OTP',
        text: `Your OTP is: ${code}. It will expire in 5 minutes.`,
      });
    } else {
      console.log(`[DEV MODE] OTP for ${email} is ${code}`);
    }

    res.status(200).json({ message: 'OTP sent successfully' });
  } catch (error) {
    console.error('Send OTP error:', error);
    res.status(500).json({ error: 'Failed to send OTP', message: error.message });
  }
};

const verifyOtp = async (req, res) => {
  try {
    const { email, code } = req.body;
    if (!email || !code) return res.status(400).json({ error: 'Email and code are required' });

    const normalizedEmail = email.toLowerCase();
    const stored = otpStore.get(normalizedEmail);

    if (!stored) {
      return res.status(401).json({ error: 'No OTP requested or OTP expired' });
    }

    if (Date.now() > stored.expiresAt) {
      otpStore.delete(normalizedEmail);
      return res.status(401).json({ error: 'OTP has expired' });
    }

    if (stored.code !== code) {
      return res.status(401).json({ error: 'Invalid OTP' });
    }

    // OTP is valid!
    otpStore.delete(normalizedEmail);

    // Check if user already exists
    let user = await User.findOne({ email: normalizedEmail });
    
    if (!user) {
      // Create new user
      user = new User({
        email: normalizedEmail,
      });
      await user.save();
    }

    // Generate JWT
    const token = jwt.sign(
      { id: user._id, email: user.email },
      process.env.JWT_SECRET || 'your_super_secret_jwt_key',
      { expiresIn: '30d' }
    );

    res.status(200).json({
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        email: user.email,
        username: user.username,
        age: user.age,
        height: user.height,
        weight: user.weight,
        hasDiabetes: user.hasDiabetes,
        additionalNotes: user.additionalNotes,
      }
    });
  } catch (error) {
    console.error('Verify OTP error:', error);
    res.status(500).json({ error: 'Failed to verify OTP', message: error.message });
  }
};

module.exports = { sendOtp, verifyOtp };
