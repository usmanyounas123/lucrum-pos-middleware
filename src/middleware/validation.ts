import { Request, Response, NextFunction } from 'express';
import { ZodObject, ZodRawShape, ZodError } from 'zod';
import { getLogger } from '../services/logger';

const logger = getLogger();

export const validateRequest = (schema: ZodObject<ZodRawShape>) => 
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      await schema.parseAsync({
        body: req.body,
        query: req.query,
        params: req.params
      });
      return next();
    } catch (error) {
      if (error instanceof ZodError) {
        logger.warn('Validation error:', error.issues);
        return res.status(400).json({
          status: 'error',
          message: 'Validation failed',
          errors: error.issues.map((e: any) => ({
            field: e.path.join('.'),
            message: e.message
          }))
        });
      }
      return next(error);
    }
  };