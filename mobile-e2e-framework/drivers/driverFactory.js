const { remote } = require('webdriverio');
const { capabilities } = require('../config/capabilities');
const logger = require('../utilities/logger');

class DriverFactory {
    constructor() {
        this.driver = null;
    }

    async initDriver(executionType = 'apk') {
        try {
            const config = {
                path: '/',
                port: 4723,
                capabilities: executionType === 'apk' ? capabilities.apkConfig : capabilities.installedAppConfig
            };

            logger.info(`Initializing Appium Driver with ${executionType} configuration...`);
            this.driver = await remote(config);
            logger.info('Driver initialized successfully.');
            return this.driver;
        } catch (error) {
            logger.error(`Error initializing driver: ${error.message}`);
            throw error;
        }
    }

    async quitDriver() {
        if (this.driver) {
            logger.info('Quitting driver...');
            await this.driver.deleteSession();
            this.driver = null;
        }
    }
}

module.exports = new DriverFactory();
