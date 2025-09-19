import { Request, Response, NextFunction } from 'express';
import { getLogger } from '../services/logger';

const logger = getLogger();

export class AppError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public type: string = 'AppError'
  ) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (err instanceof AppError) {
    logger.warn(`Application error: ${err.message}`, {
      type: err.type,
      statusCode: err.statusCode,
      path: req.path
    });

    return res.status(err.statusCode).json({
      status: 'error',
      type: err.type,
      message: err.message
    });
  }

  // Unexpected errors
  logger.error('Unexpected error:', err);
  return res.status(500).json({
    status: 'error',
    message: 'Internal server error'
  });
};

// Not found handler
export const notFoundHandler = (req: Request, res: Response) => {
  logger.warn(`Route not found: ${req.method} ${req.path}`);
  res.status(404).json({
    status: 'error',
    message: 'Route not found'
  });
};

// Custom async handler to catch promise rejections
export const asyncHandler = (fn: (req: Request, res: Response, next: NextFunction) => Promise<any>) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};