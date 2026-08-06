const { remote } = require('webdriverio');
const { config, getCapabilities } = require('../config/appium.config');
const logger = require('./logger');

class DriverFactory {
  constructor() {
    this.driver = null;
  }

  async initDriver() {
    if (this.driver) {
      return this.driver;
    }

    const options = {
      hostname: config.hostname,
      port: config.port,
      path: config.path,
      capabilities: getCapabilities(),
      logLevel: 'error'
    };

    try {
      logger.info('Initializing Appium Driver Session...');
      this.driver = await remote(options);
      logger.info('Appium Driver successfully initialized.');
      return this.driver;
    } catch (error) {
      logger.error(`Failed to initialize Appium Driver: ${error.message}`);
      throw error;
    }
  }

  getDriver() {
    if (!this.driver) {
      throw new Error('Driver is not initialized! Call initDriver() first.');
    }
    return this.driver;
  }

  async quitDriver() {
    if (this.driver) {
      try {
        await this.driver.deleteSession();
        logger.info('Appium Driver session closed.');
      } catch (error) {
        logger.error(`Error while closing driver session: ${error.message}`);
      } finally {
        this.driver = null;
      }
    }
  }
}

module.exports = new DriverFactory();
