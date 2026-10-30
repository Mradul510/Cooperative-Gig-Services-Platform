'use strict';

const express = require('express');
const fs      = require('fs');
const path    = require('path');
const config  = require('../config');
const { requireAuth, requireRole } = require('../middleware/auth');
const { computeSplit } = require('../services/fee');

const router = express.Router();

// All admin routes require authentication and cooperative_admin role
router.use(requireAuth, requireRole('cooperative_admin'));

// ── GET /api/admin/verifications ──────────────────────────────────────────────

router.get('/verifications', (req, res) => {
  try {
    const db = req.app.locals.db;
    const workers = db.prepare(`
      SELECT
        wp.*,
        u.id   AS user_id,
        u.name AS user_name,
        u.email,
        u.mobile,
        u.is_verified,
        u.created_at AS user_created_at
      FROM worker_profiles wp
      JOIN users u ON u.id = wp.user_id
      WHERE wp.aadhaar_status = 'pending'
         OR wp.police_status  = 'pending'
         OR wp.certificate_status = 'pending'
      ORDER BY wp.created_at ASC
    `).all();
    return res.json({ success: true, data: workers });
  } catch (err) {
    console.error('[admin/verifications]', err);
    return res.status(500).json({ success: false, error: 'Could not fetch verifications.' });
  }
});

// ── PATCH /api/admin/verifications/:workerId ──────────────────────────────────

router.patch('/verifications/:workerId', (req, res) => {
  try {
    const db       = req.app.locals.db;
    const workerId = parseInt(req.params.workerId, 10);
    const { doc_type, action, reason } = req.body;

    if (isNaN(workerId)) {
      return res.status(400).json({ success: false, error: 'Invalid workerId.' });
    }

    const validDocTypes = ['aadhaar', 'police', 'certificate'];
    if (!doc_type || !validDocTypes.includes(doc_type)) {
      return res.status(400).json({ success: false, error: `doc_type must be one of: ${validDocTypes.join(', ')}.` });
    }
    const validActions = ['approve', 'reject'];
    if (!action || !validActions.includes(action)) {
      return res.status(400).json({ success: false, error: `action must be one of: ${validActions.join(', ')}.` });
    }
    if (action === 'reject' && (!reason || reason.trim().length < 3)) {
      return res.status(400).json({ success: false, error: 'A rejection reason is required.' });
    }

    const profile = db.prepare('SELECT * FROM worker_profiles WHERE user_id = ?').get(workerId);
    if (!profile) {
      return res.status(404).json({ success: false, error: 'Worker profile not found.' });
    }

    const newStatus = action === 'approve' ? 'approved' : 'rejected';
    const statusCol = `${doc_type}_status`;
    const reasonCol = `${doc_type}_rejection_reason`;

    const oldStatus = profile[statusCol];

    const txn = db.transaction(() => {
      db.prepare(
        `UPDATE worker_profiles SET ${statusCol} = ?, ${reasonCol} = ? WHERE user_id = ?`
      ).run(newStatus, action === 'reject' ? reason.trim() : null, workerId);

      // Re-fetch to check if all 3 docs are now approved
      const updated = db.prepare('SELECT * FROM worker_profiles WHERE user_id = ?').get(workerId);
      const allApproved =
        updated.aadhaar_status      === 'approved' &&
        updated.police_status       === 'approved' &&
        updated.certificate_status  === 'approved';

      if (allApproved) {
        db.prepare('UPDATE users SET is_verified = 1 WHERE id = ?').run(workerId);
        db.prepare('UPDATE worker_profiles SET welfare_active = 1 WHERE user_id = ?').run(workerId);
      }

      // Audit log
      db.prepare(`
        INSERT INTO audit_log (admin_id, action, target_type, target_id, old_value, new_value)
        VALUES (?, ?, 'worker_profile', ?, ?, ?)
      `).run(
        req.user.id,
        `${action}_${doc_type}_doc`,
        workerId,
        oldStatus,
        newStatus
      );
    });
    txn();

    const finalProfile = db.prepare('SELECT * FROM worker_profiles WHERE user_id = ?').get(workerId);
    const user         = db.prepare('SELECT id, name, email, is_verified FROM users WHERE id = ?').get(workerId);
    return res.json({ success: true, data: { ...finalProfile, user } });
  } catch (err) {
    console.error('[admin/verifications/:id]', err);
    return res.status(500).json({ success: false, error: 'Could not update verification.' });
  }
});

// ── GET /api/admin/users ──────────────────────────────────────────────────────

router.get('/users', (req, res) => {
  try {
    const db = req.app.locals.db;
    const { role, q, page = 1, limit = 20 } = req.query;

    const pageNum  = Math.max(1, parseInt(page, 10) || 1);
    const pageSize = Math.min(100, Math.max(1, parseInt(limit, 10) || 20));
    const offset   = (pageNum - 1) * pageSize;

    let where  = '1=1';
    const params = [];

    if (role) {
      const validRoles = ['customer', 'worker', 'cooperative_admin'];
      if (!validRoles.includes(role)) {
        return res.status(400).json({ success: false, error: `role must be one of: ${validRoles.join(', ')}.` });
      }
      where += ' AND u.role = ?';
      params.push(role);
    }

    if (q) {
      const like = `%${q}%`;
      where += ' AND (u.name LIKE ? OR u.email LIKE ? OR u.mobile LIKE ?)';
      params.push(like, like, like);
    }

    const total = db.prepare(`SELECT COUNT(*) AS cnt FROM users u WHERE ${where}`).get(...params).cnt;

    const users = db.prepare(`
      SELECT u.id, u.name, u.email, u.mobile, u.role, u.cooperative_id, u.is_verified, u.created_at
      FROM users u
      WHERE ${where}
      ORDER BY u.created_at DESC
      LIMIT ? OFFSET ?
    `).all(...params, pageSize, offset);

    return res.json({
      success: true,
      data: { users, total, page: pageNum, limit: pageSize, pages: Math.ceil(total / pageSize) },
    });
  } catch (err) {
    console.error('[admin/users]', err);
    return res.status(500).json({ success: false, error: 'Could not fetch users.' });
  }
});

// ── POST /api/admin/users/:id/cooperative ────────────────────────────────────

router.post('/users/:id/cooperative', (req, res) => {
  try {
    const db     = req.app.locals.db;
    const userId = parseInt(req.params.id, 10);
    const { cooperative_id } = req.body;

    if (isNaN(userId)) {
      return res.status(400).json({ success: false, error: 'Invalid user id.' });
    }
    if (cooperative_id === undefined || cooperative_id === null) {
      return res.status(400).json({ success: false, error: 'cooperative_id is required.' });
    }

    const user = db.prepare('SELECT id FROM users WHERE id = ?').get(userId);
    if (!user) {
      return res.status(404).json({ success: false, error: 'User not found.' });
    }

    const coop = db.prepare('SELECT id FROM cooperatives WHERE id = ?').get(cooperative_id);
    if (!coop) {
      return res.status(404).json({ success: false, error: 'Cooperative not found.' });
    }

    db.prepare('UPDATE users SET cooperative_id = ? WHERE id = ?').run(cooperative_id, userId);

    const updated = db.prepare('SELECT id, name, email, role, cooperative_id, is_verified FROM users WHERE id = ?').get(userId);
    return res.json({ success: true, data: updated });
  } catch (err) {
    console.error('[admin/users/cooperative]', err);
    return res.status(500).json({ success: false, error: 'Could not update cooperative.' });
  }
});

// ── GET /api/admin/services ───────────────────────────────────────────────────

router.get('/services', (req, res) => {
  try {
    const db = req.app.locals.db;
    const services = db.prepare(`
      SELECT s.*, c.name AS category_name, c.icon AS category_icon
      FROM services s
      JOIN categories c ON c.id = s.category_id
      ORDER BY c.name ASC, s.title ASC
    `).all();
    return res.json({ success: true, data: services });
  } catch (err) {
    console.error('[admin/services GET]', err);
    return res.status(500).json({ success: false, error: 'Could not fetch services.' });
  }
});

// ── POST /api/admin/services ──────────────────────────────────────────────────

router.post('/services', (req, res) => {
  try {
    const db = req.app.locals.db;
    const { category_id, title, description, base_price, duration_mins, worker_cut, welfare_cut, platform_cut } = req.body;

    if (!category_id || isNaN(parseInt(category_id, 10))) {
      return res.status(400).json({ success: false, error: 'category_id is required.' });
    }
    if (!title || typeof title !== 'string' || title.trim().length < 2) {
      return res.status(400).json({ success: false, error: 'title is required (min 2 chars).' });
    }
    const price = parseFloat(base_price);
    if (isNaN(price) || price <= 0) {
      return res.status(400).json({ success: false, error: 'base_price must be a positive number.' });
    }

    const wc = parseFloat(worker_cut)   || config.WORKER_CUT;
    const fc = parseFloat(welfare_cut)  || config.WELFARE_CUT;
    const pc = parseFloat(platform_cut) || config.PLATFORM_CUT;

    if (Math.abs(wc + fc + pc - 100) > 0.01) {
      return res.status(400).json({ success: false, error: `worker_cut + welfare_cut + platform_cut must equal 100 (got ${wc + fc + pc}).` });
    }

    const cat = db.prepare('SELECT id FROM categories WHERE id = ?').get(parseInt(category_id, 10));
    if (!cat) {
      return res.status(404).json({ success: false, error: 'Category not found.' });
    }

    const result = db.prepare(`
      INSERT INTO services (category_id, title, description, base_price, duration_mins, worker_cut, welfare_cut, platform_cut)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
      parseInt(category_id, 10),
      title.trim(),
      description || null,
      price,
      parseInt(duration_mins, 10) || 60,
      wc, fc, pc
    );

    const created = db.prepare('SELECT * FROM services WHERE id = ?').get(result.lastInsertRowid);
    return res.status(201).json({ success: true, data: created });
  } catch (err) {
    console.error('[admin/services POST]', err);
    return res.status(500).json({ success: false, error: 'Could not create service.' });
  }
});

// ── PUT /api/admin/services/:id ───────────────────────────────────────────────

router.put('/services/:id', (req, res) => {
  try {
    const db        = req.app.locals.db;
    const serviceId = parseInt(req.params.id, 10);

    if (isNaN(serviceId)) {
      return res.status(400).json({ success: false, error: 'Invalid service id.' });
    }

    const service = db.prepare('SELECT * FROM services WHERE id = ?').get(serviceId);
    if (!service) {
      return res.status(404).json({ success: false, error: 'Service not found.' });
    }

    const {
      category_id, title, description, base_price, duration_mins,
      worker_cut, welfare_cut, platform_cut, is_active,
    } = req.body;

    const newCatId   = category_id   !== undefined ? parseInt(category_id, 10)     : service.category_id;
    const newTitle   = title         !== undefined ? title.trim()                   : service.title;
    const newDesc    = description   !== undefined ? description                    : service.description;
    const newPrice   = base_price    !== undefined ? parseFloat(base_price)         : service.base_price;
    const newDur     = duration_mins !== undefined ? parseInt(duration_mins, 10)    : service.duration_mins;
    const newWc      = worker_cut    !== undefined ? parseFloat(worker_cut)         : service.worker_cut;
    const newFc      = welfare_cut   !== undefined ? parseFloat(welfare_cut)        : service.welfare_cut;
    const newPc      = platform_cut  !== undefined ? parseFloat(platform_cut)       : service.platform_cut;
    const newActive  = is_active     !== undefined ? (is_active ? 1 : 0)            : service.is_active;

    if (Math.abs(newWc + newFc + newPc - 100) > 0.01) {
      return res.status(400).json({ success: false, error: `worker_cut + welfare_cut + platform_cut must equal 100 (got ${newWc + newFc + newPc}).` });
    }
    if (isNaN(newPrice) || newPrice <= 0) {
      return res.status(400).json({ success: false, error: 'base_price must be a positive number.' });
    }

    db.prepare(`
      UPDATE services
      SET category_id=?, title=?, description=?, base_price=?, duration_mins=?,
          worker_cut=?, welfare_cut=?, platform_cut=?, is_active=?
      WHERE id=?
    `).run(newCatId, newTitle, newDesc, newPrice, newDur, newWc, newFc, newPc, newActive, serviceId);

    const updated = db.prepare('SELECT * FROM services WHERE id = ?').get(serviceId);
    return res.json({ success: true, data: updated });
  } catch (err) {
    console.error('[admin/services PUT]', err);
    return res.status(500).json({ success: false, error: 'Could not update service.' });
  }
});

// ── GET /api/admin/grievances ─────────────────────────────────────────────────

router.get('/grievances', (req, res) => {
  try {
    const db = req.app.locals.db;
    const { status } = req.query;

    let where  = '1=1';
    const params = [];
    if (status) {
      const validStatuses = ['open', 'resolved'];
      if (!validStatuses.includes(status)) {
        return res.status(400).json({ success: false, error: `status must be one of: ${validStatuses.join(', ')}.` });
      }
      where += ' AND g.status = ?';
      params.push(status);
    }

    const grievances = db.prepare(`
      SELECT
        g.*,
        b.status         AS booking_status,
        b.total_amount,
        b.created_at     AS booking_created_at,
        filer.name       AS filed_by_name,
        filer.email      AS filed_by_email,
        cu.name          AS customer_name,
        wu.name          AS worker_name,
        resolver.name    AS resolved_by_name
      FROM grievances g
      JOIN bookings b    ON b.id = g.booking_id
      JOIN users filer   ON filer.id = g.filed_by_id
      JOIN users cu      ON cu.id = b.customer_id
      JOIN users wu      ON wu.id = b.worker_id
      LEFT JOIN users resolver ON resolver.id = g.resolved_by_id
      WHERE ${where}
      ORDER BY g.created_at DESC
    `).all(...params);

    return res.json({ success: true, data: grievances });
  } catch (err) {
    console.error('[admin/grievances GET]', err);
    return res.status(500).json({ success: false, error: 'Could not fetch grievances.' });
  }
});

// ── PATCH /api/admin/grievances/:id ──────────────────────────────────────────

router.patch('/grievances/:id', (req, res) => {
  try {
    const db          = req.app.locals.db;
    const grievanceId = parseInt(req.params.id, 10);
    const { resolution_note } = req.body;

    if (isNaN(grievanceId)) {
      return res.status(400).json({ success: false, error: 'Invalid grievance id.' });
    }
    if (!resolution_note || resolution_note.trim().length < 5) {
      return res.status(400).json({ success: false, error: 'resolution_note is required (min 5 chars).' });
    }

    const grievance = db.prepare('SELECT * FROM grievances WHERE id = ?').get(grievanceId);
    if (!grievance) {
      return res.status(404).json({ success: false, error: 'Grievance not found.' });
    }
    if (grievance.status === 'resolved') {
      return res.status(400).json({ success: false, error: 'Grievance is already resolved.' });
    }

    db.prepare(`
      UPDATE grievances
      SET status = 'resolved', resolution_note = ?, resolved_at = CURRENT_TIMESTAMP, resolved_by_id = ?
      WHERE id = ?
    `).run(resolution_note.trim(), req.user.id, grievanceId);

    const updated = db.prepare('SELECT * FROM grievances WHERE id = ?').get(grievanceId);
    return res.json({ success: true, data: updated });
  } catch (err) {
    console.error('[admin/grievances PATCH]', err);
    return res.status(500).json({ success: false, error: 'Could not resolve grievance.' });
  }
});

// ── GET /api/admin/health ─────────────────────────────────────────────────────

router.get('/health', (req, res) => {
  try {
    const db = req.app.locals.db;

    const start   = Date.now();
    db.prepare('SELECT 1').get();
    const latencyMs = Date.now() - start;

    const memMB = Math.round(process.memoryUsage().heapUsed / 1024 / 1024 * 100) / 100;

    let dbSizeBytes = 0;
    try {
      const dbStats = fs.statSync(config.DB_PATH);
      dbSizeBytes = dbStats.size;
    } catch (_) {
      dbSizeBytes = 0;
    }

    return res.json({
      success: true,
      data: {
        uptime:       Math.floor(process.uptime()),
        memoryMB:     memMB,
        dbSizeBytes,
        latencyMs,
        nodeVersion:  process.version,
        timestamp:    new Date().toISOString(),
      },
    });
  } catch (err) {
    console.error('[admin/health]', err);
    return res.status(500).json({ success: false, error: 'Health check failed.' });
  }
});

// ── GET /api/admin/storage ────────────────────────────────────────────────────

router.get('/storage', (req, res) => {
  try {
    const db     = req.app.locals.db;
    const docsDir = path.join(config.STORAGE_PATH, 'documents');

    if (!fs.existsSync(docsDir)) {
      return res.json({ success: true, data: { files: [], totalSizeBytes: 0, orphanCount: 0 } });
    }

    const filenames = fs.readdirSync(docsDir);

    // Get all valid user IDs
    const userIds = new Set(
      db.prepare('SELECT id FROM users').all().map((u) => String(u.id))
    );

    let totalSize = 0;
    const files = filenames.map((name) => {
      const fullPath = path.join(docsDir, name);
      let size = 0;
      try {
        size = fs.statSync(fullPath).size;
      } catch (_) {}
      totalSize += size;

      // Filename format: {userId}_{fieldname}_{timestamp}.ext
      const parts = name.split('_');
      const fileUserId = parts[0] || '';
      const isOrphan   = !userIds.has(fileUserId);

      return { name, sizeBytes: size, isOrphan, userId: fileUserId };
    });

    const orphanCount = files.filter((f) => f.isOrphan).length;

    return res.json({
      success: true,
      data: { files, totalSizeBytes: totalSize, orphanCount },
    });
  } catch (err) {
    console.error('[admin/storage]', err);
    return res.status(500).json({ success: false, error: 'Could not list storage.' });
  }
});

module.exports = router;
