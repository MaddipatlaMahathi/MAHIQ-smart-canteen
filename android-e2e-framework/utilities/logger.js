const winston = require('winston');
const path = require('path');

// Custom format for logging
const logFormat = winston.format.printf(({ level, message, timestamp, stack }) => {
  return `${timestamp} ${level.toUpperCase()}: ${stack || message}`;
});

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    winston.format.errors({ stack: true }),
    winston.format.splat(),
    logFormat
  ),
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        logFormat
      )
    }),
    new winston.transports.File({ 
      filename: path.join(process.cwd(), 'logs', 'execution.log'),
      level: 'info'
    }),
    new winston.transports.File({ 
      filename: path.join(process.cwd(), 'logs', 'error.log'),
      level: 'error'
    })
  ]
});

module.exports = logger;
