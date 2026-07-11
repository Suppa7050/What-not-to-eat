const jwt = require('jsonwebtoken');
const User = require('../models/User');

const verifyToken = async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Unauthorized', message: 'No token provided' });
  }

  const token = authHeader.split('Bearer ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your_super_secret_jwt_key');
    req.user = decoded; // contains phone_number, etc.
    
    // Attach DB user ID
    if (decoded.id) {
      req.dbUserId = decoded.id;
    } else {
      const dbUser = await User.findOne({ phoneNumber: decoded.phone_number });
      if (dbUser) {
        req.dbUserId = dbUser._id;
      }
    }

    next();
  } catch (error) {
    console.error('Error verifying JWT token:', error);
    return res.status(401).json({ error: 'Unauthorized', message: 'Invalid token' });
  }
};

module.exports = { verifyToken };
