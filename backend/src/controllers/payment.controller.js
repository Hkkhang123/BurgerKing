import axios from "axios";
import crypto from "crypto";
import qs from "qs";
import dotenv from "dotenv";
import Checkout from "../models/Checkout.js";
dotenv.config();

// Helper: Tạo chữ ký HMAC SHA256
function createMomoSignature(secretKey, rawSignature) {
  return crypto
    .createHmac("sha256", secretKey)
    .update(rawSignature)
    .digest("hex");
}

// Helper: Xác thực notify từ Momo
function verifyMomoSignature(secretKey, body) {
  const {
    partnerCode,
    accessKey,
    requestId,
    amount,
    orderId,
    orderInfo,
    orderType,
    transId,
    resultCode,
    message,
    payType,
    responseTime,
    extraData,
    signature,
  } = body;
  const rawSignature = `accessKey=${accessKey}&amount=${amount}&extraData=${extraData}&message=${message}&orderId=${orderId}&orderInfo=${orderInfo}&orderType=${orderType}&partnerCode=${partnerCode}&payType=${payType}&requestId=${requestId}&responseTime=${responseTime}&resultCode=${resultCode}&transId=${transId}`;
  const expectedSignature = createMomoSignature(secretKey, rawSignature);
  return signature === expectedSignature;
}

// Tạo thanh toán Momo
export async function createMomoPayment(req, res) {
  console.log("API /api/payment/momo được gọi", req.body);
  const { checkoutId, redirectUrl, ipnUrl } = req.body;
  // Lấy checkout từ DB
  const checkout = await Checkout.findById(checkoutId);
  if (!checkout) return res.status(404).json({ message: "Checkout not found" });
  if (checkout.isPaid)
    return res.status(400).json({ message: "Checkout already paid" });

  // Tích hợp trực tiếp thông tin test của Momo
  const partnerCode = "MOMO";
  const accessKey = "F8BBA842ECF85";
  const secretKey = "K951B6PE1waDMi640xX08PD3vg6EkVlz";
  const requestId = partnerCode + Date.now();
  const orderId = checkoutId + "_" + Date.now(); // Đảm bảo mỗi lần là duy nhất
  const orderInfo = "Thanh toán đơn hàng " + checkoutId;
  const amount = checkout.totalPrice.toString();
  const requestType = "captureWallet";
  const extraData = "";

  // Tạo rawSignature đúng thứ tự
  const rawSignature = `accessKey=${accessKey}&amount=${amount}&extraData=${extraData}&ipnUrl=${ipnUrl}&orderId=${orderId}&orderInfo=${orderInfo}&partnerCode=${partnerCode}&redirectUrl=${redirectUrl}&requestId=${requestId}&requestType=${requestType}`;
  const signature = createMomoSignature(secretKey, rawSignature);

  // Tạo body gửi lên Momo
  const body = {
    partnerCode,
    accessKey,
    requestId,
    amount,
    orderId,
    orderInfo,
    redirectUrl,
    ipnUrl,
    extraData,
    requestType,
    signature,
    lang: "vi",
  };

  try {
    // Lưu trạng thái pending cho checkout
    checkout.paymentStatus = "Chờ thanh toán";
    await checkout.save();
    // Gửi request đến Momo
    const response = await axios.post(
      "https://test-payment.momo.vn/v2/gateway/api/create",
      body,
      {
        headers: { "Content-Type": "application/json" },
      }
    );
    // Chỉ trả về payUrl khi MoMo trả về thành công
    if (response.data.resultCode === 0) {
      return res.json({ payUrl: response.data.payUrl });
    } else {
      return res.status(400).json({ error: response.data.message || "Tạo giao dịch MoMo thất bại" });
    }
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
}

// Tạo thanh toán VNPay
// export function createVNPayUrl(req, res) {
//   const { orderId, amount, returnUrl } = req.body;
//   const vnp_TmnCode = process.env.VNP_TMNCODE;
//   const vnp_HashSecret = process.env.VNP_HASHSECRET;
//   const vnp_Url = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
//   const vnp_ReturnUrl = returnUrl;

//   let vnp_Params = {
//     vnp_Version: "2.1.0",
//     vnp_Command: "pay",
//     vnp_TmnCode: vnp_TmnCode,
//     vnp_Amount: amount * 100,
//     vnp_CreateDate: new Date()
//       .toISOString()
//       .replace(/[-:TZ.]/g, "")
//       .slice(0, 14),
//     vnp_CurrCode: "VND",
//     vnp_IpAddr: req.ip || "127.0.0.1",
//     vnp_Locale: "vn",
//     vnp_OrderInfo: "Thanh toan don hang " + orderId,
//     vnp_OrderType: "other",
//     vnp_ReturnUrl: vnp_ReturnUrl,
//     vnp_TxnRef: orderId,
//   };

//   vnp_Params = sortObject(vnp_Params);
//   const signData = qs.stringify(vnp_Params, { encode: false });
//   const secureHash = crypto
//     .createHmac("sha512", vnp_HashSecret)
//     .update(signData)
//     .digest("hex");
//   vnp_Params["vnp_SecureHash"] = secureHash;
//   const payUrl = vnp_Url + "?" + qs.stringify(vnp_Params, { encode: false });
//   return res.json({ payUrl });
// }

// function sortObject(obj) {
//   const sorted = {};
//   const keys = Object.keys(obj).sort();
//   for (let key of keys) {
//     sorted[key] = obj[key];
//   }
//   return sorted;
// }

// Nhận notify từ Momo
export async function momoNotify(req, res) {
  // Xác thực chữ ký notify
  if (!verifyMomoSignature(secretKey, req.body)) {
    return res.status(400).json({ message: "Invalid signature" });
  }
  const { orderId, resultCode } = req.body;
  if (!orderId) return res.status(400).json({ message: "orderId is required" });
  try {
    const checkout = await Checkout.findById(orderId);
    if (!checkout)
      return res.status(404).json({ message: "Checkout not found" });
    if (resultCode === 0) {
      // Thanh toán thành công
      checkout.isPaid = true;
      checkout.paymentStatus = "Đã thanh toán";
      checkout.paymentDetail = req.body;
      checkout.paidAt = Date.now();
      await checkout.save();
    } else {
      checkout.paymentStatus = "Thanh toán thất bại";
      checkout.paymentDetail = req.body;
      await checkout.save();
    }
    res.status(200).send("OK");
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
}

// Nhận notify từ VNPay
// export async function vnpayReturn(req, res) {
//   // TODO: Xác thực chữ ký notify từ VNPay
//   const { vnp_TxnRef } = req.query; // vnp_TxnRef là _id của Checkout
//   if (!vnp_TxnRef)
//     return res.status(400).json({ message: "vnp_TxnRef is required" });
//   try {
//     const checkout = await Checkout.findById(vnp_TxnRef);
//     if (!checkout)
//       return res.status(404).json({ message: "Checkout not found" });
//     // Cập nhật trạng thái thanh toán
//     checkout.isPaid = true;
//     checkout.paymentStatus = "Đã thanh toán";
//     checkout.paymentDetail = req.query; // Lưu toàn bộ notify làm paymentDetail
//     checkout.paidAt = Date.now();
//     await checkout.save();
//     res.status(200).send("OK");
//   } catch (err) {
//     res.status(500).json({ error: err.message });
//   }
// }
