import { Router } from 'express';
import { orderRoutes } from './orders';
import lucrumRoutes from './lucrum';

export const setupRoutes = (app: Router) => {
  app.use('/api/v1', orderRoutes);
  app.use('/api/v1/lucrum', lucrumRoutes);
};