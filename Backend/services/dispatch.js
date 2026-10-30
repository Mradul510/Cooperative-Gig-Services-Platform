'use strict';

const EARTH_RADIUS_KM = 6371;

/**
 * Haversine formula – returns distance in kilometres between two lat/lng points.
 *
 * @param {number} lat1
 * @param {number} lon1
 * @param {number} lat2
 * @param {number} lon2
 * @returns {number} distance in km
 */
function haversineKm(lat1, lon1, lat2, lon2) {
  const toRad = (deg) => (deg * Math.PI) / 180;
  const dLat  = toRad(lat2 - lat1);
  const dLon  = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) *
      Math.cos(toRad(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return EARTH_RADIUS_KM * c;
}

/**
 * Score a worker candidate (higher = better match).
 *
 * Components:
 *  – Proximity bonus  : 1 / (distance + 0.1) × 10   → closer workers score higher
 *  – Rating bonus     : rating_avg × 2
 *  – Workload bonus   : 1 / (activeBookings + 1) × 5 → less-busy workers score higher
 *  – Recency penalty  : proportional to minutes since last assignment (capped at 60)
 *    workers who haven't been assigned recently are preferred
 *
 * @param {object} worker        - Row with worker_profile + user joined fields
 * @param {number} targetLat
 * @param {number} targetLng
 * @param {number} activeBookings - Count of pending/accepted bookings for this worker
 * @returns {number} composite score
 */
function scoreWorker(worker, targetLat, targetLng, activeBookings) {
  const distance = haversineKm(worker.latitude, worker.longitude, targetLat, targetLng);

  const proximityScore = (1 / (distance + 0.1)) * 10;
  const ratingScore    = (worker.rating_avg || 0) * 2;
  const workloadScore  = (1 / (activeBookings + 1)) * 5;

  // Last-assigned penalty: workers assigned very recently score slightly lower
  let lastAssignedPenalty = 0;
  if (worker.last_assigned_at) {
    const minutesSince = (Date.now() - new Date(worker.last_assigned_at).getTime()) / 60000;
    // Penalty decays over 60 minutes: newly assigned = 1 point lower
    lastAssignedPenalty = Math.max(0, 1 - minutesSince / 60);
  }

  return proximityScore + ratingScore + workloadScore - lastAssignedPenalty;
}

/**
 * Filter and rank available workers for a given location and category.
 *
 * @param {import('better-sqlite3').Database} db
 * @param {{ lat: number, lng: number, radius?: number, category?: string }} options
 * @returns {Array<object>} ranked workers with `distance` and `score` fields appended
 */
function dispatchWorkers(db, { lat, lng, radius = 5, category }) {
  // 1. Fetch all verified, available workers with a known location
  let query = `
    SELECT
      u.id          AS user_id,
      u.name,
      u.email,
      u.mobile,
      u.cooperative_id,
      wp.id         AS profile_id,
      wp.trade_category,
      wp.experience_years,
      wp.rating_avg,
      wp.jobs_completed,
      wp.latitude,
      wp.longitude,
      wp.availability,
      wp.last_assigned_at,
      wp.welfare_active,
      wp.cooperative_reg_no,
      wp.aadhaar_status,
      wp.police_status,
      wp.certificate_status
    FROM worker_profiles wp
    JOIN users u ON u.id = wp.user_id
    WHERE u.is_verified = 1
      AND wp.availability = 1
      AND wp.latitude IS NOT NULL
      AND wp.longitude IS NOT NULL
  `;

  const params = [];

  if (category) {
    query += ' AND wp.trade_category = ?';
    params.push(category);
  }

  const candidates = db.prepare(query).all(...params);

  // 2. Count active bookings per worker (pending or accepted)
  const activeBookingCounts = db.prepare(`
    SELECT worker_id, COUNT(*) AS cnt
    FROM bookings
    WHERE status IN ('pending', 'accepted')
    GROUP BY worker_id
  `).all();

  const activeMap = {};
  activeBookingCounts.forEach((row) => {
    activeMap[row.worker_id] = row.cnt;
  });

  // 3. Filter by haversine distance
  const nearby = candidates.filter((w) => {
    const dist = haversineKm(w.latitude, w.longitude, lat, lng);
    return dist <= radius;
  });

  // 4. Score each worker
  const scored = nearby.map((w) => {
    const dist   = haversineKm(w.latitude, w.longitude, lat, lng);
    const active = activeMap[w.user_id] || 0;
    const score  = scoreWorker(w, lat, lng, active);
    return { ...w, distance: Math.round(dist * 100) / 100, activeBookings: active, score };
  });

  // 5. Sort descending by score, tie-break ascending by last_assigned_at
  scored.sort((a, b) => {
    if (Math.abs(b.score - a.score) > 0.001) return b.score - a.score;
    // tie-break: least recently assigned first (null = never assigned → highest priority)
    const aTime = a.last_assigned_at ? new Date(a.last_assigned_at).getTime() : 0;
    const bTime = b.last_assigned_at ? new Date(b.last_assigned_at).getTime() : 0;
    return aTime - bTime;
  });

  return scored;
}

module.exports = { dispatchWorkers, haversineKm };
