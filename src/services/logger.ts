import winston from 'winston';

let logger: winston.Logger;

export const setupLogger = () => {
  if (logger) return logger;

  const logPath = process.env.LOG_PATH || 'logs/app.log';
  const logLevel = process.env.LOG_LEVEL || 'info';

  logger = winston.createLogger({
    level: logLevel,
    format: winston.format.combine(
      winston.format.timestamp(),
      winston.format.json()
    ),
    transports: [
      new winston.transports.File({ filename: logPath }),
      new winston.transports.Console({
        format: winston.format.combine(
          winston.format.colorize(),
          winston.format.simple()
        )
      })
    ]
  });

  return logger;
};

export const getLogger = () => {
  if (!logger) {
    return setupLogger();
  }
  return logger;
};