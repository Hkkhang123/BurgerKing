import Cart from "../models/Cart.js";
import Product from "../models/Product.js";
import Order from "../models/Order.js";
import Checkout from "../models/Checkout.js";
import crypto from "crypto";
import https from "https";

export const createCheckout = async (req, res) => {
  const { checkoutItem, shippingAddress, paymentMethod, totalPrice } = req.body;
  if (!checkoutItem || checkoutItem.length === 0) {
    return res.status(400).json({ message: "No item in checkout" });
  }
  try {
    if (paymentMethod === "Thanh toán khi nhận hàng") {
      // Tạo Order ngay lập tức cho thanh toán khi nhận hàng
      const orderCode = generateOrderCode();
      
      const newOrder = await Order.create({
        user: req.user._id,
        orderItems: checkoutItem,
        shippingAddress,
        paymentMethod,
        totalPrice,
        paymentStatus: "Chờ thanh toán",
        isPaid: false,
        status: "Chờ xử lý",
        orderCode: orderCode,
      });
      
      // Xóa giỏ hàng sau khi tạo order thành công
      await Cart.findOneAndDelete({ user: req.user._id });
      
      console.log(`Order created for user ${req.user._id} with cash on delivery. Cart cleared.`);
      res.status(201).json(newOrder);
    } else if (paymentMethod === "momo") {
      // Tạo checkout trước
      const newCheckout = await Checkout.create({
        user: req.user._id,
        checkoutItem: checkoutItem,
        shippingAddress,
        paymentMethod,
        totalPrice,
        paymentStatus: "Đang xử lý",
        isPaid: false,
        orderCode: generateOrderCode(),
      });
      await Cart.findOneAndDelete({ user: req.user._id });
      console.log(`Checkout created for user ${req.user._id} với phương thức momo. Cart cleared.`);
      // Gọi MoMo để lấy payUrl
      const accessKey = "F8BBA842ECF85";
      const secretKey = "K951B6PE1waDMi640xX08PD3vg6EkVlz";
      const orderInfo = "pay with MoMo";
      const partnerCode = "MOMO";
      const redirectUrl = "https://webhook.site/b3088a6a-2d17-4f8d-a383-71389a6c600b";
      const ipnUrl = "https://burgerking-j92p.onrender.com/api/payment/momo/ipn";
      const requestType = "payWithMethod";
      const momoOrderId = newCheckout._id.toString();
      const requestId = momoOrderId;
      const extraData = "";
      const orderGroupId = "";
      const autoCapture = true;
      const lang = "vi";
      const rawSignature = `accessKey=${accessKey}&amount=${totalPrice}&extraData=${extraData}&ipnUrl=${ipnUrl}&orderId=${momoOrderId}&orderInfo=${orderInfo}&partnerCode=${partnerCode}&redirectUrl=${redirectUrl}&requestId=${requestId}&requestType=${requestType}`;
      const signature = crypto
        .createHmac("sha256", secretKey)
        .update(rawSignature)
        .digest("hex");
      const requestBody = JSON.stringify({
        partnerCode,
        partnerName: "Test",
        storeId: "MomoTestStore",
        requestId,
        amount: totalPrice,
        orderId: momoOrderId,
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
            res.status(201).json({
              ...newCheckout.toObject(),
              payUrl: result.payUrl,
            });
          } catch (e) {
            res.status(500).json({ message: "Lỗi parse response MoMo", detail: e.message });
          }
        });
      });
      momoReq.on("error", (e) => {
        res.status(500).json({ message: "Lỗi kết nối MoMo", detail: e.message });
      });
      momoReq.write(requestBody);
      momoReq.end();
    } else {
      // Các phương thức thanh toán khác: tạo Checkout như cũ
      let paymentStatus = "Đang xử lý";
      let isPaid = false;
      
      if (paymentMethod === "momo") {
        paymentStatus = "Đang xử lý";
        isPaid = false;
      }
      
      const newCheckout = await Checkout.create({
        user: req.user._id,
        checkoutItem: checkoutItem,
        shippingAddress,
        paymentMethod,
        totalPrice,
        paymentStatus,
        isPaid,
        orderCode: generateOrderCode(),
      });
      
      // Xóa giỏ hàng sau khi tạo checkout thành công
      await Cart.findOneAndDelete({ user: req.user._id });
      
      console.log(`Checkout created for user ${req.user._id} with payment method: ${paymentMethod}. Cart cleared.`);
      res.status(201).json(newCheckout);
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const updateCheckout = async (req, res) => {
  const { paymentStatus, paymentDetail } = req.body;
  try {
    const checkout = await Checkout.findById(req.params.id);
    if (!checkout) {
      return res.status(404).json({ message: "Checkout not found" });
    }

    if (paymentStatus === "Đã thanh toán") {
      checkout.isPaid = true;
      checkout.paymentStatus = paymentStatus;
      checkout.paymentDetail = paymentDetail;
      checkout.paidAt = Date.now();
      await checkout.save();
      res.status(200).json(checkout);
    } else {
      res.status(400).json({ message: "Invalid Payment Status" });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const finalizeCheckout = async (req, res) => {
  try {
    const checkout = await Checkout.findById(req.params.id);
    if (!checkout) {
      return res.status(404).json({ message: "Checkout not found" });
    }

    if (checkout.isPaid && !checkout.isFinalized) {
      const finalOrder = await Order.create({
        user: checkout.user,
        orderItems: checkout.checkoutItem,
        shippingAddress: checkout.shippingAddress,
        paymentMethod: checkout.paymentMethod,
        totalPrice: checkout.totalPrice,
        paymentStatus: "Đã thanh toán",
        isPaid: true,
        status: "Chờ xử lý",
        orderCode: checkout.orderCode,
        paidAt: checkout.paidAt,
      });

      checkout.isFinalized = true;
      checkout.finalizedAt = Date.now();
      await checkout.save();

      // Cập nhật purchaseCount cho từng sản phẩm
      for (const item of checkout.checkoutItem) {
        await Product.findByIdAndUpdate(
          item.productId,
          { $inc: { purchaseCount: item.quantity } },
          { new: true }
        );
      }

      res.status(200).json(finalOrder);
    } else if (checkout.isFinalized) {
      res.status(400).json({ message: "Checkout already finalized" });
    } else {
      res.status(400).json({ message: "Checkout not paid" });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getCheckoutById = async (req, res) => {
  try {
    const checkout = await Checkout.findById(req.params.id);
    if (!checkout) {
      return res.status(404).json({ message: "Checkout not found" });
    }
    res.json(checkout);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Hàm tạo mã đơn hàng dễ nhớ
const generateOrderCode = () => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let result = '';
  for (let i = 0; i < 6; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
};