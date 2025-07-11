//https://developers.momo.vn/#/docs/en/aiov2/?id=payment-method
//parameters
import crypto from "crypto";
import https from "https";
import Checkout from "../models/Checkout.js";

export const momoTest = (req, res) => {
  const { checkoutId, amount } = req.body;
  const accessKey = "F8BBA842ECF85";
  const secretKey = "K951B6PE1waDMi640xX08PD3vg6EkVlz";
  const orderInfo = "pay with MoMo";
  const partnerCode = "MOMO";
  const redirectUrl = "https://webhook.site/b3088a6a-2d17-4f8d-a383-71389a6c600b";
  const ipnUrl = "https://burgerking-j92p.onrender.com/api/payment/momo/ipn"; // Đổi thành endpoint thật của bạn
  const requestType = "payWithMethod";
  const orderId = checkoutId;
  const requestId = checkoutId;
  const extraData = "";
  const orderGroupId = "";
  const autoCapture = true;
  const lang = "vi";

  const rawSignature = `accessKey=${accessKey}&amount=${amount}&extraData=${extraData}&ipnUrl=${ipnUrl}&orderId=${orderId}&orderInfo=${orderInfo}&partnerCode=${partnerCode}&redirectUrl=${redirectUrl}&requestId=${requestId}&requestType=${requestType}`;
  const signature = crypto
    .createHmac("sha256", secretKey)
    .update(rawSignature)
    .digest("hex");

  const requestBody = JSON.stringify({
    partnerCode,
    partnerName: "Test",
    storeId: "MomoTestStore",
    requestId,
    amount,
    orderId,
    orderInfo,
    redirectUrl,
    ipnUrl,
    lang,
    requestType,
    autoCapture,
    extraData,
    orderGroupId,
    signature,
  });

  const options = {
    hostname: "test-payment.momo.vn",
    port: 443,
    path: "/v2/gateway/api/create",
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
    momoRes.on("end", () => {
      try {
        const result = JSON.parse(data);
        res.status(200).json(result);
      } catch (e) {
        res
          .status(500)
          .json({ error: "Lỗi parse response MoMo", detail: e.message });
      }
    });
  });

  momoReq.on("error", (e) => {
    res.status(500).json({ error: "Lỗi kết nối MoMo", detail: e.message });
  });

  momoReq.write(requestBody);
  momoReq.end();
};

// Endpoint IPN nhận notify từ MoMo
export const momoIpn = async (req, res) => {
  const secretKey = "K951B6PE1waDMi640xX08PD3vg6EkVlz";
  const body = req.body;
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
  if (signature !== body.signature) {
    return res.status(400).json({ message: "Invalid signature" });
  }
  // Xác thực thành công, cập nhật trạng thái đơn hàng
  try {
    const checkoutId = body.orderId;
    const checkout = await Checkout.findById(checkoutId);
    if (!checkout) {
      return res.status(404).json({ message: "Checkout not found" });
    }
    if (body.resultCode === 0) {
      // Thanh toán thành công
      checkout.paymentStatus = "Đã thanh toán";
      checkout.isPaid = true;
      checkout.paymentDetail = body;
      checkout.paidAt = Date.now();
      await checkout.save();
    } else {
      // Thanh toán thất bại
      checkout.paymentStatus = "Thanh toán thất bại";
      checkout.paymentDetail = body;
      await checkout.save();
    }
    res.status(200).json({ message: "IPN received and processed" });
  } catch (e) {
    res.status(500).json({ message: "Server error", error: e.message });
  }
};

export default { momoTest, momoIpn };
