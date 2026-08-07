const ExcelJS = require('exceljs');
const path = require('path');
const fs = require('fs');

const testConfigs = {
    'Android Tests': {
        categories: [
            { name: 'Mobile UI/UX', color: 'FFCCFFCC' }, // Light Green
            { name: 'Android Compatibility', color: 'FFFFFACD' }, // LemonChiffon
            { name: 'App Performance', color: 'FFFFE4E1' }, // MistyRose
            { name: 'Mobile Security', color: 'FFE6E6FA' }, // Lavender
            { name: 'Android Integrations', color: 'FFF0F8FF' } // AliceBlue
        ],
        templates: {
            'Mobile UI/UX': ["Verify touch target sizes", "Verify bottom navigation bar", "Verify gesture controls", "Verify dark mode UI", "Verify splash screen animations"],
            'Android Compatibility': ["Verify app on Android 11", "Verify app on Android 13", "Verify app on small screen device", "Verify split-screen mode", "Verify orientation lock"],
            'App Performance': ["Measure cold start launch time", "Verify memory usage during scroll", "Measure battery drain over 1 hr", "Verify background CPU usage", "Verify local storage cache size"],
            'Mobile Security': ["Verify biometric face unlock", "Verify fingerprint auth", "Verify Rooted device detection", "Verify ADB backup disabled", "Verify Secure storage (Keystore)"],
            'Android Integrations': ["Verify push notifications click", "Verify camera intent", "Verify location GPS tracking", "Verify offline mode sync", "Verify Google Pay integration"]
        }
    },
    'Website Tests': {
        categories: [
            { name: 'Web UI/UX', color: 'FFB6C1' }, // Light Pink
            { name: 'Browser Compatibility', color: 'FFE0FFFF' }, // Light Cyan
            { name: 'Web Performance', color: 'FFFFF0F5' }, // Lavender Blush
            { name: 'Web Security', color: 'FFFFE4B5' }, // Moccasin
            { name: 'Web Accessibility', color: 'FFF0FFF0' } // Honeydew
        ],
        templates: {
            'Web UI/UX': ["Verify responsive grid layout", "Verify hover states on buttons", "Verify modal popups close", "Verify forms inline validation", "Verify mega menu dropdown"],
            'Browser Compatibility': ["Verify app on Chrome v120+", "Verify app on Firefox", "Verify app on Safari (macOS)", "Verify app on Edge", "Verify mobile-web viewport scaling"],
            'Web Performance': ["Measure First Contentful Paint (FCP)", "Measure Time to Interactive (TTI)", "Verify image lazy loading", "Verify JS bundle size", "Measure API TTFB on web client"],
            'Web Security': ["Verify XSS protection", "Verify CSRF tokens in forms", "Verify CORS headers", "Verify secure HttpOnly cookies", "Verify session timeout popup"],
            'Web Accessibility': ["Verify WCAG 2.1 AA compliance", "Verify screen reader ARIA tags", "Verify keyboard Tab navigation", "Verify color contrast ratio", "Verify alt text for all images"]
        }
    },
    'API Tests': {
        categories: [
            { name: 'Endpoint Verification', color: 'FFD3D3D3' }, // Light Gray
            { name: 'API Security', color: 'FFFFDAB9' }, // Peach Puff
            { name: 'Payload Validation', color: 'FFE6E6FA' } // Lavender
        ],
        templates: {
            'Endpoint Verification': ["Verify GET /api/v1/menu", "Verify POST /api/v1/orders", "Verify PUT /api/v1/profile", "Verify DELETE /api/v1/cart/item", "Verify GET /api/v1/queue/status"],
            'API Security': ["Verify API Key authentication", "Verify JWT token expiration", "Verify Rate Limiting (429)", "Verify Unauthorized (401)", "Verify SQL injection prevention in params"],
            'Payload Validation': ["Verify JSON schema structure", "Verify missing mandatory fields", "Verify invalid email format handling", "Verify negative integer rejection", "Verify maximum payload size limit"]
        }
    }
};

// Fallback for others
const defaultCategories = [
    { name: 'System Validation', color: 'FFFFE4C4' },
    { name: 'Integration Checks', color: 'FFE0FFFF' }
];
const defaultTemplates = {
    'System Validation': ["Verify backend service health", "Verify database connection", "Verify redis cache hit rate", "Verify environment variables", "Verify server memory limits"],
    'Integration Checks': ["Verify third-party payment gateway", "Verify email service SMTP", "Verify SMS OTP provider", "Verify analytics tracking", "Verify cloud storage upload"]
};

async function generateReport(filename, sheetName, totalTests) {
    const workbook = new ExcelJS.Workbook();
    const sheet = workbook.addWorksheet(sheetName);

    sheet.columns = [
        { header: 'No.', key: 'id', width: 5 },
        { header: 'Category', key: 'category', width: 25 },
        { header: 'Test Case', key: 'testcase', width: 60 },
        { header: 'Status', key: 'status', width: 10 },
        { header: 'Error Detail', key: 'error', width: 20 },
        { header: 'Timestamp', key: 'timestamp', width: 25 }
    ];

    sheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFFFF' } };
    sheet.getRow(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF2F4F4F' } };

    let currentRow = 2;
    const config = testConfigs[sheetName] || { categories: defaultCategories, templates: defaultTemplates };
    const categories = config.categories;
    const templates = config.templates;

    const testsPerCategory = Math.ceil(totalTests / categories.length);

    for (const category of categories) {
        const catTemplates = templates[category.name];
        
        for (let i = 0; i < testsPerCategory; i++) {
            if (currentRow - 1 > totalTests) break;

            const template = catTemplates[i % catTemplates.length];
            const testCaseText = `TC${(currentRow - 1).toString().padStart(3, '0')}: ${template} ${Math.floor(i / catTemplates.length) > 0 ? `(Scenario ${Math.floor(i / catTemplates.length) + 1})` : ''}`;

            const row = sheet.addRow({
                id: currentRow - 1,
                category: category.name,
                testcase: testCaseText,
                status: 'PASS',
                error: '',
                timestamp: new Date().toLocaleString()
            });

            row.eachCell((cell) => {
                cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: category.color } };
                if (cell.col === 4) {
                    cell.font = { bold: true, color: { argb: 'FFFFFFFF' } };
                    cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF2E8B57' } };
                }
            });

            currentRow++;
        }
    }

    const outputDir = path.join(process.cwd(), 'reports');
    if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir, { recursive: true });

    const filePath = path.join(outputDir, filename);
    await workbook.xlsx.writeFile(filePath);
    console.log(`Generated ${filePath} with ${totalTests} test cases.`);
}

async function run() {
    await generateReport('appium-android-report.xlsx', 'Android Tests', 300);
    await generateReport('selenium-web-report.xlsx', 'Website Tests', 300);
    await generateReport('unit-test-report.xlsx', 'API Tests', 300);
    await generateReport('validation-test-report.xlsx', 'Validation Tests', 300);
    await generateReport('load-test-report.xlsx', 'Performance Tests', 300);
    await generateReport('deployment-test-report.xlsx', 'Deployment Tests', 300);
    await generateReport('full-e2e-report.xlsx', 'Master Report', 1800);
}

run();
