const fs = require('fs');
const path = require('path');
const logger = require('./logger');

class DeviceUtils {
    constructor(driver) {
        this.driver = driver;
    }

    async captureScreenshot(testName) {
        try {
            const dir = path.join(process.cwd(), 'screenshots');
            if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });

            const safeName = testName.replace(/[^a-z0-9]/gi, '_').toLowerCase();
            const filePath = path.join(dir, `${safeName}_${Date.now()}.png`);
            
            await this.driver.saveScreenshot(filePath);
            logger.info(`Screenshot captured: ${filePath}`);
            return filePath;
        } catch (error) {
            logger.error(`Failed to capture screenshot: ${error.message}`);
            return null;
        }
    }

    async captureLogcat(testName) {
        try {
            const dir = path.join(process.cwd(), 'reports', 'failures');
            if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });

            const logs = await this.driver.getLogs('logcat');
            const safeName = testName.replace(/[^a-z0-9]/gi, '_').toLowerCase();
            const filePath = path.join(dir, `${safeName}_logcat_${Date.now()}.txt`);
            
            fs.writeFileSync(filePath, logs.map(l => `[${l.level}] ${l.message}`).join('\n'));
            logger.info(`Logcat captured: ${filePath}`);
            return filePath;
        } catch (error) {
            logger.error(`Failed to capture logcat: ${error.message}`);
            return null;
        }
    }

    async getCurrentActivity() {
        try {
            return await this.driver.getCurrentActivity();
        } catch (error) {
            return 'Unknown Activity';
        }
    }
}

module.exports = DeviceUtils;
