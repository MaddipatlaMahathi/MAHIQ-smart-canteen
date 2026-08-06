const logger = require('../utilities/logger');
const GestureUtils = require('../utilities/gestureUtils');

class BasePage {
  constructor(driver) {
    this.driver = driver;
    this.gestures = new GestureUtils(driver);
  }

  async waitForElement(selector, timeout = 10000) {
    logger.info(`Waiting for element: ${selector}`);
    const el = await this.driver.$(selector);
    await el.waitForDisplayed({ timeout });
    return el;
  }

  async click(selector) {
    logger.info(`Clicking element: ${selector}`);
    const el = await this.waitForElement(selector);
    await el.click();
  }

  async type(selector, text) {
    logger.info(`Typing "${text}" into element: ${selector}`);
    const el = await this.waitForElement(selector);
    await el.setValue(text);
  }

  async getText(selector) {
    const el = await this.waitForElement(selector);
    const text = await el.getText();
    logger.info(`Got text "${text}" from element: ${selector}`);
    return text;
  }

  async isDisplayed(selector) {
    try {
      const el = await this.driver.$(selector);
      return await el.isDisplayed();
    } catch (error) {
      return false;
    }
  }
}

module.exports = BasePage;
