const path = require('path');

const capabilities = {
    // Execution for APK
    apkConfig: {
        platformName: 'Android',
        'appium:automationName': 'UiAutomator2',
        'appium:deviceName': 'Android Emulator', // Or dynamically detected
        'appium:app': path.join(process.cwd(), 'app', 'app-release.apk'),
        'appium:autoGrantPermissions': true,
        'appium:noReset': false,
        'appium:newCommandTimeout': 300
    },

    // Execution for pre-installed application
    installedAppConfig: {
        platformName: 'Android',
        'appium:automationName': 'UiAutomator2',
        'appium:deviceName': 'Android Emulator',
        'appium:appPackage': process.env.APP_PACKAGE || 'com.example.app',
        'appium:appActivity': process.env.APP_ACTIVITY || 'com.example.app.MainActivity',
        'appium:autoGrantPermissions': true,
        'appium:noReset': true,
        'appium:newCommandTimeout': 300
    }
};

module.exports = { capabilities };
