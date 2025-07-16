//https://developers.momo.vn/#/docs/en/aiov2/?id=payment-method
//parameters
import crypto from "crypto";
import https from "https";
import Checkout from "../models/Checkout.js";
import Order from "../models/Order.js";
import Product from "../models/Product.js";
import Cart from "../models/Cart.js";
import { finalizeCheckout } from "../controllers/checkout.controller.js";
import { createMomoPayment } from "../services/momo.service.js";


export const momoTest = async (req, res) => {
  const { checkoutId, amount } = req.body;
  try {
    const momoRes = await createMomoPayment({ checkoutId, amount });
    res.status(200).json(momoRes);
  } catch (e) {
    res.status(500).json({ error: "Lỗi gọi MoMo", detail: e.message });
  }
};

// Endpoint IPN nhận notify từ MoMo
export const momoIpn = async (req, res) => {
  const secretKey = "K951B6PE1waDMi640xX08PD3vg6EkVlz";
  const body = req.body;
  // Log toàn bộ body IPN nhận được
  console.log("[MoMo IPN] Body:", JSON.stringify(body));
  // Tạo rawSignature từ body (theo tài liệu MoMo)
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
  // Log kết quả xác thực signature
  if (signature !== body.signature) {
    console.log("[MoMo IPN] Invalid signature!", { rawSignature, signature, momoSignature: body.signature });
    return res.status(400).json({ message: "Invalid signature" });
  } else {
    console.log("[MoMo IPN] Signature valid.");
  }
  // Xác thực thành công, cập nhật trạng thái đơn hàng
  try {
    const checkoutId = body.orderId;
    const checkout = await Checkout.findById(checkoutId);
    if (!checkout) {
      console.log(`[MoMo IPN] Checkout not found: ${checkoutId}`);
      return res.status(404).json({ message: "Checkout not found" });
    }
    // Kiểm tra amount có khớp với totalPrice của đơn hàng không
    if (parseInt(body.amount) !== checkout.totalPrice) {
      console.log(`[MoMo IPN] Amount mismatch! MoMo: ${body.amount}, Checkout: ${checkout.totalPrice}`);
      return res.status(400).json({ message: "Amount mismatch" });
    }
    console.log(`[MoMo IPN] Amount verified: ${body.amount}`);
    if (body.resultCode === 0) {
      // Thanh toán thành công
      checkout.paymentStatus = "Đã thanh toán";
      checkout.isPaid = true;
      checkout.paymentDetail = body;
      checkout.paidAt = Date.now();
      await checkout.save();
      console.log(`[MoMo IPN] Thanh toán thành công cho checkoutId: ${checkoutId}`);

      // Tạo notification thanh toán thành công
      await import("../models/Notification.js").then(({ default: Notification }) => Notification.create({
        user: checkout.user,
        title: "Thanh toán thành công",
        message: `Đơn hàng #${checkout._id} đã được thanh toán.`,
      }));

      // Tự động finalize checkout
      try {
        if (checkout.isPaid && !checkout.isFinalized) {
          await finalizeCheckoutDirectly(checkoutId, checkout.user);
        } else if (checkout.isFinalized) {
          console.log(`[MoMo IPN] Checkout đã được finalize trước đó`);
        } else {
          console.log(`[MoMo IPN] Checkout chưa thanh toán, không thể finalize`);
        }
      } catch (finalizeError) {
        console.log(`[MoMo IPN] Lỗi khi finalize checkout:`, finalizeError);
      }
    } else {
      // Thanh toán thất bại
      checkout.paymentStatus = "Thanh toán thất bại";
      checkout.paymentDetail = body;
      await checkout.save();
      console.log(`[MoMo IPN] Thanh toán thất bại cho checkoutId: ${checkoutId}`);
    }
    res.status(200).json({ message: "IPN received and processed" });
  } catch (e) {
    console.log("[MoMo IPN] Server error:", e);
    res.status(500).json({ message: "Server error", error: e.message });
  }
};

// Hàm kiểm tra trạng thái thanh toán từ MoMo
export const momoStatus = async (req, res) => {
  const { checkoutId } = req.body;
  
  if (!checkoutId) {
    return res.status(400).json({ message: "checkoutId is required" });
  }
  
  try {
    // Lấy thông tin checkout
    const checkout = await Checkout.findById(checkoutId);
    if (!checkout) {
      return res.status(404).json({ message: "Checkout not found" });
    }
    
    // Kiểm tra xem có paymentDetail không (từ IPN)
    if (checkout.paymentDetail && checkout.paymentDetail.resultCode === 0) {
      return res.json({
        success: true,
        isPaid: true,
        paymentStatus: checkout.paymentStatus,
        message: "Payment confirmed via IPN"
      });
    }
    
    // Nếu chưa có IPN, thử kiểm tra trực tiếp từ MoMo API
    const accessKey = "F8BBA842ECF85";
    const secretKey = "K951B6PE1waDMi640xX08PD3vg6EkVlz";
    const partnerCode = "MOMO";
    const requestId = checkoutId;
    
          const rawSignature = `accessKey=${accessKey}&orderId=${checkoutId}&partnerCode=${partnerCode}&requestId=${requestId}`;
    const signature = crypto
      .createHmac("sha256", secretKey)
      .update(rawSignature)
      .digest("hex");
    
    const requestBody = JSON.stringify({
      partnerCode,
      orderId: checkoutId,
      requestId,
      signature,
    });
    
    const options = {
      hostname: "test-payment.momo.vn",
      port: 443,
      path: "/v2/gateway/api/query",
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(requestBody),
      },
    };
    
    const momoReq = https.request(options, (momoRes) => {
      let data = "";
      momoRes.on("data", (chunk) => {
        data += chunk;
      });
      momoRes.on("end", async () => {
        try {
          const result = JSON.parse(data);
          console.log("[MoMo Status] Response:", result);
          
          if (result.resultCode === 0) {
            // Thanh toán thành công
            checkout.paymentStatus = "Đã thanh toán";
            checkout.isPaid = true;
            checkout.paymentDetail = result;
            checkout.paidAt = Date.now();
            await checkout.save();
            
            console.log(`[MoMo Status] Updated checkout ${checkoutId} to paid status`);
            
            res.json({
              success: true,
              isPaid: true,
              paymentStatus: "Đã thanh toán",
              message: "Payment confirmed via MoMo API"
            });
          } else {
            res.json({
              success: false,
              isPaid: false,
              paymentStatus: checkout.paymentStatus,
              message: "Payment not completed"
            });
          }
        } catch (e) {
          console.log("[MoMo Status] Parse error:", e);
          res.status(500).json({ 
            success: false, 
            message: "Error parsing MoMo response",
            error: e.message 
          });
        }
      });
    });
    
    momoReq.on("error", (e) => {
      console.log("[MoMo Status] Request error:", e);
      res.status(500).json({ 
        success: false, 
        message: "Error connecting to MoMo",
        error: e.message 
      });
    });
    
    momoReq.write(requestBody);
    momoReq.end();
    
  } catch (error) {
    console.log("[MoMo Status] Server error:", error);
    res.status(500).json({ 
      success: false, 
      message: "Server error",
      error: error.message 
    });
  }
};

export default { momoTest, momoIpn, momoStatus };