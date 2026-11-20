'use strict';

const Database = require('better-sqlite3');
const bcrypt = require('bcryptjs');
const path = require('path');
const config = require('./config');

const db = new Database(config.DB_PATH);

const coop = db.prepare('SELECT id FROM cooperatives LIMIT 1').get();
const cooperativeId = coop ? coop.id : 1;

const extraWorkers = [
  // Cleaning
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
  // Electrical
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
  // Plumbing
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
  // Carpentry
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

const insertUser = db.prepare(`
  INSERT OR IGNORE INTO users (name, email, mobile, password_hash, role, cooperative_id, is_verified)
  VALUES (?, ?, ?, ?, 'worker', ?, 1)
`);

const insertProfile = db.prepare(`
  INSERT OR IGNORE INTO worker_profiles
    (user_id, trade_category, experience_years, aadhaar_status, police_status, certificate_status,
     welfare_active, rating_avg, jobs_completed, latitude, longitude, availability, cooperative_reg_no)
  VALUES (?, ?, ?, 'approved', 'approved', 'approved', 1, ?, ?, ?, ?, 1, ?)
`);

const insertSkill = db.prepare(`
  INSERT OR IGNORE INTO worker_skills (worker_id, service_id)
  VALUES (?, ?)
`);

extraWorkers.forEach((w) => {
  const hash = bcrypt.hashSync(w.password, 10);
  insertUser.run(w.name, w.email, w.mobile, hash, cooperativeId);
  const user = db.prepare('SELECT id FROM users WHERE email = ?').get(w.email);
  if (user) {
    const existingProf = db.prepare('SELECT id FROM worker_profiles WHERE user_id = ?').get(user.id);
    if (!existingProf) {
      insertProfile.run(
        user.id,
        w.trade,
        w.experienceYears,
        w.ratingAvg,
        w.jobsCompleted,
        w.lat,
        w.lng,
        w.regNo
      );
    } else {
      db.prepare(`
        UPDATE worker_profiles
        SET trade_category = ?, experience_years = ?, rating_avg = ?, jobs_completed = ?, latitude = ?, longitude = ?, availability = 1, cooperative_reg_no = ?
        WHERE user_id = ?
      `).run(w.trade, w.experienceYears, w.ratingAvg, w.jobsCompleted, w.lat, w.lng, w.regNo, user.id);
    }

    // Link skills
    const services = db.prepare(`
      SELECT s.id FROM services s
      JOIN categories c ON c.id = s.category_id
      WHERE LOWER(c.name) = LOWER(?)
    `).all(w.trade);
    services.forEach(s => insertSkill.run(user.id, s.id));
  }
});

console.log('Seeded extra dummy workers across categories!');

const all = db.prepare(`
  SELECT u.name, wp.trade_category, wp.rating_avg, wp.jobs_completed, wp.availability, wp.latitude, wp.longitude
  FROM users u
  JOIN worker_profiles wp ON wp.user_id = u.id
  WHERE u.role = 'worker'
`).all();

console.table(all);

