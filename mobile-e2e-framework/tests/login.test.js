const { expect } = require('chai');
const baseTest = require('../utilities/baseTest');
const LoginPage = require('../pages/loginPage');
const users = require('../testdata/users.json');
const excelReporter = require('../utilities/excelReporter');

describe('Authentication Testing', function () {
    let driver;
    let loginPage;
    let testStartTime;

    before(async function () {
        const setup = await baseTest.setup('apk');
        driver = setup.driver;
        loginPage = new LoginPage(driver);
    });

    beforeEach(function () {
        testStartTime = Date.now();
    });

    afterEach(async function () {
        await baseTest.handleFailure(this.currentTest);
        
        const duration = Date.now() - testStartTime;
        excelReporter.addTestCase({
            testId: `TC_${Math.floor(Math.random() * 1000)}`,
            module: 'Authentication',
            scenario: this.currentTest.title,
            device: 'Android Emulator',
            status: this.currentTest.state === 'passed' ? 'PASS' : 'FAIL',
            start_time: new Date(testStartTime).toISOString(),
            end_time: new Date().toISOString(),
            duration: duration
        });
        
        excelReporter.addExecutionLog({
            timestamp: new Date().toISOString(),
            testName: this.currentTest.title,
            step: 'Execution Completed',
            result: this.currentTest.state === 'passed' ? 'PASS' : 'FAIL',
            remarks: 'Handled by AfterEach'
        });
    });

    after(async function () {
        await baseTest.teardown();
    });

    it('should show error on empty credentials', async function () {
        await loginPage.login('', '');
        const error = await loginPage.getErrorMessage();
        expect(error).to.include('required');
    });

    it('should show error on invalid credentials', async function () {
        await loginPage.login(users.invalidUser.username, users.invalidUser.password);
        const error = await loginPage.getErrorMessage();
        expect(error).to.include('invalid');
    });

    it('should successfully login with valid credentials', async function () {
        await loginPage.login(users.validUser.username, users.validUser.password);
        const isDashboard = await loginPage.isDashboardVisible();
        expect(isDashboard).to.be.true;
    });
});
