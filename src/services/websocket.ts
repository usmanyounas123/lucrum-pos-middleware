import { Server, Socket } from 'socket.io';
import { getLogger } from './logger';

const logger = getLogger();
const connectedClients = new Map<string, Socket>();

export const setupWebSocket = (io: Server) => {
  // Optional authentication middleware - can be disabled for simplicity
  io.use(async (socket, next) => {
    // For now, allow all connections without authentication
    // You can add API key validation here if needed
    next();
  });

  io.on('connection', (socket: Socket) => {
    const clientId = socket.handshake.headers['x-client-id'] as string || socket.id;
    const clientType = socket.handshake.headers['x-client-type'] as string || 'unknown';
    
    connectedClients.set(clientId, socket);
    logger.info(`Client connected: ${clientId} (type: ${clientType})`);
    
    // Send welcome message to newly connected client
    socket.emit('connection_status', {
      status: 'connected',
      client_id: clientId,
      timestamp: new Date().toISOString()
    });

    // Handle client disconnect
    socket.on('disconnect', (reason) => {
      connectedClients.delete(clientId);
      logger.info(`Client disconnected: ${clientId} (reason: ${reason})`);
    });

    // Handle socket errors
    socket.on('error', (error) => {
      logger.error(`Socket error from ${clientId}:`, error);
    });

    // Optional: Handle heartbeat/ping from clients
    socket.on('ping', () => {
      socket.emit('pong');
    });
  });
};

// Broadcast to all connected clients
export const broadcastToAll = (event: string, data: any) => {
  logger.info(`Broadcasting event "${event}" to ${connectedClients.size} clients`);
  connectedClients.forEach((socket, clientId) => {
    try {
      socket.emit(event, data);
    } catch (error) {
      logger.error(`Failed to emit to client ${clientId}:`, error);
    }
  });
};

// Get list of connected client IDs
export const getConnectedClients = () => {
  return Array.from(connectedClients.keys());
};

// Get number of connected clients
export const getClientCount = () => {
  return connectedClients.size;
};

// Disconnect a specific client
export const disconnectClient = (clientId: string) => {
  const socket = connectedClients.get(clientId);
  if (socket) {
    socket.disconnect();
    connectedClients.delete(clientId);
    logger.info(`Forcibly disconnected client: ${clientId}`);
    return true;
  }
  return false;
};

// Send message to specific client
export const sendToClient = (clientId: string, event: string, data: any) => {
  const socket = connectedClients.get(clientId);
  if (socket) {
    try {
      socket.emit(event, data);
      return true;
    } catch (error) {
      logger.error(`Failed to send to client ${clientId}:`, error);
      return false;
    }
  }
  logger.warn(`Client ${clientId} not found`);
  return false;
};