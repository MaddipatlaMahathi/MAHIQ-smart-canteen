const logger = require('../utilities/logger');

class BasePage {
    constructor(driver) {
        this.driver = driver;
    }

    async waitForElement(selector, timeout = 10000) {
        logger.info(`Waiting for element: ${selector}`);
        const element = await this.driver.$(selector);
        await element.waitForExist({ timeout });
        return element;
    }

    async clickElement(selector) {
        logger.info(`Clicking element: ${selector}`);
        const element = await this.waitForElement(selector);
        await element.click();
    }

    async typeText(selector, text) {
        logger.info(`Typing text into ${selector}`);
        const element = await this.waitForElement(selector);
        await element.setValue(text);
    }

    async getText(selector) {
        const element = await this.waitForElement(selector);
        const text = await element.getText();
        logger.info(`Got text from ${selector}: ${text}`);
        return text;
    }

    async isElementDisplayed(selector) {
        try {
            const element = await this.driver.$(selector);
            return await element.isDisplayed();
        } catch (error) {
            return false;
        }
    }
}

module.exports = BasePage;
