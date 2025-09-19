import { Router } from 'express';
import { validateApiKey } from '../middleware/auth';

const router = Router();

// Simple health check endpoint
router.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Simplified orders endpoint
router.get('/orders', validateApiKey, (req, res) => {
  res.json({ orders: [], message: 'Orders endpoint active' });
});

router.post('/orders', validateApiKey, (req, res) => {
  res.json({ message: 'Order created', order_id: `order-${Date.now()}` });
});

router.put('/orders/:id/status', validateApiKey, (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  res.json({ message: 'Order status updated', order_id: id, status });
});

router.post('/invoices', validateApiKey, (req, res) => {
  res.json({ message: 'Invoice created', invoice_id: `inv-${Date.now()}` });
});

export { router as orderRoutes };