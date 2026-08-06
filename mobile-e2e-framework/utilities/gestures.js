const logger = require('./logger');

class Gestures {
    constructor(driver) {
        this.driver = driver;
    }

    async tap(element) {
        await element.click();
        logger.info(`Tapped on element`);
    }

    async swipeUp() {
        logger.info('Swiping up...');
        const { width, height } = await this.driver.getWindowSize();
        await this.driver.performActions([{
            type: 'pointer',
            id: 'finger1',
            parameters: { pointerType: 'touch' },
            actions: [
                { type: 'pointerMove', duration: 0, x: width / 2, y: height * 0.8 },
                { type: 'pointerDown', button: 0 },
                { type: 'pointerMove', duration: 1000, x: width / 2, y: height * 0.2 },
                { type: 'pointerUp', button: 0 }
            ]
        }]);
    }

    async swipeDown() {
        logger.info('Swiping down...');
        const { width, height } = await this.driver.getWindowSize();
        await this.driver.performActions([{
            type: 'pointer',
            id: 'finger1',
            parameters: { pointerType: 'touch' },
            actions: [
                { type: 'pointerMove', duration: 0, x: width / 2, y: height * 0.2 },
                { type: 'pointerDown', button: 0 },
                { type: 'pointerMove', duration: 1000, x: width / 2, y: height * 0.8 },
                { type: 'pointerUp', button: 0 }
            ]
        }]);
    }

    async scrollUntilVisible(selector, maxSwipes = 5) {
        logger.info(`Scrolling until element ${selector} is visible`);
        let isVisible = false;
        let swipes = 0;

        while (!isVisible && swipes < maxSwipes) {
            const element = await this.driver.$(selector);
            if (await element.isDisplayed()) {
                isVisible = true;
            } else {
                await this.swipeUp();
                swipes++;
            }
        }
        return isVisible;
    }
}

module.exports = Gestures;
