'use strict';

const express = require('express');
const { computeSplit } = require('../services/fee');

const router = express.Router();

// ── GET /api/categories ───────────────────────────────────────────────────────

router.get('/', (req, res) => {
  try {
    const db   = req.app.locals.db;
    const cats = db.prepare('SELECT * FROM categories ORDER BY name ASC').all();
    return res.json({ success: true, data: cats });
  } catch (err) {
    console.error('[categories]', err);
    return res.status(500).json({ success: false, error: 'Could not fetch categories.' });
  }
});

// ── GET /api/services ─────────────────────────────────────────────────────────
// Query params: ?category_id=  or  ?id=

router.get('/services', (req, res) => {
  try {
    const db = req.app.locals.db;
    const { category_id, id } = req.query;

    let query = `
      SELECT s.*, c.name AS category_name, c.icon AS category_icon
      FROM services s
      JOIN categories c ON c.id = s.category_id
      WHERE s.is_active = 1
    `;
    const params = [];

    if (id !== undefined) {
      query += ' AND s.id = ?';
      params.push(parseInt(id, 10));
    } else if (category_id !== undefined) {
      query += ' AND s.category_id = ?';
      params.push(parseInt(category_id, 10));
    }

    query += ' ORDER BY s.title ASC';

    const services = db.prepare(query).all(...params);

    // Append a computed split example at base_price for each service
    const enriched = services.map((svc) => {
      const split = computeSplit(svc.base_price, svc.worker_cut, svc.welfare_cut);
      return { ...svc, split_example: split };
    });

    return res.json({ success: true, data: enriched });
  } catch (err) {
    console.error('[services]', err);
    return res.status(500).json({ success: false, error: 'Could not fetch services.' });
  }
});

module.exports = router;
