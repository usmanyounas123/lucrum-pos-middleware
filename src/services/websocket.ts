import { Server, Socket } from 'socket.io';
import { getLogger } from './logger';

const logger = getLogger();
const connectedClients = new Map<string, Socket>();

export const setupWebSocket = (io: Server) => {
  io.use(async (socket, next) => {
    const apiKey = socket.handshake.auth?.apiKey || socket.handshake.headers['x-api-key'];
    if (!apiKey) {
      return next(new Error('Authentication failed: No API key provided'));
    }
    
    // TODO: Validate API key against database
    // For now, we'll just pass through
    next();
  });

  io.on('connection', (socket: Socket) => {
    const clientId = socket.handshake.headers['x-client-id'] as string || socket.id;
    const clientType = socket.handshake.headers['x-client-type'] as string || 'unknown';
    
    connectedClients.set(clientId, socket);
    logger.info(`Client connected: ${clientId} (type: ${clientType})`);
    
    // Legacy order events (backward compatibility)
    socket.on('order:new', (data) => {
      logger.info(`New order received from ${clientId}:`, data);
      socket.broadcast.emit('order:created', data);
    });

    socket.on('order:status', (data) => {
      logger.info(`Order status update from ${clientId}:`, data);
      socket.broadcast.emit('order:updated', data);
    });

    // Lucrum Sales Order events
    socket.on('lucrum_sales_order_created', (data) => {
      logger.info(`New Lucrum sales order received from ${clientId}:`, data.name);
      socket.broadcast.emit('sales-order:created', data);
      
      // Also emit to KDS clients if this is a KDS item
      if (data.kds_status && data.items?.some((item: any) => item.is_kds_item)) {
        socket.broadcast.emit('kds:new-order', {
          name: data.name,
          table_no: data.table_no,
          branch: data.branch,
          customer_name: data.customer_name,
          items: data.items.filter((item: any) => item.is_kds_item),
          kds_status: data.kds_status,
          order_time: data.order_time,
          resturent_type: data.resturent_type
        });
      }
    });

    socket.on('sales-order:status-update', (data) => {
      logger.info(`Sales order status update from ${clientId}:`, data);
      socket.broadcast.emit('sales-order:status-updated', data);
    });

    // KDS specific events
    socket.on('kds:status-update', (data) => {
      logger.info(`KDS status update from ${clientId}:`, data);
      socket.broadcast.emit('kds:status-updated', data);
      
      // Emit general sales order update as well
      socket.broadcast.emit('sales-order:kds-updated', data);
    });

    socket.on('kds:item-status-update', (data) => {
      logger.info(`KDS item status update from ${clientId}:`, data);
      socket.broadcast.emit('kds:item-status-updated', data);
    });

    socket.on('kds:cooking-started', (data) => {
      logger.info(`Cooking started for order ${data.order_name} from ${clientId}`);
      socket.broadcast.emit('kds:cooking-started', data);
    });

    socket.on('kds:cooking-completed', (data) => {
      logger.info(`Cooking completed for order ${data.order_name} from ${clientId}`);
      socket.broadcast.emit('kds:cooking-completed', data);
    });

    socket.on('kds:order-ready', (data) => {
      logger.info(`Order ${data.order_name} is ready from ${clientId}`);
      socket.broadcast.emit('kds:order-ready', data);
      
      // Notify POS systems that order is ready
      socket.broadcast.emit('pos:order-ready', data);
    });

    socket.on('kds:order-served', (data) => {
      logger.info(`Order ${data.order_name} has been served from ${clientId}`);
      socket.broadcast.emit('kds:order-served', data);
    });

    // Table management events
    socket.on('table:order-placed', (data) => {
      logger.info(`Order placed for table ${data.table_no} from ${clientId}`);
      socket.broadcast.emit('table:order-placed', data);
    });

    socket.on('table:bill-requested', (data) => {
      logger.info(`Bill requested for table ${data.table_no} from ${clientId}`);
      socket.broadcast.emit('table:bill-requested', data);
    });

    // Branch/location specific events
    socket.on('branch:order-update', (data) => {
      logger.info(`Branch order update from ${clientId}:`, data);
      // Only broadcast to clients connected to the same branch
      socket.to(`branch:${data.branch}`).emit('branch:order-updated', data);
    });

    // Join branch room for location-specific updates
    socket.on('join-branch', (branchName) => {
      socket.join(`branch:${branchName}`);
      logger.info(`Client ${clientId} joined branch: ${branchName}`);
    });

    // Join KDS station room for station-specific updates
    socket.on('join-kds-station', (stationName) => {
      socket.join(`kds:${stationName}`);
      logger.info(`Client ${clientId} joined KDS station: ${stationName}`);
    });

    // Error handling
    socket.on('error', (error) => {
      logger.error(`Socket error from ${clientId}:`, error);
    });

    socket.on('disconnect', (reason) => {
      connectedClients.delete(clientId);
      logger.info(`Client disconnected: ${clientId} (reason: ${reason})`);
    });
  });
};

export const broadcastToAll = (event: string, data: any) => {
  connectedClients.forEach((socket) => {
    socket.emit(event, data);
  });
};

export const broadcastToBranch = (branchName: string, event: string, data: any) => {
  connectedClients.forEach((socket) => {
    socket.to(`branch:${branchName}`).emit(event, data);
  });
};

export const broadcastToKDSStation = (stationName: string, event: string, data: any) => {
  connectedClients.forEach((socket) => {
    socket.to(`kds:${stationName}`).emit(event, data);
  });
};

export const getConnectedClients = () => {
  return Array.from(connectedClients.keys());
};

export const getClientCount = () => {
  return connectedClients.size;
};