import { Request, Response, NextFunction } from 'express';
import { getLogger } from '../services/logger';

const logger = getLogger();

export const validateApiKey = (req: Request, res: Response, next: NextFunction) => {
  const apiKey = req.headers['x-api-key'] as string;
  
  if (!apiKey) {
    return res.status(401).json({ 
      success: false,
      error: 'API key is required. Add X-API-Key header.' 
    });
  }
  
  // Simple validation against environment variable
  const validApiKey = process.env.ADMIN_API_KEY;
  
  if (!validApiKey) {
    logger.error('ADMIN_API_KEY not configured in environment');
    return res.status(500).json({ 
      success: false,
      error: 'Server configuration error' 
    });
  }
  
  if (apiKey !== validApiKey) {
    logger.warn(`Invalid API key attempt: ${apiKey.substring(0, 8)}...`);
    return res.status(401).json({ 
      success: false,
      error: 'Invalid API key' 
    });
  }
  
  // Add simple client info to request for logging
  (req as any).client = {
    apiKey: apiKey,
    authenticated: true,
    timestamp: new Date().toISOString()
  };
  
  next();
};