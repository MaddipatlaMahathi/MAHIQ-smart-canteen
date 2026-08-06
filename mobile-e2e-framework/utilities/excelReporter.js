const ExcelJS = require('exceljs');
const path = require('path');
const fs = require('fs');
const logger = require('./logger');

class ExcelReporter {
    constructor() {
        this.workbook = new ExcelJS.Workbook();
        this.workbook.creator = 'Automation Framework';
        this.filePath = path.join(process.cwd(), 'excel', 'Mobile_E2E_Report.xlsx');
        
        const dir = path.join(process.cwd(), 'excel');
        if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });

        this.summarySheet = this.workbook.addWorksheet('Summary');
        this.testCasesSheet = this.workbook.addWorksheet('Test Cases');
        this.failedTestsSheet = this.workbook.addWorksheet('Failed Tests');
        this.executionLogsSheet = this.workbook.addWorksheet('Execution Logs');

        this.initSheets();
    }

    initSheets() {
        // Sheet 1: Summary
        this.summarySheet.columns = [
            { header: 'Execution Date', key: 'date', width: 20 },
            { header: 'Device Name', key: 'device', width: 25 },
            { header: 'Android Version', key: 'version', width: 20 },
            { header: 'Total Tests', key: 'total', width: 15 },
            { header: 'Passed', key: 'passed', width: 15 },
            { header: 'Failed', key: 'failed', width: 15 },
            { header: 'Skipped', key: 'skipped', width: 15 },
            { header: 'Pass Percentage', key: 'pass_percent', width: 20 },
            { header: 'Execution Duration', key: 'duration', width: 20 }
        ];

        // Sheet 2: Test Cases
        this.testCasesSheet.columns = [
            { header: 'Test ID', key: 'testId', width: 15 },
            { header: 'Module', key: 'module', width: 20 },
            { header: 'Scenario Name', key: 'scenario', width: 40 },
            { header: 'Device', key: 'device', width: 20 },
            { header: 'Status', key: 'status', width: 15 },
            { header: 'Start Time', key: 'start_time', width: 25 },
            { header: 'End Time', key: 'end_time', width: 25 },
            { header: 'Duration (ms)', key: 'duration', width: 15 }
        ];

        // Sheet 3: Failed Tests
        this.failedTestsSheet.columns = [
            { header: 'Test Name', key: 'testName', width: 40 },
            { header: 'Failure Reason', key: 'reason', width: 50 },
            { header: 'Screenshot Path', key: 'screenshot', width: 50 },
            { header: 'Device', key: 'device', width: 20 },
            { header: 'Android Version', key: 'version', width: 20 },
            { header: 'Activity Name', key: 'activity', width: 30 }
        ];

        // Sheet 4: Execution Logs
        this.executionLogsSheet.columns = [
            { header: 'Timestamp', key: 'timestamp', width: 25 },
            { header: 'Test Name', key: 'testName', width: 40 },
            { header: 'Step Description', key: 'step', width: 50 },
            { header: 'Result', key: 'result', width: 15 },
            { header: 'Remarks', key: 'remarks', width: 40 }
        ];

        this.applyStyles(this.summarySheet);
        this.applyStyles(this.testCasesSheet);
        this.applyStyles(this.failedTestsSheet);
        this.applyStyles(this.executionLogsSheet);
    }

    applyStyles(sheet) {
        sheet.getRow(1).font = { bold: true };
        sheet.getRow(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFD3D3D3' } };
    }

    addSummary(data) {
        this.summarySheet.addRow(data);
    }

    addTestCase(data) {
        this.testCasesSheet.addRow(data);
    }

    addFailedTest(data) {
        this.failedTestsSheet.addRow(data);
    }

    addExecutionLog(data) {
        this.executionLogsSheet.addRow(data);
    }

    async generateReport() {
        try {
            await this.workbook.xlsx.writeFile(this.filePath);
            logger.info(`Excel report generated successfully at: ${this.filePath}`);
        } catch (error) {
            logger.error(`Failed to generate Excel report: ${error.message}`);
        }
    }
}

module.exports = new ExcelReporter();
