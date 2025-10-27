import * as dotenv from 'dotenv';
dotenv.config();

export const JWT_CONFIG = {
  secret: process.env.JWT_SECRET || 'your-secret-key-change-in-production',
  accessTokenExpiresIn: process.env.JWT_ACCESS_TOKEN_EXPIRES_IN || '15m',
  refreshTokenExpiresIn: process.env.JWT_REFRESH_TOKEN_EXPIRES_IN || '7d',
  signOptions: { 
    expiresIn: process.env.JWT_ACCESS_TOKEN_EXPIRES_IN || '15m'
  },
};