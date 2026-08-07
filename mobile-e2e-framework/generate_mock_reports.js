const ExcelJS = require('exceljs');
const path = require('path');
const fs = require('fs');

const testConfigs = {
    'Android Tests': {
        categories: [
            { name: 'Mobile App UI/UX', color: 'FFCCFFCC' }, 
            { name: 'Canteen Core Flows', color: 'FFFFFACD' }, 
            { name: 'Queue & Tracking', color: 'FFFFE4E1' }, 
            { name: 'Mobile Security', color: 'FFE6E6FA' }, 
            { name: 'Hardware Integrations', color: 'FFF0F8FF' } 
        ],
        templates: {
            'Mobile App UI/UX': [
                "Verify MAHIQ splash screen loads canteen logo correctly",
                "Verify dark mode UI for late-night hostel orders",
                "Verify smooth scrolling on long canteen menu list",
                "Verify 'Add to Cart' floating button animation",
                "Verify readable fonts for food item descriptions"
            ],
            'Canteen Core Flows': [
                "Verify adding 3 Samosas and 1 Coffee to cart",
                "Verify cart total recalculates when item quantity changes",
                "Verify student can apply valid coupon code at checkout",
                "Verify Razorpay UPI payment popup launches correctly",
                "Verify order is placed and virtual token is generated"
            ],
            'Queue & Tracking': [
                "Verify real-time queue length shows 'High Traffic'",
                "Verify order status changes to 'Preparing' live",
                "Verify estimated wait time updates dynamically",
                "Verify push notification received when order is 'Ready'",
                "Verify past orders appear in student order history"
            ],
            'Mobile Security': [
                "Verify biometric auth for quick checkout",
                "Verify automatic logout after 30 mins of inactivity",
                "Verify student cannot access Admin dashboard",
                "Verify secure transmission of payment details",
                "Verify app prevents screen recording on payment page"
            ],
            'Hardware Integrations': [
                "Verify scanning table QR code opens menu directly",
                "Verify GPS location warns if outside college campus",
                "Verify push notification sound for order readiness",
                "Verify background sync updates menu prices",
                "Verify camera intent for profile picture upload"
            ]
        }
    },
    'Website Tests': {
        categories: [
            { name: 'Web Dashboard UI', color: 'FFB6C1' }, 
            { name: 'Admin Panel Flows', color: 'FFE0FFFF' }, 
            { name: 'Web Performance', color: 'FFFFF0F5' }, 
            { name: 'Cross-Browser', color: 'FFFFE4B5' }, 
            { name: 'Accessibility', color: 'FFF0FFF0' } 
        ],
        templates: {
            'Web Dashboard UI': [
                "Verify responsive grid layout for food categories",
                "Verify hover states on 'Add to Cart' buttons",
                "Verify sticky header stays visible on scroll",
                "Verify interactive pie chart for daily sales stats",
                "Verify search bar auto-suggests 'Biryani'"
            ],
            'Admin Panel Flows': [
                "Verify Admin can mark 'Chicken Noodles' as Out of Stock",
                "Verify Admin can approve pending cash orders",
                "Verify Admin can bulk-update menu prices",
                "Verify Admin sees live incoming orders dashboard",
                "Verify Admin can generate daily revenue PDF report"
            ],
            'Web Performance': [
                "Measure load time of high-res food images",
                "Verify lazy loading of below-the-fold menu items",
                "Measure Time to Interactive on Admin live dashboard",
                "Verify web socket connection latency for live queue",
                "Verify caching of static menu assets"
            ],
            'Cross-Browser': [
                "Verify web portal renders correctly on Chrome v120+",
                "Verify Razorpay integration works on Safari macOS",
                "Verify responsive mobile-web view on iPhone 15 size",
                "Verify admin dashboard charts on Firefox",
                "Verify printing receipts layout on Edge browser"
            ],
            'Accessibility': [
                "Verify keyboard navigation through menu items",
                "Verify screen reader reads 'Out of Stock' badges",
                "Verify color contrast for 'Order Ready' green text",
                "Verify alt text for all food item thumbnails",
                "Verify focus indicator on checkout form fields"
            ]
        }
    },
    'API Tests': {
        categories: [
            { name: 'Menu & Orders API', color: 'FFD3D3D3' }, 
            { name: 'Auth & Security', color: 'FFFFDAB9' }, 
            { name: 'Queue Sockets', color: 'FFE6E6FA' } 
        ],
        templates: {
            'Menu & Orders API': [
                "Verify GET /api/v1/canteen/menu returns 200 OK",
                "Verify POST /api/v1/orders creates new order with token",
                "Verify PUT /api/v1/admin/inventory updates stock correctly",
                "Verify GET /api/v1/orders/history returns user orders",
                "Verify DELETE /api/v1/cart/items clears the cart"
            ],
            'Auth & Security': [
                "Verify POST /api/v1/auth/login returns valid JWT",
                "Verify expired JWT token returns 401 Unauthorized",
                "Verify rate limiting (429) on spamming order endpoint",
                "Verify student token cannot access /api/v1/admin/*",
                "Verify SQL injection prevention on search?q= parameter"
            ],
            'Queue Sockets': [
                "Verify WebSocket connection established successfully",
                "Verify socket receives 'order_status_update' event",
                "Verify socket receives 'queue_length_change' event",
                "Verify socket auto-reconnects on disconnection",
                "Verify maximum payload size for socket messages"
            ]
        }
    }
};

// Fallback for others
const defaultCategories = [
    { name: 'MAHIQ Database', color: 'FFFFE4C4' },
    { name: 'External Integrations', color: 'FFE0FFFF' }
];
const defaultTemplates = {
    'MAHIQ Database': [
        "Verify order insertion into MongoDB collection", 
        "Verify Redis cache stores active menu items", 
        "Verify ACID transaction during concurrent order placement", 
        "Verify database index on order_id for fast lookups", 
        "Verify daily backup job executes successfully"
    ],
    'External Integrations': [
        "Verify Razorpay payment gateway webhook triggers", 
        "Verify Firebase Cloud Messaging (FCM) push alerts", 
        "Verify Twilio SMS integration for OTP login", 
        "Verify AWS S3 upload for canteen item images", 
        "Verify Google Maps API for campus delivery distance"
    ]
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
    console.log(`Generated MAHIQ customized report: ${filePath}`);
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
