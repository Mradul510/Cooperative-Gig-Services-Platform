'use strict';

require('dotenv').config();

const config = {
  PORT: parseInt(process.env.PORT, 10) || 3000,
  JWT_SECRET: process.env.JWT_SECRET || 'coop-gig-secret-change-in-prod',
  JWT_EXPIRY: process.env.JWT_EXPIRY || '7d',
  STORAGE_PATH: process.env.STORAGE_PATH || './storage',
  DB_PATH: process.env.DB_PATH || './database.sqlite',
  WORKER_CUT: parseFloat(process.env.WORKER_CUT) || 85,
  WELFARE_CUT: parseFloat(process.env.WELFARE_CUT) || 10,
  PLATFORM_CUT: parseFloat(process.env.PLATFORM_CUT) || 5,
};

const feeSplit = {
  workerCut: config.WORKER_CUT,
  welfareCut: config.WELFARE_CUT,
  platformCut: config.PLATFORM_CUT,
};

module.exports = { ...config, feeSplit };
