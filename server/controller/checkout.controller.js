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
    const newCheckout = await Checkout.create({
      user: req.user._id,
      checkoutItem: checkoutItem,
      shippingAddress,
      paymentMethod,
      totalPrice,
      paymentStatus: "Đang xử lý",
      isPaid: false,
    });
    console.log(`Checkout created:  ${req.user._id}`);
    res.status(201).json(newCheckout);
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
