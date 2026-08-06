const ExcelJS = require('exceljs');
const path = require('path');
const logger = require('./logger');

class ExcelReporter {
  constructor() {
    this.workbook = new ExcelJS.Workbook();
    this.summarySheet = this.workbook.addWorksheet('Summary');
    this.testCasesSheet = this.workbook.addWorksheet('Test Cases');
    this.failedTestsSheet = this.workbook.addWorksheet('Failed Tests');
    this.executionLogsSheet = this.workbook.addWorksheet('Execution Logs');

    this.setupHeaders();
  }

  setupHeaders() {
    // Sheet 1: Summary
    this.summarySheet.columns = [
      { header: 'Execution Date', key: 'date', width: 20 },
      { header: 'Device Name', key: 'device', width: 25 },
      { header: 'Android Version', key: 'version', width: 15 },
      { header: 'Total Tests', key: 'total', width: 15 },
      { header: 'Passed', key: 'passed', width: 10 },
      { header: 'Failed', key: 'failed', width: 10 },
      { header: 'Skipped', key: 'skipped', width: 10 },
      { header: 'Pass Percentage', key: 'percentage', width: 15 },
      { header: 'Execution Duration', key: 'duration', width: 20 }
    ];

    // Sheet 2: Test Cases
    this.testCasesSheet.columns = [
      { header: 'Test ID', key: 'testId', width: 15 },
      { header: 'Module', key: 'module', width: 20 },
      { header: 'Scenario Name', key: 'scenario', width: 40 },
      { header: 'Device', key: 'device', width: 20 },
      { header: 'Status', key: 'status', width: 10 },
      { header: 'Start Time', key: 'start', width: 20 },
      { header: 'End Time', key: 'end', width: 20 },
      { header: 'Duration', key: 'duration', width: 15 }
    ];

    // Sheet 3: Failed Tests
    this.failedTestsSheet.columns = [
      { header: 'Test Name', key: 'name', width: 40 },
      { header: 'Failure Reason', key: 'reason', width: 50 },
      { header: 'Screenshot Path', key: 'screenshot', width: 60 },
      { header: 'Device', key: 'device', width: 20 },
      { header: 'Android Version', key: 'version', width: 15 },
      { header: 'Activity Name', key: 'activity', width: 30 }
    ];

    // Sheet 4: Execution Logs
    this.executionLogsSheet.columns = [
      { header: 'Timestamp', key: 'timestamp', width: 25 },
      { header: 'Test Name', key: 'testName', width: 40 },
      { header: 'Step Description', key: 'step', width: 50 },
      { header: 'Result', key: 'result', width: 10 },
      { header: 'Remarks', key: 'remarks', width: 30 }
    ];

    // Style headers
    this.workbook.worksheets.forEach(sheet => {
      sheet.getRow(1).font = { bold: true };
      sheet.getRow(1).fill = {
        type: 'pattern',
        pattern: 'solid',
        fgColor: { argb: 'FFE0E0E0' }
      };
    });
  }

  addSummaryData(data) {
    this.summarySheet.addRow(data);
  }

  addTestCaseData(data) {
    const row = this.testCasesSheet.addRow(data);
    row.getCell('status').font = {
      color: { argb: data.status === 'Passed' ? 'FF008000' : (data.status === 'Failed' ? 'FFFF0000' : 'FF808080') }
    };
  }

  addFailedTestData(data) {
    this.failedTestsSheet.addRow(data);
  }

  addExecutionLog(data) {
    this.executionLogsSheet.addRow(data);
  }

  async generateReport() {
    try {
      const filePath = path.join(process.cwd(), 'excel', 'Mobile_E2E_Report.xlsx');
      await this.workbook.xlsx.writeFile(filePath);
      logger.info(`Excel Report generated successfully at: ${filePath}`);
    } catch (error) {
      logger.error(`Failed to generate Excel report: ${error.message}`);
    }
  }
}

// Export as a singleton instance so it can be updated globally throughout the test run
module.exports = new ExcelReporter();
