'use strict';
const Database = require('better-sqlite3');
const config = require('./config');
const db = new Database(config.DB_PATH);

db.prepare(`UPDATE worker_profiles SET latitude = 23.2599, longitude = 77.4126, availability = 1 WHERE latitude IS NULL OR longitude IS NULL`).run();
db.prepare(`UPDATE worker_profiles SET trade_category = 'Cleaning' WHERE trade_category IS NULL`).run();
db.prepare(`UPDATE users SET is_verified = 1 WHERE role = 'worker'`).run();

const workers = db.prepare(`
  SELECT u.name, u.role, u.is_verified, wp.trade_category, wp.availability, wp.latitude, wp.longitude
  FROM users u
  JOIN worker_profiles wp ON wp.user_id = u.id
`).all();

console.log('Fixed workers status in DB:');
console.table(workers);

