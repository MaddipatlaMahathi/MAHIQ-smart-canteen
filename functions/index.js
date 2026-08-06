const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Razorpay = require("razorpay");
const crypto = require("crypto");

admin.initializeApp();

// Hardcoded for testing. Best practice: use Firebase Secret Manager or functions.config()
const razorpay = new Razorpay({
  key_id: 'rzp_test_rYjUq6xN2R6VjE', // Test Key ID
  key_secret: 'h4oRTYU8z6y7Q9g0T2Yp6R3V' // Test Key Secret (Mocked for testing)
});

exports.createRazorpayOrder = functions.https.onCall(async (data, context) => {
  // Ensure the user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Only authenticated users can place orders."
    );
  }

  const amount = data.amount;
  if (!amount) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Amount is required"
    );
  }

  try {
    const options = {
      amount: Math.round(amount * 100), // Convert to paise
      currency: "INR",
      receipt: `receipt_${Date.now()}`
    };

    const order = await razorpay.orders.create(options);
    
    // Return only necessary non-sensitive info to the client
    return {
      orderId: order.id,
      amount: order.amount,
      currency: order.currency,
    };
  } catch (error) {
    console.error("Error creating Razorpay order:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Failed to create Razorpay order"
    );
  }
});

exports.verifyRazorpayPayment = functions.https.onCall((data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Only authenticated users can verify payments."
    );
  }

  const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = data;

  if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing payment verification data"
    );
  }

  try {
    const secret = razorpay.key_secret;
    const body = razorpay_order_id + "|" + razorpay_payment_id;
    
    const expectedSignature = crypto
      .createHmac("sha256", secret)
      .update(body.toString())
      .digest("hex");

    const isAuthentic = expectedSignature === razorpay_signature;

    if (isAuthentic) {
      return { success: true };
    } else {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Invalid payment signature"
      );
    }
  } catch (error) {
    console.error("Error verifying payment:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Failed to verify payment"
    );
  }
});
