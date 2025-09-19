import { Request, Response, NextFunction } from 'express';
import { getDatabase } from '../services/database';
import { getLogger } from '../services/logger';

const logger = getLogger();
const db = getDatabase();

export const validateApiKey = (req: Request, res: Response, next: NextFunction) => {
  const apiKey = req.headers['x-api-key'] as string;
  
  if (!apiKey) {
    return res.status(401).json({ error: 'API key is required' });
  }
  
  try {
    const db = getDatabase();
    const query = 'SELECT * FROM clients WHERE api_key = ? AND is_active = 1';
    const stmt = db.prepare(query);
    const row = stmt.get([apiKey]);
    
    if (!row) {
      return res.status(401).json({ error: 'Invalid API key' });
    }
    
    // Update last connected timestamp
    const updateQuery = 'UPDATE clients SET last_connected = CURRENT_TIMESTAMP WHERE api_key = ?';
    const updateStmt = db.prepare(updateQuery);
    updateStmt.run([apiKey]);
    
    // Add client info to request
    (req as any).client = row;
    next();
  } catch (error) {
    logger.error('Database error in auth middleware:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Extend Express Request interface
declare global {
  namespace Express {
    interface Request {
      clientId: string;
      clientType: string;
    }
  }
}