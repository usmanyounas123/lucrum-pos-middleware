import { Request, Response, NextFunction } from 'express';
import rateLimit from 'express-rate-limit';
import helmet from 'helmet';
import crypto from 'crypto';
import { getLogger } from '../services/logger';

const logger = getLogger();

// Rate limiting middleware
export const rateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: { error: 'Too many requests, please try again later.' },
  standardHeaders: true,
  legacyHeaders: false
});

// Security headers middleware using helmet
export const securityHeaders = helmet();

// Generate API key for new clients
export const generateApiKey = (clientId: string): string => {
  const randomBytes = crypto.randomBytes(32).toString('hex');
  const timestamp = Date.now().toString();
  const hash = crypto
    .createHash('sha256')
    .update(`${clientId}:${randomBytes}:${timestamp}`)
    .digest('hex');
  return hash;
};

// Validate request source IP
export const validateSourceIP = (allowedIPs: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const clientIP = req.ip || req.socket.remoteAddress;
    
    if (!clientIP || !allowedIPs.includes(clientIP)) {
      logger.warn(`Unauthorized access attempt from IP: ${clientIP}`);
      return res.status(403).json({
        status: 'error',
        message: 'Access denied: unauthorized IP address'
      });
    }
    next();
  };
};

// Request sanitization middleware
export const sanitizeRequest = (req: Request, _res: Response, next: NextFunction) => {
  if (req.body && typeof req.body === 'object') {
    for (const key in req.body) {
      if (typeof req.body[key] === 'string') {
        // Remove any potential XSS content
        req.body[key] = req.body[key]
          .replace(/[<>]/g, '')  // Remove < and >
          .trim();
      }
    }
  }
  next();
};