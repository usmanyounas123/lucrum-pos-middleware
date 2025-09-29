import { Router } from 'express';
import { orderRoutes } from './orders';

export const setupRoutes = (app: Router) => {
  app.use('/api', orderRoutes);
};