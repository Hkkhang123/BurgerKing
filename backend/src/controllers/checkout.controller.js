import Cart from "../models/Cart.js";
import Product from "../models/Product.js";
import Order from "../models/Order.js";
import Checkout from "../models/Checkout.js";
import { createMomoPayment } from "../services/momo.service.js";

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
      console.log(`Checkout created for user ${req.user._id} with payment method: ${paymentMethod}. Cart cleared.`);
      // Gọi MoMo để lấy payUrl
      try {
        const momoRes = await createMomoPayment({
          checkoutId: newCheckout._id.toString(),
          amount: totalPrice,
        });
        res.status(201).json({
          ...newCheckout.toObject(),
          payUrl: momoRes.payUrl,
        });
      } catch (momoError) {
        res.status(500).json({ message: "Lỗi tạo thanh toán MoMo", detail: momoError.message });
      }
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




