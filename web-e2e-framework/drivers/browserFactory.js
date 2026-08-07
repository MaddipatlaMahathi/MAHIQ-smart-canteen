const { Builder } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');

class BrowserFactory {
    static async getDriver(browserName = 'chrome') {
        let driver;
        
        switch (browserName.toLowerCase()) {
            case 'chrome':
                const options = new chrome.Options();
                options.addArguments('--headless'); // Useful for CI/CD environments
                options.addArguments('--no-sandbox');
                options.addArguments('--disable-dev-shm-usage');
                options.addArguments('--window-size=1920,1080');
                
                driver = await new Builder()
                    .forBrowser('chrome')
                    .setChromeOptions(options)
                    .build();
                break;
            default:
                throw new Error(`Browser not supported: ${browserName}`);
        }
        
        // Wait up to 10 seconds for elements to appear by default
        await driver.manage().setTimeouts({ implicit: 10000 });
        
        return driver;
    }
}

module.exports = BrowserFactory;
