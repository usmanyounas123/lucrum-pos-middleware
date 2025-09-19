import { Router } from 'express';

const router = Router();

// Simple clients endpoint
router.post('/clients', (req, res) => {
  res.json({ message: 'Client registered', client_id: `client-${Date.now()}` });
});

router.get('/clients/:id', (req, res) => {
  const { id } = req.params;
  res.json({ client_id: id, status: 'active' });
});

router.delete('/clients/:id', (req, res) => {
  const { id } = req.params;
  res.json({ message: 'Client deleted', client_id: id });
});

export { router as clientRoutes };