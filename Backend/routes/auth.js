'use strict';

const express  = require('express');
const bcrypt   = require('bcryptjs');
const jwt      = require('jsonwebtoken');
const config   = require('../config');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// ── Helpers ──────────────────────────────────────────────────────────────────

function generateToken(user) {
  return jwt.sign(
    { id: user.id, email: user.email, role: user.role, name: user.name },
    config.JWT_SECRET,
    { expiresIn: config.JWT_EXPIRY }
  );
}

function sanitizeUser(user) {
  const { password_hash, ...safe } = user;
  return safe;
}

function validateEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function validateMobile(mobile) {
  return /^\d{10}$/.test(mobile);
}

// ── POST /api/auth/register ───────────────────────────────────────────────────

router.post('/register', (req, res) => {
  try {
    const db = req.app.locals.db;
    const { name, email, mobile, password, role, cooperative_id } = req.body;

    // Validate required fields
    if (!name || typeof name !== 'string' || name.trim().length < 2) {
      return res.status(400).json({ success: false, error: 'name must be at least 2 characters.' });
    }
    if (!email || !validateEmail(email)) {
      return res.status(400).json({ success: false, error: 'A valid email is required.' });
    }
    if (!mobile || !validateMobile(mobile)) {
      return res.status(400).json({ success: false, error: 'mobile must be exactly 10 digits.' });
    }
    if (!password || password.length < 6) {
      return res.status(400).json({ success: false, error: 'password must be at least 6 characters.' });
    }
    const validRoles = ['customer', 'worker', 'cooperative_admin'];
    if (!role || !validRoles.includes(role)) {
      return res.status(400).json({ success: false, error: `role must be one of: ${validRoles.join(', ')}.` });
    }

    // Check uniqueness
    const existingEmail  = db.prepare('SELECT id FROM users WHERE email = ?').get(email.toLowerCase());
    if (existingEmail) {
      return res.status(409).json({ success: false, error: 'Email is already registered.' });
    }
    const existingMobile = db.prepare('SELECT id FROM users WHERE mobile = ?').get(mobile);
    if (existingMobile) {
      return res.status(409).json({ success: false, error: 'Mobile number is already registered.' });
    }

    // Validate cooperative_id if provided
    if (cooperative_id !== undefined && cooperative_id !== null) {
      const coop = db.prepare('SELECT id FROM cooperatives WHERE id = ?').get(cooperative_id);
      if (!coop) {
        return res.status(400).json({ success: false, error: 'cooperative_id does not exist.' });
      }
    }

    const password_hash = bcrypt.hashSync(password, 10);

    const insertTxn = db.transaction(() => {
      const result = db.prepare(`
        INSERT INTO users (name, email, mobile, password_hash, role, cooperative_id, is_verified)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      `).run(
        name.trim(),
        email.toLowerCase(),
        mobile,
        password_hash,
        role,
        cooperative_id || null,
        0
      );

      const userId = result.lastInsertRowid;

      if (role === 'worker') {
        db.prepare(`
          INSERT INTO worker_profiles (user_id, aadhaar_status, police_status, certificate_status)
          VALUES (?, 'pending', 'pending', 'pending')
        `).run(userId);
      }

      return userId;
    });

    const userId = insertTxn();
    const newUser = db.prepare('SELECT * FROM users WHERE id = ?').get(userId);
    const token   = generateToken(newUser);

    return res.status(201).json({
      success: true,
      data: { token, user: sanitizeUser(newUser) },
    });
  } catch (err) {
    console.error('[auth/register]', err);
    return res.status(500).json({ success: false, error: 'Registration failed.' });
  }
});

// ── POST /api/auth/login ──────────────────────────────────────────────────────

router.post('/login', (req, res) => {
  try {
    const db = req.app.locals.db;
    const { identifier, password } = req.body;

    if (!identifier || typeof identifier !== 'string') {
      return res.status(400).json({ success: false, error: 'identifier (email or mobile) is required.' });
    }
    if (!password || typeof password !== 'string') {
      return res.status(400).json({ success: false, error: 'password is required.' });
    }

    // Look up by email OR mobile
    const user = db.prepare(
      'SELECT * FROM users WHERE email = ? OR mobile = ?'
    ).get(identifier.toLowerCase(), identifier);

    if (!user) {
      return res.status(401).json({ success: false, error: 'Invalid credentials.' });
    }

    const valid = bcrypt.compareSync(password, user.password_hash);
    if (!valid) {
      return res.status(401).json({ success: false, error: 'Invalid credentials.' });
    }

    const token = generateToken(user);
    return res.json({ success: true, data: { token, user: sanitizeUser(user) } });
  } catch (err) {
    console.error('[auth/login]', err);
    return res.status(500).json({ success: false, error: 'Login failed.' });
  }
});

// ── GET /api/auth/me ──────────────────────────────────────────────────────────

router.get('/me', requireAuth, (req, res) => {
  try {
    const db   = req.app.locals.db;
    const user = db.prepare('SELECT * FROM users WHERE id = ?').get(req.user.id);

    if (!user) {
      return res.status(404).json({ success: false, error: 'User not found.' });
    }

    const safe = sanitizeUser(user);

    if (user.role === 'worker') {
      const profile = db.prepare('SELECT * FROM worker_profiles WHERE user_id = ?').get(user.id);
      safe.worker_profile = profile || null;
    }

    return res.json({ success: true, data: safe });
  } catch (err) {
    console.error('[auth/me]', err);
    return res.status(500).json({ success: false, error: 'Could not fetch profile.' });
  }
});

module.exports = router;
