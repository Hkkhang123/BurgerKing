import Order from "../models/Order.js";
import Cart from "../models/Cart.js";
import Product from "../models/Product.js";


export const myOrder = async (req, res) => {
    try {
        const orders = await Order.find({user: req.user._id}).sort({createdAt: -1});
        res.json(orders);
    } catch (error) {
        res.status(500).json({message: error.message})
    }
}

export const getOrders = async (req, res) => {
    try {
        const order = await Order.findById(req.params.id).populate("user", "name email");
        if (!order) {
            return res.status(404).json({message: "Order not found"});
        }
        res.json(order);
    } catch (error) {
        res.status(500).json({message: error.message})
    }
}

export const reorderOrder = async (req, res) => {
  try {
    const orderId = req.params.id;
    const order = await Order.findById(orderId);
    if (!order) return res.status(404).json({ message: "Order not found" });

    // Logic copy sản phẩm từ order vào cart
    for (const item of order.orderItems) {
      await Cart.create({
        user: req.user._id,
        product: item.productId,
        quantity: item.quantity,
      });
    }

    res.json({ message: "Reorder success" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

