'use strict';

/**
 * Fee split service
 * Computes the 85 / 10 / 5 split (worker / welfare / platform).
 * Platform always gets the remainder so floating-point rounding never
 * causes the three parts to diverge from basePrice.
 *
 * @param {number} basePrice   - Total price of the booking
 * @param {number} workerCut   - Worker percentage (e.g. 85)
 * @param {number} welfareCut  - Welfare pool percentage (e.g. 10)
 * @returns {{ workerPayout: number, welfarePayout: number, platformPayout: number }}
 */
function computeSplit(basePrice, workerCut, welfareCut) {
  const workerPayout   = Math.round((basePrice * workerCut  / 100) * 100) / 100;
  const welfarePayout  = Math.round((basePrice * welfareCut / 100) * 100) / 100;
  const platformPayout = Math.round((basePrice - workerPayout - welfarePayout) * 100) / 100;
  return { workerPayout, welfarePayout, platformPayout };
}

module.exports = { computeSplit };
