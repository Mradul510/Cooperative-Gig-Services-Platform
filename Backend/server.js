'use strict';

require('dotenv').config();

const express    = require('express');
const cors       = require('cors');
const path       = require('path');
const fs         = require('fs');
const Database   = require('better-sqlite3');
const rateLimit  = require('express-rate-limit');

const config          = require('./config');
const { runMigrations } = require('./migrations/001_initial');
const { runSeed }       = require('./migrations/002_seed');

// ── Route modules ─────────────────────────────────────────────────────────────
const authRoutes       = require('./routes/auth');
const categoryRoutes   = require('./routes/categories');
const workerRoutes     = require('./routes/workers');
const bookingRoutes    = require('./routes/bookings');
const grievanceRoutes  = require('./routes/grievances');
const adminRoutes      = require('./routes/admin');

// ── Storage directory ─────────────────────────────────────────────────────────
const docsDir = path.join(config.STORAGE_PATH, 'documents');
if (!fs.existsSync(docsDir)) {
  fs.mkdirSync(docsDir, { recursive: true });
}

// ── Database ──────────────────────────────────────────────────────────────────
const db = new Database(config.DB_PATH, { verbose: null });
runMigrations(db);
runSeed(db);

// ── Express app ───────────────────────────────────────────────────────────────
const app = express();

// CORS
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// JSON body parsing
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

// Attach DB to app locals so routes can access it
app.locals.db = db;

// ── Rate limiting ─────────────────────────────────────────────────────────────
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, error: 'Too many requests from this IP, please try again later.' },
});
app.use('/api/auth', authLimiter);

// ── API routes ────────────────────────────────────────────────────────────────
app.use('/api/auth',        authRoutes);
app.use('/api/categories',  categoryRoutes);
// /api/services is handled inside categoryRoutes as GET /services
app.get('/api/services', (req, res, next) => {
  req.url = '/services';
  categoryRoutes(req, res, next);
});
app.use('/api/workers',     workerRoutes);
app.use('/api/bookings',    bookingRoutes);
app.use('/api/grievances',  grievanceRoutes);
app.use('/api/admin',       adminRoutes);

// ── Admin dashboard (static HTML) ─────────────────────────────────────────────
const adminDir = path.join(__dirname, 'admin');
if (fs.existsSync(adminDir)) {
  app.use('/admin', express.static(adminDir));
}

// ── Root health check ─────────────────────────────────────────────────────────
app.get('/', (_req, res) => {
  res.json({
    success: true,
    data: {
      name:    'CoopGig API',
      version: '1.0.0',
      status:  'running',
      time:    new Date().toISOString(),
    },
  });
});

// ── 404 catch-all ─────────────────────────────────────────────────────────────
app.use((_req, res) => {
  res.status(404).json({ success: false, error: 'Route not found.' });
});

// ── Global error handler ──────────────────────────────────────────────────────
// eslint-disable-next-line no-unused-vars
app.use((err, _req, res, _next) => {
  console.error('[unhandled error]', err);
  res.status(err.status || 500).json({
    success: false,
    error: err.message || 'Internal server error.',
  });
});

// ── Start server ──────────────────────────────────────────────────────────────
app.listen(config.PORT, () => {
  console.log(`CoopGig API running on port ${config.PORT}`);
  console.log(`Admin dashboard: http://localhost:${config.PORT}/admin`);
});

module.exports = app;
