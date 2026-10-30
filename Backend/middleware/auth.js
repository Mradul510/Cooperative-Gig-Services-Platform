'use strict';

const jwt    = require('jsonwebtoken');
const config = require('../config');

/**
 * Middleware: verify Bearer JWT and attach decoded payload to req.user.
 */
function requireAuth(req, res, next) {
  const authHeader = req.headers['authorization'] || req.headers['Authorization'];
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, error: 'Authorization token required.' });
  }

  const token = authHeader.slice(7);
  try {
    const decoded = jwt.verify(token, config.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ success: false, error: 'Token has expired.' });
    }
    return res.status(401).json({ success: false, error: 'Invalid token.' });
  }
}

/**
 * Middleware factory: ensure req.user has one of the specified roles.
 * Must be used AFTER requireAuth.
 *
 * @param {...string} roles - Allowed role strings
 */
function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ success: false, error: 'Not authenticated.' });
    }
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        error: `Access denied. Required role(s): ${roles.join(', ')}.`,
      });
    }
    next();
  };
}

module.exports = { requireAuth, requireRole };
