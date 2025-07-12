import Checkout from "../models/Checkout.js";
import Cart from "../models/Cart.js";
import Product from "../models/Product.js";
import Order from "../models/Order.js";

export const createCheckout = async (req, res) => {
  const { checkoutItem, shippingAddress, paymentMethod, totalPrice } = req.body;
  if (!checkoutItem || checkoutItem.length === 0) {
    return res.status(400).json({ message: "No item in checkout" });
  }
  try {
    // Xử lý trạng thái thanh toán dựa trên phương thức thanh toán
    let paymentStatus = "Đang xử lý";
    let isPaid = false;
    
    if (paymentMethod === "Thanh toán khi nhận hàng") {
      paymentStatus = "Chờ thanh toán";
      isPaid = false;
    } else if (paymentMethod === "Thanh toán MoMo") {
      paymentStatus = "Đang xử lý";
      isPaid = false;
    } else if (paymentMethod === "Chuyển khoản ngân hàng") {
      paymentStatus = "Chờ xác nhận";
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
      orderCode: generateOrderCode(), // Tạo mã đơn hàng dễ nhớ
    });
    
    console.log(`Checkout created for user ${req.user._id} with payment method: ${paymentMethod}`);
    res.status(201).json(newCheckout);
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
      res.status(400).json({ message: "Ivalid Payment Status" });
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
        paidAt: checkout.paidAt,
        isDelivered: false,
        paymentDetail: checkout.paymentDetail,
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

      await Cart.findOneAndDelete({ user: checkout.user });
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

// Thêm hàm lấy checkout theo ID
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


