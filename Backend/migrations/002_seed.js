'use strict';

const bcrypt = require('bcryptjs');

/**
 * Migration 002 – Seed data
 * Inserts default cooperative, categories, services, admin, workers and customers.
 * Only runs when the cooperatives table is empty.
 */
function runSeed(db) {
  const existing = db.prepare('SELECT COUNT(*) as cnt FROM cooperatives').get();
  if (existing.cnt > 0) {
    console.log('[seed] Data already seeded – skipping.');
    return;
  }

  // ── Cooperative ──────────────────────────────────────────────────────────────
  const coopResult = db
    .prepare('INSERT INTO cooperatives (name, region) VALUES (?, ?)')
    .run('Bhopal Central Co-op', 'Bhopal, MP');
  const cooperativeId = coopResult.lastInsertRowid;

  // ── Categories ───────────────────────────────────────────────────────────────
  const insertCat = db.prepare(
    'INSERT INTO categories (name, icon, description) VALUES (?, ?, ?)'
  );
  const cleaningResult   = insertCat.run('Cleaning',   '🧹', 'Professional home and office cleaning services');
  const electricalResult = insertCat.run('Electrical', '⚡', 'Certified electrical installation and repair services');
  const plumbingResult   = insertCat.run('Plumbing',   '🔧', 'Expert plumbing repair and installation services');
  const carpentryResult  = insertCat.run('Carpentry',  '🪚', 'Skilled carpentry and furniture services');

  const cleaningId   = cleaningResult.lastInsertRowid;
  const electricalId = electricalResult.lastInsertRowid;
  const plumbingId   = plumbingResult.lastInsertRowid;
  const carpentryId  = carpentryResult.lastInsertRowid;

  // ── Services ─────────────────────────────────────────────────────────────────
  const insertSvc = db.prepare(`
    INSERT INTO services (category_id, title, description, base_price, duration_mins, worker_cut, welfare_cut, platform_cut)
    VALUES (?, ?, ?, ?, ?, 85, 10, 5)
  `);

  // Cleaning
  insertSvc.run(cleaningId,   'Regular home cleaning',     'Standard room-by-room cleaning with mop and vacuum',          399,  60);
  insertSvc.run(cleaningId,   'Kitchen cleaning',          'Deep clean of kitchen surfaces, appliances and floors',        699,  90);
  insertSvc.run(cleaningId,   'Deep home cleaning',        'Full-home deep clean including bathrooms, kitchen and rooms',  1499, 180);
  // Electrical
  insertSvc.run(electricalId, 'Fan installation',          'Ceiling or exhaust fan fitting with wiring',                  299,  45);
  insertSvc.run(electricalId, 'Switch/socket repair',      'Replace or repair switches, sockets and MCBs',                199,  30);
  insertSvc.run(electricalId, 'Wiring inspection',         'Full home wiring safety inspection with report',              499,  90);
  // Plumbing
  insertSvc.run(plumbingId,   'Tap repair',                'Fix dripping or broken taps and faucets',                    199,  30);
  insertSvc.run(plumbingId,   'Pipe leakage fix',          'Locate and repair leaking pipes',                             399,  60);
  insertSvc.run(plumbingId,   'Water heater installation', 'Install geyser/water heater with pipe connections',           699, 120);
  // Carpentry
  insertSvc.run(carpentryId,  'Furniture repair',          'Fix broken furniture joints, hinges and drawers',             299,  60);
  insertSvc.run(carpentryId,  'Door/window fix',           'Repair sticking doors/windows, replace handles and locks',    399,  60);
  insertSvc.run(carpentryId,  'Custom shelf fitting',      'Measure and fit wall-mounted shelves',                        599,  90);

  // ── Admin user ───────────────────────────────────────────────────────────────
  const adminHash = bcrypt.hashSync('Admin@123', 10);
  db.prepare(`
    INSERT INTO users (name, email, mobile, password_hash, role, cooperative_id, is_verified)
    VALUES (?, ?, ?, ?, 'cooperative_admin', ?, 1)
  `).run('Coop Admin', 'admin@coopgig.com', '9000000001', adminHash, cooperativeId);

  // ── Workers ──────────────────────────────────────────────────────────────────
  const workerData = [
    {
      name: 'Ramesh Kumar',
      email: 'ramesh@coopgig.com',
      mobile: '9000000002',
      password: 'Worker@123',
      trade: 'Electrical',
      experienceYears: 5,
      lat: 23.2621,
      lng: 77.4152,
      regNo: 'BCK-001',
      ratingAvg: 4.7,
      jobsCompleted: 42,
    },
    {
      name: 'Suresh Patel',
      email: 'suresh@coopgig.com',
      mobile: '9000000003',
      password: 'Worker@123',
      trade: 'Plumbing',
      experienceYears: 3,
      lat: 23.2555,
      lng: 77.4089,
      regNo: 'BCK-002',
      ratingAvg: 4.5,
      jobsCompleted: 31,
    },
    {
      name: 'Meena Sharma',
      email: 'meena@coopgig.com',
      mobile: '9000000004',
      password: 'Worker@123',
      trade: 'Cleaning',
      experienceYears: 7,
      lat: 23.2640,
      lng: 77.4200,
      regNo: 'BCK-003',
      ratingAvg: 4.8,
      jobsCompleted: 56,
    },
    {
      name: 'Sunita Bai',
      email: 'sunita@coopgig.com',
      mobile: '9000000011',
      password: 'Worker@123',
      trade: 'Cleaning',
      experienceYears: 4,
      lat: 23.2580,
      lng: 77.4110,
      regNo: 'BCK-004',
      ratingAvg: 4.9,
      jobsCompleted: 72,
    },
    {
      name: 'Manoj Tiwari',
      email: 'manoj@coopgig.com',
      mobile: '9000000012',
      password: 'Worker@123',
      trade: 'Electrical',
      experienceYears: 6,
      lat: 23.2610,
      lng: 77.4140,
      regNo: 'BCK-005',
      ratingAvg: 4.9,
      jobsCompleted: 64,
    },
    {
      name: 'Rajesh Verma',
      email: 'rajesh@coopgig.com',
      mobile: '9000000013',
      password: 'Worker@123',
      trade: 'Plumbing',
      experienceYears: 8,
      lat: 23.2570,
      lng: 77.4095,
      regNo: 'BCK-006',
      ratingAvg: 4.8,
      jobsCompleted: 89,
    },
    {
      name: 'Vikram Carpenter',
      email: 'vikram@coopgig.com',
      mobile: '9000000014',
      password: 'Worker@123',
      trade: 'Carpentry',
      experienceYears: 6,
      lat: 23.2605,
      lng: 77.4135,
      regNo: 'BCK-007',
      ratingAvg: 4.8,
      jobsCompleted: 53,
    },
    {
      name: 'Harish Mistri',
      email: 'harish@coopgig.com',
      mobile: '9000000015',
      password: 'Worker@123',
      trade: 'Carpentry',
      experienceYears: 9,
      lat: 23.2635,
      lng: 77.4180,
      regNo: 'BCK-008',
      ratingAvg: 4.7,
      jobsCompleted: 47,
    },
  ];

  const insertWorkerUser = db.prepare(`
    INSERT INTO users (name, email, mobile, password_hash, role, cooperative_id, is_verified)
    VALUES (?, ?, ?, ?, 'worker', ?, 1)
  `);
  const insertWorkerProfile = db.prepare(`
    INSERT INTO worker_profiles
      (user_id, trade_category, experience_years, aadhaar_status, police_status, certificate_status,
       welfare_active, rating_avg, jobs_completed, latitude, longitude, availability, cooperative_reg_no)
    VALUES (?, ?, ?, 'approved', 'approved', 'approved', 1, ?, ?, ?, ?, 1, ?)
  `);

  workerData.forEach((w) => {
    const hash   = bcrypt.hashSync(w.password, 10);
    const result = insertWorkerUser.run(w.name, w.email, w.mobile, hash, cooperativeId);
    insertWorkerProfile.run(
      result.lastInsertRowid,
      w.trade,
      w.experienceYears,
      w.ratingAvg,
      w.jobsCompleted,
      w.lat,
      w.lng,
      w.regNo
    );
  });

  // ── Customers ────────────────────────────────────────────────────────────────
  const customerData = [
    { name: 'Priya Singh', email: 'priya@example.com', mobile: '9000000005', password: 'Customer@123' },
    { name: 'Amit Verma',  email: 'amit@example.com',  mobile: '9000000006', password: 'Customer@123' },
  ];

  const insertCustomer = db.prepare(`
    INSERT INTO users (name, email, mobile, password_hash, role, is_verified)
    VALUES (?, ?, ?, ?, 'customer', 1)
  `);

  customerData.forEach((c) => {
    const hash = bcrypt.hashSync(c.password, 10);
    insertCustomer.run(c.name, c.email, c.mobile, hash);
  });

  // ── Worker Skills (Mapping workers to their trade services) ─────────────────
  const insertWorkerSkill = db.prepare(`
    INSERT OR IGNORE INTO worker_skills (worker_id, service_id)
    VALUES (?, ?)
  `);

  const allWorkers = db.prepare("SELECT id, role FROM users WHERE role = 'worker'").all();
  allWorkers.forEach((w) => {
    const prof = db.prepare('SELECT trade_category FROM worker_profiles WHERE user_id = ?').get(w.id);
    if (prof && prof.trade_category) {
      const svcs = db.prepare(`
        SELECT s.id FROM services s
        JOIN categories c ON c.id = s.category_id
        WHERE c.name = ?
      `).all(prof.trade_category);
      svcs.forEach(s => insertWorkerSkill.run(w.id, s.id));
    }
  });

  // ── Sample Reviews & Payments for existing completed bookings ────────────────
  const insertPayment = db.prepare(`
    INSERT OR IGNORE INTO payments (booking_id, amount, payment_method, payment_status, transaction_id, paid_at)
    VALUES (?, ?, ?, 'completed', ?, datetime('now'))
  `);

  const insertReview = db.prepare(`
    INSERT OR IGNORE INTO reviews (booking_id, customer_id, worker_id, rating, comment)
    VALUES (?, ?, ?, ?, ?)
  `);

  const completedBookings = db.prepare("SELECT * FROM bookings WHERE status = 'completed'").all();
  completedBookings.forEach((b) => {
    insertPayment.run(b.id, b.total_amount, 'cash', `TXN_CASH_${b.id}`);
    if (b.rating) {
      insertReview.run(b.id, b.customer_id, b.worker_id, b.rating, b.rating_note || 'Great service from verified cooperative worker.');
    }
  });

  console.log('[seed] Seed data inserted successfully.');
}

module.exports = { runSeed };
