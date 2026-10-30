'use strict';

const express = require('express');
const path    = require('path');
const multer  = require('multer');
const fs      = require('fs');
const config  = require('../config');
const { requireAuth, requireRole } = require('../middleware/auth');
const { dispatchWorkers } = require('../services/dispatch');

const router = express.Router();

// ── Multer storage ────────────────────────────────────────────────────────────

const docsDir = path.join(config.STORAGE_PATH, 'documents');
if (!fs.existsSync(docsDir)) {
  fs.mkdirSync(docsDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, docsDir),
  filename: (req, file, cb) => {
    const ext      = path.extname(file.originalname) || '';
    const safeName = `${req.user.id}_${file.fieldname}_${Date.now()}${ext}`;
    cb(null, safeName);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5 MB
  fileFilter: (_req, file, cb) => {
    const allowed = ['.jpg', '.jpeg', '.png', '.pdf'];
    const ext     = path.extname(file.originalname).toLowerCase();
    if (allowed.includes(ext)) {
      cb(null, true);
    } else {
      cb(new Error('Only JPG, PNG and PDF files are allowed.'));
    }
  },
});

// ── GET /api/workers ──────────────────────────────────────────────────────────

router.get('/', requireAuth, (req, res) => {
  try {
    const db = req.app.locals.db;
    let { lat, lng, radius, category } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({ success: false, error: 'lat and lng query parameters are required.' });
    }

    lat    = parseFloat(lat);
    lng    = parseFloat(lng);
    radius = Math.min(parseFloat(radius) || 5, 5); // max 5 km

    if (isNaN(lat) || isNaN(lng)) {
      return res.status(400).json({ success: false, error: 'lat and lng must be valid numbers.' });
    }

    const workers = dispatchWorkers(db, { lat, lng, radius, category });
    return res.json({ success: true, data: workers });
  } catch (err) {
    console.error('[workers/list]', err);
    return res.status(500).json({ success: false, error: 'Could not fetch workers.' });
  }
});

// ── GET /api/workers/:id ──────────────────────────────────────────────────────

router.get('/:id', requireAuth, (req, res) => {
  try {
    const db     = req.app.locals.db;
    const userId = parseInt(req.params.id, 10);

    if (isNaN(userId)) {
      return res.status(400).json({ success: false, error: 'Invalid worker id.' });
    }

    const user = db.prepare(`
      SELECT id, name, email, mobile, role, cooperative_id, is_verified, created_at
      FROM users WHERE id = ? AND role = 'worker'
    `).get(userId);

    if (!user) {
      return res.status(404).json({ success: false, error: 'Worker not found.' });
    }

    const profile = db.prepare('SELECT * FROM worker_profiles WHERE user_id = ?').get(userId);

    return res.json({ success: true, data: { ...user, worker_profile: profile || null } });
  } catch (err) {
    console.error('[workers/:id]', err);
    return res.status(500).json({ success: false, error: 'Could not fetch worker.' });
  }
});

// ── POST /api/workers/documents ───────────────────────────────────────────────

router.post(
  '/documents',
  requireAuth,
  requireRole('worker'),
  (req, res, next) => {
    upload.fields([
      { name: 'aadhaar_doc',     maxCount: 1 },
      { name: 'police_doc',      maxCount: 1 },
      { name: 'certificate_doc', maxCount: 1 },
    ])(req, res, (err) => {
      if (err) {
        return res.status(400).json({ success: false, error: err.message });
      }
      next();
    });
  },
  (req, res) => {
    try {
      const db     = req.app.locals.db;
      const userId = req.user.id;
      const files  = req.files || {};

      if (!files.aadhaar_doc && !files.police_doc && !files.certificate_doc) {
        return res.status(400).json({ success: false, error: 'At least one document file is required.' });
      }

      const profile = db.prepare('SELECT id FROM worker_profiles WHERE user_id = ?').get(userId);
      if (!profile) {
        return res.status(404).json({ success: false, error: 'Worker profile not found.' });
      }

      const updates = [];
      const params  = [];

      if (files.aadhaar_doc) {
        updates.push('aadhaar_doc = ?, aadhaar_status = ?');
        params.push(files.aadhaar_doc[0].filename, 'pending');
      }
      if (files.police_doc) {
        updates.push('police_doc = ?, police_status = ?');
        params.push(files.police_doc[0].filename, 'pending');
      }
      if (files.certificate_doc) {
        updates.push('certificate_doc = ?, certificate_status = ?');
        params.push(files.certificate_doc[0].filename, 'pending');
      }

      params.push(userId);
      db.prepare(`UPDATE worker_profiles SET ${updates.join(', ')} WHERE user_id = ?`).run(...params);

      const updated = db.prepare('SELECT * FROM worker_profiles WHERE user_id = ?').get(userId);
      return res.json({ success: true, data: updated });
    } catch (err) {
      console.error('[workers/documents]', err);
      return res.status(500).json({ success: false, error: 'Could not upload documents.' });
    }
  }
);

// ── PATCH /api/workers/availability ──────────────────────────────────────────

router.patch('/availability', requireAuth, requireRole('worker'), (req, res) => {
  try {
    const db     = req.app.locals.db;
    const userId = req.user.id;

    const profile = db.prepare('SELECT id, availability FROM worker_profiles WHERE user_id = ?').get(userId);
    if (!profile) {
      return res.status(404).json({ success: false, error: 'Worker profile not found.' });
    }

    const newAvailability = profile.availability === 1 ? 0 : 1;
    db.prepare('UPDATE worker_profiles SET availability = ? WHERE user_id = ?').run(newAvailability, userId);

    return res.json({
      success: true,
      data: { availability: newAvailability, message: newAvailability ? 'You are now available.' : 'You are now unavailable.' },
    });
  } catch (err) {
    console.error('[workers/availability]', err);
    return res.status(500).json({ success: false, error: 'Could not update availability.' });
  }
});

module.exports = router;
