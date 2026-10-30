'use strict';

const express = require('express');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// ── POST /api/grievances ──────────────────────────────────────────────────────

router.post('/', requireAuth, (req, res) => {
  try {
    const db = req.app.locals.db;
    const { booking_id, description } = req.body;

    if (!booking_id || isNaN(parseInt(booking_id, 10))) {
      return res.status(400).json({ success: false, error: 'booking_id is required.' });
    }
    if (!description || typeof description !== 'string' || description.trim().length < 10) {
      return res.status(400).json({ success: false, error: 'description must be at least 10 characters.' });
    }

    const bookingId = parseInt(booking_id, 10);
    const booking   = db.prepare('SELECT * FROM bookings WHERE id = ?').get(bookingId);

    if (!booking) {
      return res.status(404).json({ success: false, error: 'Booking not found.' });
    }

    // Only booking participants (customer or worker) may file a grievance
    const userId = req.user.id;
    if (booking.customer_id !== userId && booking.worker_id !== userId && req.user.role !== 'cooperative_admin') {
      return res.status(403).json({ success: false, error: 'You are not a participant in this booking.' });
    }

    const result = db.prepare(`
      INSERT INTO grievances (booking_id, filed_by_id, description)
      VALUES (?, ?, ?)
    `).run(bookingId, userId, description.trim());

    const grievance = db.prepare('SELECT * FROM grievances WHERE id = ?').get(result.lastInsertRowid);
    return res.status(201).json({ success: true, data: grievance });
  } catch (err) {
    console.error('[grievances/create]', err);
    return res.status(500).json({ success: false, error: 'Could not file grievance.' });
  }
});

// ── GET /api/grievances ───────────────────────────────────────────────────────

router.get('/', requireAuth, (req, res) => {
  try {
    const db     = req.app.locals.db;
    const userId = req.user.id;

    // Customers and workers see their own grievances; admins see all via admin route
    const grievances = db.prepare(`
      SELECT g.*,
             b.status AS booking_status,
             b.total_amount,
             filer.name AS filed_by_name
      FROM grievances g
      JOIN bookings b ON b.id = g.booking_id
      JOIN users filer ON filer.id = g.filed_by_id
      WHERE g.filed_by_id = ?
         OR (b.customer_id = ? OR b.worker_id = ?)
      ORDER BY g.created_at DESC
    `).all(userId, userId, userId);

    return res.json({ success: true, data: grievances });
  } catch (err) {
    console.error('[grievances/list]', err);
    return res.status(500).json({ success: false, error: 'Could not fetch grievances.' });
  }
});

module.exports = router;
