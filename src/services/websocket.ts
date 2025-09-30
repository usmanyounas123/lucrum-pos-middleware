import { Server, Socket } from 'socket.io';
import { getLogger } from './logger';

const logger = getLogger();
const connectedClients = new Map<string, Socket>();

export const setupWebSocket = (io: Server) => {
  // Simple authentication middleware
  io.use(async (socket, next) => {
    const apiKey = socket.handshake.auth?.apiKey;
    
    // Optional API key validation - comment out for no auth
    if (process.env.ADMIN_API_KEY && apiKey !== process.env.ADMIN_API_KEY) {
      logger.warn(`WebSocket authentication failed for ${socket.id}`);
      next(new Error('Invalid API key'));
      return;
    }
    
    next();
  });

  io.on('connection', (socket: Socket) => {
    const clientId = socket.id;
    connectedClients.set(clientId, socket);
    
    logger.info(`WebSocket client connected: ${clientId}`);
    
    // Send connection confirmation
    socket.emit('connected', {
      client_id: clientId,
      timestamp: new Date().toISOString(),
      events: ['order_created', 'order_updated', 'order_deleted']
    });

    // Handle disconnect
    socket.on('disconnect', (reason) => {
      connectedClients.delete(clientId);
      logger.info(`WebSocket client disconnected: ${clientId} (${reason})`);
    });

    // Handle errors
    socket.on('error', (error) => {
      logger.error(`WebSocket error from ${clientId}:`, error);
    });

    // Simple ping/pong for connection health
    socket.on('ping', () => {
      socket.emit('pong', { timestamp: new Date().toISOString() });
    });
  });
  
  logger.info('Simple WebSocket server initialized');
};

// Broadcast order events to all connected clients
export const broadcastToAll = (event: string, data: any) => {
  if (connectedClients.size === 0) {
    logger.debug(`No clients connected to broadcast event: ${event}`);
    return;
  }
  
  logger.info(`Broadcasting ${event} to ${connectedClients.size} clients`);
  
  connectedClients.forEach((socket, clientId) => {
    try {
      socket.emit(event, {
        ...data,
        broadcast_timestamp: new Date().toISOString()
      });
    } catch (error) {
      logger.error(`Failed to broadcast to client ${clientId}:`, error);
      // Remove dead connections
      connectedClients.delete(clientId);
    }
  });
};

// Get connection statistics
export const getConnectionStats = () => {
  return {
    connected_clients: connectedClients.size,
    client_ids: Array.from(connectedClients.keys())
  };
};