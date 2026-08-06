const BasePage = require('./BasePage');

class LoginPage extends BasePage {
  constructor(driver) {
    super(driver);
  }

  // Locators
  get usernameInput() { return '//*[@resource-id="com.example.app:id/username"]'; }
  get passwordInput() { return '//*[@resource-id="com.example.app:id/password"]'; }
  get loginButton() { return '//*[@resource-id="com.example.app:id/loginBtn"]'; }
  get errorMessage() { return '//*[@resource-id="com.example.app:id/errorMsg"]'; }
  get dashboardTitle() { return '//*[@resource-id="com.example.app:id/dashboardTitle"]'; }

  // Actions
  async login(username, password) {
    if (username) await this.type(this.usernameInput, username);
    if (password) await this.type(this.passwordInput, password);
    await this.click(this.loginButton);
  }

  async getError() {
    return await this.getText(this.errorMessage);
  }

  async isOnDashboard() {
    return await this.isDisplayed(this.dashboardTitle);
  }
}

module.exports = LoginPage;
