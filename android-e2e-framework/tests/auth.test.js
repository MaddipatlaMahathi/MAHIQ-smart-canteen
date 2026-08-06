const { expect } = require('chai');
const { getDriver } = require('./baseTest');
const LoginPage = require('../pages/LoginPage');

describe('Authentication Flow E2E Tests', function () {
  let loginPage;

  before(function () {
    loginPage = new LoginPage(getDriver());
  });

  it('Should show error on empty username', async function () {
    await loginPage.login('', 'Password123');
    const error = await loginPage.getError();
    expect(error).to.include('Username is required');
  });

  it('Should show error on empty password', async function () {
    await loginPage.login('user@example.com', '');
    const error = await loginPage.getError();
    expect(error).to.include('Password is required');
  });

  it('Should show error on invalid credentials', async function () {
    await loginPage.login('invalid@example.com', 'wrongpassword');
    const error = await loginPage.getError();
    expect(error).to.include('Invalid credentials');
  });

  it('Should successfully login with valid credentials', async function () {
    await loginPage.login('valid@example.com', 'ValidPass123!');
    const isOnDashboard = await loginPage.isOnDashboard();
    expect(isOnDashboard).to.be.true;
  });
});
