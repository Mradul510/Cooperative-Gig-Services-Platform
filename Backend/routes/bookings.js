'use strict';

const express = require('express');
const { requireAuth, requireRole } = require('../middleware/auth');
const { computeSplit } = require('../services/fee');

const router = express.Router();

// ── POST /api/bookings ────────────────────────────────────────────────────────

router.post('/', requireAuth, requireRole('customer'), (req, res) => {
  try {
    const db = req.app.locals.db;
    const { worker_id, service_id, slot_type, booking_time } = req.body;

    // Validate required fields
    if (!worker_id || isNaN(parseInt(worker_id, 10))) {
      return res.status(400).json({ success: false, error: 'worker_id is required.' });
    }
    if (!service_id || isNaN(parseInt(service_id, 10))) {
      return res.status(400).json({ success: false, error: 'service_id is required.' });
    }
    const validSlotTypes = ['immediate', 'scheduled'];
    if (!slot_type || !validSlotTypes.includes(slot_type)) {
      return res.status(400).json({ success: false, error: `slot_type must be one of: ${validSlotTypes.join(', ')}.` });
    }
    if (slot_type === 'scheduled' && !booking_time) {
      return res.status(400).json({ success: false, error: 'booking_time is required for scheduled bookings.' });
    }

    const workerId  = parseInt(worker_id, 10);
    const serviceId = parseInt(service_id, 10);

    // Validate worker exists and is verified
    const worker = db.prepare(`
      SELECT u.id, u.is_verified, wp.availability, wp.aadhaar_status, wp.police_status, wp.certificate_status
      FROM users u
      JOIN worker_profiles wp ON wp.user_id = u.id
      WHERE u.id = ? AND u.role = 'worker'
    `).get(workerId);

    if (!worker) {
      return res.status(404).json({ success: false, error: 'Worker not found.' });
    }
    if (!worker.is_verified) {
      return res.status(400).json({ success: false, error: 'Worker is not yet verified.' });
    }
    if (!worker.availability) {
      return res.status(400).json({ success: false, error: 'Worker is not currently available.' });
    }

    // Validate service exists
    const service = db.prepare('SELECT * FROM services WHERE id = ? AND is_active = 1').get(serviceId);
    if (!service) {
      return res.status(404).json({ success: false, error: 'Service not found or inactive.' });
    }

    // Check for overlapping scheduled booking (if scheduled)
    if (slot_type === 'scheduled' && booking_time) {
      const bookingTs    = new Date(booking_time).getTime();
      const durationMs   = service.duration_mins * 60 * 1000;
      const bookingEnd   = new Date(bookingTs + durationMs).toISOString();
      const bookingStart = new Date(bookingTs).toISOString();

      const overlap = db.prepare(`
        SELECT id FROM bookings
        WHERE worker_id = ?
          AND slot_type = 'scheduled'
          AND status IN ('pending', 'accepted')
          AND booking_time IS NOT NULL
          AND datetime(booking_time) < datetime(?)
          AND datetime(booking_time, '+' || (
            SELECT duration_mins FROM services WHERE id = service_id
          ) || ' minutes') > datetime(?)
      `).get(workerId, bookingEnd, bookingStart);

      if (overlap) {
        return res.status(409).json({ success: false, error: 'Worker already has a booking in this time slot.' });
      }
    }

    // Compute fee split
    const { workerPayout, welfarePayout, platformPayout } = computeSplit(
      service.base_price,
      service.worker_cut,
      service.welfare_cut
    );

    // Insert booking and update last_assigned_at
    const txn = db.transaction(() => {
      const result = db.prepare(`
        INSERT INTO bookings
          (customer_id, worker_id, service_id, status, slot_type, booking_time,
           total_amount, worker_payout, welfare_payout, platform_payout)
        VALUES (?, ?, ?, 'pending', ?, ?, ?, ?, ?, ?)
      `).run(
        req.user.id,
        workerId,
        serviceId,
        slot_type,
        booking_time ? new Date(booking_time).toISOString() : null,
        service.base_price,
        workerPayout,
        welfarePayout,
        platformPayout
      );

      db.prepare(`
        UPDATE worker_profiles SET last_assigned_at = CURRENT_TIMESTAMP WHERE user_id = ?
      `).run(workerId);

      return result.lastInsertRowid;
    });

    const bookingId = txn();
    const booking   = db.prepare('SELECT * FROM bookings WHERE id = ?').get(bookingId);

    return res.status(201).json({ success: true, data: booking });
  } catch (err) {
    console.error('[bookings/create]', err);
    return res.status(500).json({ success: false, error: 'Could not create booking.' });
  }
});

// ── GET /api/bookings ─────────────────────────────────────────────────────────

router.get('/', requireAuth, (req, res) => {
  try {
    const db   = req.app.locals.db;
    const user = req.user;

    let query;
    let params;

    if (user.role === 'customer') {
      query = `
        SELECT b.*,
               s.title AS service_title, s.base_price, s.duration_mins,
               c.name AS category_name,
               wu.id AS worker_user_id, wu.name AS worker_name, wu.mobile AS worker_mobile,
               wp.trade_category, wp.rating_avg
        FROM bookings b
        JOIN services s ON s.id = b.service_id
        JOIN categories c ON c.id = s.category_id
        JOIN users wu ON wu.id = b.worker_id
        JOIN worker_profiles wp ON wp.user_id = b.worker_id
        WHERE b.customer_id = ?
        ORDER BY b.created_at DESC
      `;
      params = [user.id];
    } else if (user.role === 'worker') {
      query = `
        SELECT b.*,
               s.title AS service_title, s.base_price, s.duration_mins,
               c.name AS category_name,
               cu.id AS customer_user_id, cu.name AS customer_name, cu.mobile AS customer_mobile
        FROM bookings b
        JOIN services s ON s.id = b.service_id
        JOIN categories c ON c.id = s.category_id
        JOIN users cu ON cu.id = b.customer_id
        WHERE b.worker_id = ?
        ORDER BY b.created_at DESC
      `;
      params = [user.id];
    } else if (user.role === 'cooperative_admin') {
      query = `
        SELECT b.*,
               s.title AS service_title, s.base_price, s.duration_mins,
               c.name AS category_name,
               wu.name AS worker_name, wu.mobile AS worker_mobile,
               cu.name AS customer_name, cu.mobile AS customer_mobile
        FROM bookings b
        JOIN services s ON s.id = b.service_id
        JOIN categories c ON c.id = s.category_id
        JOIN users wu ON wu.id = b.worker_id
        JOIN users cu ON cu.id = b.customer_id
        ORDER BY b.created_at DESC
      `;
      params = [];
    } else {
      return res.status(403).json({ success: false, error: 'Access denied.' });
    }

    const bookings = db.prepare(query).all(...params);
    return res.json({ success: true, data: bookings });
  } catch (err) {
    console.error('[bookings/list]', err);
    return res.status(500).json({ success: false, error: 'Could not fetch bookings.' });
  }
});

// ── PATCH /api/bookings/:id/status ────────────────────────────────────────────

router.patch('/:id/status', requireAuth, (req, res) => {
  try {
    const db        = req.app.locals.db;
    const bookingId = parseInt(req.params.id, 10);
    const { status } = req.body;

    if (isNaN(bookingId)) {
      return res.status(400).json({ success: false, error: 'Invalid booking id.' });
    }

    const validStatuses = ['accepted', 'completed', 'cancelled'];
    if (!status || !validStatuses.includes(status)) {
      return res.status(400).json({ success: false, error: `status must be one of: ${validStatuses.join(', ')}.` });
    }

    const booking = db.prepare('SELECT * FROM bookings WHERE id = ?').get(bookingId);
    if (!booking) {
      return res.status(404).json({ success: false, error: 'Booking not found.' });
    }

    const user = req.user;

    // Role-based transition rules:
    // worker can: pending → accepted, accepted → completed
    // customer can: pending → cancelled
    const allowedTransitions = {
      worker:   { pending: ['accepted'], accepted: ['completed'] },
      customer: { pending: ['cancelled'] },
    };

    if (user.role === 'cooperative_admin') {
      // Admins can cancel anything that isn't already terminal
      if (!['completed', 'cancelled'].includes(booking.status) && status === 'cancelled') {
        // OK
      } else if (user.role === 'cooperative_admin' && !['completed', 'cancelled'].includes(booking.status)) {
        // Allow
      } else {
        return res.status(400).json({ success: false, error: `Cannot transition booking from '${booking.status}'.` });
      }
    } else {
      // Check ownership
      if (user.role === 'worker' && booking.worker_id !== user.id) {
        return res.status(403).json({ success: false, error: 'Not your booking.' });
      }
      if (user.role === 'customer' && booking.customer_id !== user.id) {
        return res.status(403).json({ success: false, error: 'Not your booking.' });
      }

      const allowed = (allowedTransitions[user.role] || {})[booking.status] || [];
      if (!allowed.includes(status)) {
        return res.status(400).json({
          success: false,
          error: `As ${user.role}, you cannot move booking from '${booking.status}' to '${status}'.`,
        });
      }
    }

    const txn = db.transaction(() => {
      db.prepare('UPDATE bookings SET status = ? WHERE id = ?').run(status, bookingId);

      if (status === 'completed') {
        db.prepare(`
          UPDATE worker_profiles SET jobs_completed = jobs_completed + 1 WHERE user_id = ?
        `).run(booking.worker_id);
      }
    });
    txn();

    const updated = db.prepare('SELECT * FROM bookings WHERE id = ?').get(bookingId);
    return res.json({ success: true, data: updated });
  } catch (err) {
    console.error('[bookings/status]', err);
    return res.status(500).json({ success: false, error: 'Could not update booking status.' });
  }
});

// ── POST /api/bookings/:id/rate ───────────────────────────────────────────────

router.post('/:id/rate', requireAuth, requireRole('customer'), (req, res) => {
  try {
    const db        = req.app.locals.db;
    const bookingId = parseInt(req.params.id, 10);
    const { rating, rating_note } = req.body;

    if (isNaN(bookingId)) {
      return res.status(400).json({ success: false, error: 'Invalid booking id.' });
    }

    const ratingVal = parseInt(rating, 10);
    if (isNaN(ratingVal) || ratingVal < 1 || ratingVal > 5) {
      return res.status(400).json({ success: false, error: 'rating must be an integer between 1 and 5.' });
    }

    const booking = db.prepare('SELECT * FROM bookings WHERE id = ?').get(bookingId);
    if (!booking) {
      return res.status(404).json({ success: false, error: 'Booking not found.' });
    }
    if (booking.customer_id !== req.user.id) {
      return res.status(403).json({ success: false, error: 'Not your booking.' });
    }
    if (booking.status !== 'completed') {
      return res.status(400).json({ success: false, error: 'Can only rate completed bookings.' });
    }
    if (booking.rating !== null) {
      return res.status(400).json({ success: false, error: 'Booking has already been rated.' });
    }

    const txn = db.transaction(() => {
      // Update booking rating
      db.prepare('UPDATE bookings SET rating = ?, rating_note = ? WHERE id = ?')
        .run(ratingVal, rating_note || null, bookingId);

      // Recompute running average for the worker
      const stats = db.prepare(`
        SELECT AVG(rating) AS avg_rating, COUNT(*) AS rated_count
        FROM bookings
        WHERE worker_id = ? AND rating IS NOT NULL
      `).get(booking.worker_id);

      db.prepare('UPDATE worker_profiles SET rating_avg = ? WHERE user_id = ?')
        .run(Math.round((stats.avg_rating || 0) * 100) / 100, booking.worker_id);
    });
    txn();

    const updated = db.prepare('SELECT * FROM bookings WHERE id = ?').get(bookingId);
    return res.json({ success: true, data: updated });
  } catch (err) {
    console.error('[bookings/rate]', err);
    return res.status(500).json({ success: false, error: 'Could not submit rating.' });
  }
});

module.exports = router;
