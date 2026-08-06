const driverFactory = require('../utilities/driverFactory');
const excelReporter = require('../utilities/excelReporter');
const logger = require('../utilities/logger');
const path = require('path');
const fs = require('fs');

let driver;

before(async function () {
  this.timeout(60000); // 1 minute for driver init
  try {
    driver = await driverFactory.initDriver();
    
    // Add Summary Row (Placeholder for actual run)
    excelReporter.addSummaryData({
      date: new Date().toISOString(),
      device: 'Android Emulator',
      version: '14.0',
      total: 0, passed: 0, failed: 0, skipped: 0, percentage: '0%', duration: '0s'
    });
  } catch (err) {
    logger.error('Failed to initialize driver before tests: ' + err.message);
    throw err;
  }
});

beforeEach(async function () {
  this.startTime = Date.now();
  logger.info(`--- Starting Test: ${this.currentTest.title} ---`);
});

afterEach(async function () {
  const duration = ((Date.now() - this.startTime) / 1000).toFixed(2) + 's';
  const status = this.currentTest.state === 'passed' ? 'Passed' : 'Failed';
  
  let screenshotPath = '';
  
  if (this.currentTest.state === 'failed') {
    logger.error(`Test Failed: ${this.currentTest.title} - ${this.currentTest.err.message}`);
    
    try {
      const fileName = `Fail_${Date.now()}.png`;
      screenshotPath = path.join(process.cwd(), 'screenshots', fileName);
      await driver.saveScreenshot(screenshotPath);
      logger.info(`Screenshot saved at: ${screenshotPath}`);
      
      // Also get logcat
      const logs = await driver.getLogs('logcat');
      fs.writeFileSync(path.join(process.cwd(), 'logs', `logcat_${Date.now()}.txt`), JSON.stringify(logs));
    } catch (e) {
      logger.error('Failed to capture failure artifacts: ' + e.message);
    }

    excelReporter.addFailedTestData({
      name: this.currentTest.title,
      reason: this.currentTest.err.message,
      screenshot: screenshotPath,
      device: 'Emulator',
      version: '14.0',
      activity: 'MainActivity'
    });
  }

  excelReporter.addTestCaseData({
    testId: `TC-${Math.floor(Math.random() * 1000)}`,
    module: 'E2E',
    scenario: this.currentTest.title,
    device: 'Emulator',
    status: status,
    start: new Date(this.startTime).toISOString(),
    end: new Date().toISOString(),
    duration: duration
  });

  excelReporter.addExecutionLog({
    timestamp: new Date().toISOString(),
    testName: this.currentTest.title,
    step: 'Completed',
    result: status,
    remarks: this.currentTest.err ? this.currentTest.err.message : 'Success'
  });
});

after(async function () {
  this.timeout(10000);
  await driverFactory.quitDriver();
  await excelReporter.generateReport();
});

module.exports = {
  getDriver: () => driver
};
