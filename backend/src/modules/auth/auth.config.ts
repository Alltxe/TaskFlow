import * as dotenv from 'dotenv';
dotenv.config();

export const JWT_CONFIG = {
  secret: process.env.JWT_SECRET || 'your-secret-key-change-in-production',
  signOptions: { 
    expiresIn: (process.env.JWT_EXPIRES_IN as any) || '7d' 
  },
};