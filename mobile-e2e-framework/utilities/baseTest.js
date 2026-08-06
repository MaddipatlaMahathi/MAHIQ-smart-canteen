const driverFactory = require('../drivers/driverFactory');
const excelReporter = require('./excelReporter');
const DeviceUtils = require('./deviceUtils');
const logger = require('./logger');

let driver;
let deviceUtils;
let executionStartTime;

const baseTest = {
    setup: async function (executionType = 'apk') {
        logger.info('--- Starting Test Execution ---');
        executionStartTime = Date.now();
        driver = await driverFactory.initDriver(executionType);
        deviceUtils = new DeviceUtils(driver);
        
        // Add Summary Row
        excelReporter.addSummary({
            date: new Date().toISOString().split('T')[0],
            device: 'Android Emulator',
            version: 'Latest',
            total: 0, passed: 0, failed: 0, skipped: 0,
            pass_percent: '0%',
            duration: '0s'
        });
        
        return { driver, deviceUtils };
    },

    teardown: async function () {
        logger.info('--- Ending Test Execution ---');
        await driverFactory.quitDriver();
        await excelReporter.generateReport();
    },

    handleFailure: async function (testCtx) {
        if (testCtx.state === 'failed') {
            logger.error(`Test Failed: ${testCtx.title}`);
            const screenshotPath = await deviceUtils.captureScreenshot(testCtx.title);
            const logcatPath = await deviceUtils.captureLogcat(testCtx.title);
            const activity = await deviceUtils.getCurrentActivity();

            excelReporter.addFailedTest({
                testName: testCtx.title,
                reason: testCtx.err.message,
                screenshot: screenshotPath || 'N/A',
                device: 'Android Emulator',
                version: 'Latest',
                activity: activity
            });
            
            excelReporter.addExecutionLog({
                timestamp: new Date().toISOString(),
                testName: testCtx.title,
                step: 'Failure Handler',
                result: 'FAIL',
                remarks: `Logs saved to ${logcatPath}`
            });
        }
    }
};

module.exports = baseTest;
