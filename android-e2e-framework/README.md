# Enterprise Appium E2E Automation Framework

This is a production-ready, highly scalable End-to-End (E2E) mobile automation framework built with Node.js, Appium 2.x, WebdriverIO, Mocha, and Chai. It is specifically designed for testing Android applications (both APKs and installed apps).

## Features
- **Page Object Model (POM)**: Ensures scalable and maintainable test architecture.
- **Reporting**: Generates comprehensive Excel reports (`exceljs`) and HTML reports (`mochawesome`).
- **Logging**: Detailed logging using Winston logger (`logs/`).
- **Failure Capture**: Automatically captures screenshots and device logs (`logcat`) upon test failure.
- **CI/CD Integration**: Fully integrated with GitHub Actions for automated executions on PRs and Pushes.
- **Gesture Support**: Reusable utility methods for tapping, scrolling, swiping, and zooming.

## Prerequisites
- Node.js (v16+)
- Appium 2.x (`npm i -g appium`)
- Appium UiAutomator2 Driver (`appium driver install uiautomator2`)
- Android SDK & Java (Set `ANDROID_HOME` and `JAVA_HOME` environment variables)
- A running Android Emulator or real device connected via ADB.

## Setup & Execution
1. Install dependencies:
   ```bash
   npm install
   ```

2. Start the Appium server in a separate terminal:
   ```bash
   appium
   ```

3. Run all tests:
   ```bash
   npm run test
   ```

4. Run specific test suite (e.g., authentication):
   ```bash
   npm run test:auth
   ```

## Directory Structure
- `config/`: Capabilities and environment configurations.
- `utilities/`: Reusable classes (Driver Factory, Gestures, Logging, Excel Reporting).
- `pages/`: Page Object classes encapsulating UI locators and actions.
- `tests/`: Mocha test scripts.
- `reports/`, `excel/`, `logs/`, `screenshots/`: Automatically generated test artifacts.
