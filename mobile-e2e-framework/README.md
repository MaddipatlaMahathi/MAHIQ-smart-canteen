# Enterprise Appium E2E Automation Framework

A production-ready mobile automation framework for Android applications using Appium, Node.js, Mocha, and WebDriverIO.

## Features
- **Appium 2.x** with `UiAutomator2` driver
- **Mocha + Chai** for testing and assertions
- **Page Object Model (POM)** architecture
- **Excel Reports** (4 customized sheets: Summary, Test Cases, Failures, Logs)
- **HTML Reports** via Mochawesome
- **Failure Handling**: Automatically captures screenshots, logcat, and current activity
- **CI/CD Integration**: Fully ready for GitHub Actions
- **Custom Utility Layer**: Wrappers for Gestures, device state, and waits

## Setup & Installation

### Prerequisites
1. Node.js (v16+)
2. Java Development Kit (JDK 11+)
3. Android SDK & Android Emulator (or real device)
4. Appium 2.0 globally installed:
   ```bash
   npm install -g appium
   appium driver install uiautomator2
   ```

### Installation
Clone the repository, navigate to `mobile-e2e-framework`, and install dependencies:
```bash
cd mobile-e2e-framework
npm install
```

## Configuration
Modify `config/capabilities.js` to point to your specific `.apk` file or installed app package. 
If testing via APK, drop your apk file inside `mobile-e2e-framework/app/app-release.apk`.

## Execution

### Run all tests:
```bash
npm run test
```

### Run specific test (e.g. Login):
```bash
npm run test:login
```

## Generated Artifacts
After execution, the following folders are generated:
- `reports/` -> Mochawesome HTML Reports
- `excel/` -> `Mobile_E2E_Report.xlsx`
- `screenshots/` -> Failure screenshots
- `logs/` -> Framework and Logcat logs
