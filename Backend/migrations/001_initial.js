'use strict';

/**
 * Migration 001 – Initial schema
 * Creates all tables and enables WAL journal mode.
 */
function runMigrations(db) {
  db.exec(`
    CREATE TABLE IF NOT EXISTS cooperatives (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      name       TEXT NOT NULL,
      region     TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS users (
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      name            TEXT NOT NULL,
      email           TEXT UNIQUE NOT NULL,
      mobile          TEXT UNIQUE NOT NULL,
      password_hash   TEXT NOT NULL,
      role            TEXT NOT NULL CHECK(role IN ('customer','worker','cooperative_admin')),
      cooperative_id  INTEGER REFERENCES cooperatives(id),
      is_verified     INTEGER DEFAULT 0,
      created_at      DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS worker_profiles (
      id                       INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id                  INTEGER UNIQUE NOT NULL REFERENCES users(id),
      trade_category           TEXT,
      experience_years         INTEGER DEFAULT 0,
      aadhaar_doc              TEXT,
      aadhaar_status           TEXT DEFAULT 'pending' CHECK(aadhaar_status IN ('pending','approved','rejected')),
      aadhaar_rejection_reason TEXT,
      police_doc               TEXT,
      police_status            TEXT DEFAULT 'pending' CHECK(police_status IN ('pending','approved','rejected')),
      police_rejection_reason  TEXT,
      certificate_doc          TEXT,
      certificate_status       TEXT DEFAULT 'pending' CHECK(certificate_status IN ('pending','approved','rejected')),
      certificate_rejection_reason TEXT,
      welfare_active           INTEGER DEFAULT 0,
      rating_avg               REAL DEFAULT 0.0,
      jobs_completed           INTEGER DEFAULT 0,
      latitude                 REAL,
      longitude                REAL,
      availability             INTEGER DEFAULT 0,
      last_assigned_at         DATETIME,
      cooperative_reg_no       TEXT UNIQUE,
      created_at               DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS categories (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      name        TEXT NOT NULL,
      icon        TEXT,
      description TEXT,
      created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS services (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      category_id   INTEGER NOT NULL REFERENCES categories(id),
      title         TEXT NOT NULL,
      description   TEXT,
      base_price    REAL NOT NULL,
      duration_mins INTEGER DEFAULT 60,
      worker_cut    REAL DEFAULT 85,
      welfare_cut   REAL DEFAULT 10,
      platform_cut  REAL DEFAULT 5,
      is_active     INTEGER DEFAULT 1,
      created_at    DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS bookings (
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      customer_id     INTEGER NOT NULL REFERENCES users(id),
      worker_id       INTEGER NOT NULL REFERENCES users(id),
      service_id      INTEGER NOT NULL REFERENCES services(id),
      status          TEXT NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','accepted','completed','cancelled')),
      slot_type       TEXT NOT NULL DEFAULT 'immediate' CHECK(slot_type IN ('immediate','scheduled')),
      booking_time    DATETIME,
      total_amount    REAL NOT NULL,
      worker_payout   REAL NOT NULL,
      welfare_payout  REAL NOT NULL,
      platform_payout REAL NOT NULL,
      rating          INTEGER CHECK(rating BETWEEN 1 AND 5),
      rating_note     TEXT,
      created_at      DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS grievances (
      id               INTEGER PRIMARY KEY AUTOINCREMENT,
      booking_id       INTEGER NOT NULL REFERENCES bookings(id),
      filed_by_id      INTEGER NOT NULL REFERENCES users(id),
      description      TEXT NOT NULL,
      status           TEXT NOT NULL DEFAULT 'open' CHECK(status IN ('open','resolved')),
      resolution_note  TEXT,
      resolved_at      DATETIME,
      resolved_by_id   INTEGER REFERENCES users(id),
      created_at       DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS audit_log (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      admin_id    INTEGER REFERENCES users(id),
      action      TEXT NOT NULL,
      target_type TEXT,
      target_id   INTEGER,
      old_value   TEXT,
      new_value   TEXT,
      created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `);

  db.pragma('journal_mode = WAL');

  console.log('[migrations] Schema up to date.');
}

module.exports = { runMigrations };
