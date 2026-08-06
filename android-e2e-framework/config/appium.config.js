const path = require('path');

const config = {
  // Use APK if APP_MODE=apk is passed in env, else use installed app (appPackage/appActivity)
  useApk: process.env.APP_MODE === 'apk',
  
  // App settings for installed app mode
  appPackage: process.env.APP_PACKAGE || 'com.example.app',
  appActivity: process.env.APP_ACTIVITY || 'com.example.app.MainActivity',

  // App settings for APK mode
  apkPath: process.env.APK_PATH || path.join(process.cwd(), 'app', 'app-release.apk'),

  // Device settings
  deviceName: process.env.DEVICE_NAME || 'emulator-5554',
  platformVersion: process.env.PLATFORM_VERSION || '14.0',
  platformName: 'Android',
  automationName: 'UiAutomator2',

  // Appium server settings
  hostname: process.env.APPIUM_HOST || '127.0.0.1',
  port: parseInt(process.env.APPIUM_PORT, 10) || 4723,
  path: '/',
};

const getCapabilities = () => {
  const caps = {
    platformName: config.platformName,
    'appium:automationName': config.automationName,
    'appium:deviceName': config.deviceName,
    'appium:platformVersion': config.platformVersion,
    'appium:autoGrantPermissions': true,
    'appium:noReset': false,
    'appium:fullReset': true, // clean install each time
  };

  if (config.useApk) {
    caps['appium:app'] = config.apkPath;
  } else {
    caps['appium:appPackage'] = config.appPackage;
    caps['appium:appActivity'] = config.appActivity;
  }

  return caps;
};

module.exports = {
  config,
  getCapabilities
};
