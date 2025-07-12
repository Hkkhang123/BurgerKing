import crypto from 'crypto';

const secretKey = "K951B6PE1waDMi640xX08PD3vg6EkVlz";

// Lấy checkoutId và amount từ command line arguments
const checkoutId = process.argv[2];
const amount = process.argv[3];

if (!checkoutId || !amount) {
  console.log("Usage: node test-momo-signature.js <checkoutId> <amount>");
  console.log("Example: node test-momo-signature.js 64f8a1b2c3d4e5f678901234 50000");
  process.exit(1);
}

const body = {
  accessKey: "F8BBA842ECF85",
  amount: amount,
  extraData: "",
  message: "Success",
  orderId: checkoutId,
  orderInfo: "pay with MoMo",
  orderType: "momo_wallet",
  partnerCode: "MOMO",
  payType: "qr",
  requestId: checkoutId,
  responseTime: Date.now(),
  resultCode: 0,
  transId: "123456789"
};

// Tạo rawSignature theo đúng thứ tự MoMo yêu cầu
const rawSignature =
  `accessKey=${body.accessKey}` +
  `&amount=${body.amount}` +
  `&extraData=${body.extraData}` +
  `&message=${body.message}` +
  `&orderId=${body.orderId}` +
  `&orderInfo=${body.orderInfo}` +
  `&orderType=${body.orderType}` +
  `&partnerCode=${body.partnerCode}` +
  `&payType=${body.payType}` +
  `&requestId=${body.requestId}` +
  `&responseTime=${body.responseTime}` +
  `&resultCode=${body.resultCode}` +
  `&transId=${body.transId}`;

const signature = crypto.createHmac("sha256", secretKey).update(rawSignature).digest("hex");

console.log("=== MoMo IPN Test Helper ===");
console.log("CheckoutId:", checkoutId);
console.log("Amount:", amount);
console.log("Raw Signature:", rawSignature);
console.log("Generated Signature:", signature);
console.log("\n=== Complete Body for Postman ===");
console.log(JSON.stringify(body, null, 2));

// Thêm signature vào body
body.signature = signature;

console.log("\n=== Body with Signature ===");
console.log(JSON.stringify(body, null, 2));

console.log("\n=== Test URL ===");
console.log("POST https://burgerking-j92p.onrender.com/api/payment/momo/ipn");
console.log("Content-Type: application/json"); 