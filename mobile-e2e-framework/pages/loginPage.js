const BasePage = require('./basePage');

class LoginPage extends BasePage {
    constructor(driver) {
        super(driver);
        // Using sample Android selectors (UiSelector / Accessibility ID)
        this.usernameInput = '~username-input';
        this.passwordInput = '~password-input';
        this.loginButton = '~login-button';
        this.errorMessage = '~error-message';
        this.dashboardHeader = '~dashboard-header';
    }

    async login(username, password) {
        if (username) await this.typeText(this.usernameInput, username);
        if (password) await this.typeText(this.passwordInput, password);
        await this.clickElement(this.loginButton);
    }

    async getErrorMessage() {
        return await this.getText(this.errorMessage);
    }

    async isDashboardVisible() {
        return await this.isElementDisplayed(this.dashboardHeader);
    }
}

module.exports = LoginPage;
