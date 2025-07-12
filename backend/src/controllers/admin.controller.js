import User from "../models/User.js";
import Product from "../models/Product.js";
import Order from "../models/Order.js";
import Checkout from "../models/Checkout.js";
export const getAllUsers = async (req, res) => {
  try {
    const user = await User.find({});
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const newUser = async (req, res) => {
  const { name, email, password, role } = req.body;
  try {
    let user = await User.findOne({ email });
    if (user) {
      return res.status(400).json({ message: "User already exists" });
    }
    user = new User({ name, email, password, role: role || "customer" });
    await user.save();
    res.status(201).json({ message: "User created successfully", user });
  } catch (error) {}
};

export const updateUser = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (user) {
      user.name = req.body.name || user.name;
      user.email = req.body.email || user.email;
      user.role = req.body.role || user.role;
    }
    const updateUser = await user.save();
    res
      .status(200)
      .json({ message: "User updated successfully", user: updateUser });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const deleteUser = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (user) {
      await user.deleteOne();
      res.status(200).json({ message: "User deleted successfully" });
    } else {
      res.status(404).json({ message: "User not found" });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getProducts = async (req, res) => {
  try {
    const products = await Product.find({});
    res.json(products);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getOrders = async (req, res) => {
  try {
    const orders = await Order.find({}).populate("user", "name email");
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};



export const deleteOrder = async (req, res) => {
    try {
        const order = await Order.findById(req.params.id);
        if (order) {    
            await order.deleteOne();
            res.status(200).json({ message: "Order deleted successfully" });
        } else {
            res.status(404).json({ message: "Order not found" });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
}

// Admin quản lý orders
export const getAllOrders = async (req, res) => {
  try {
    const orders = await Order.find({})
      .populate("user", "name email")
      .sort({ createdAt: -1 }); // Sắp xếp theo thời gian tạo mới nhất
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const updateOrder = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id).populate("user", "name email");
    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }

    const { paymentStatus, isPaid, status, isDelivered, note } = req.body;
    
    // Cập nhật trạng thái thanh toán
    if (paymentStatus) {
      order.paymentStatus = paymentStatus;
    }
    
    if (isPaid !== undefined) {
      order.isPaid = isPaid;
      if (isPaid && !order.paidAt) {
        order.paidAt = Date.now();
        // Cập nhật purchaseCount cho từng sản phẩm
        for (const item of order.orderItems) {
          await Product.findByIdAndUpdate(
            item.productId,
            { $inc: { purchaseCount: item.quantity } },
            { new: true }
          );
        }
      }
    }
    
    // Cập nhật trạng thái giao hàng
    if (status) {
      order.status = status;
    }
    
    if (isDelivered !== undefined) {
      order.isDelivered = isDelivered;
      if (isDelivered && !order.deliveredAt) {
        order.deliveredAt = Date.now();
      }
    }

    const updatedOrder = await order.save();
    
    console.log(`Admin ${req.user._id} updated order ${order._id} to payment: ${paymentStatus}, delivery: ${status}`);
    
    res.json({
      success: true,
      message: "Order updated successfully",
      order: updatedOrder
    });
  } catch (error) {
    console.log("Error updating order:", error);
    res.status(500).json({ message: error.message });
  }
};



export const confirmCashPayment = async (req, res) => {
  try {
    const { orderCode } = req.params;
    const { note } = req.body;
    
    // Tìm trong Order trước (thanh toán khi nhận hàng)
    let order = await Order.findOne({ orderCode });
    if (order) {
      if (order.paymentMethod !== "Thanh toán khi nhận hàng") {
        return res.status(400).json({ message: "This order is not for cash payment" });
      }
      
      if (order.isPaid) {
        return res.status(400).json({ message: "Order already paid" });
      }
      
      // Cập nhật trạng thái thanh toán
      order.paymentStatus = "Đã thanh toán";
      order.isPaid = true;
      order.paidAt = Date.now();
      
      // Cập nhật purchaseCount cho từng sản phẩm
      for (const item of order.orderItems) {
        await Product.findByIdAndUpdate(
          item.productId,
          { $inc: { purchaseCount: item.quantity } },
          { new: true }
        );
      }
      
      await order.save();
      
      console.log(`Admin ${req.user._id} confirmed cash payment for order ${orderCode}`);
      
      res.json({
        success: true,
        message: "Cash payment confirmed successfully",
        order: order
      });
      return;
    }
    
    // Nếu không tìm thấy trong Order, tìm trong Checkout
    const checkout = await Checkout.findOne({ orderCode });
    if (!checkout) {
      return res.status(404).json({ message: "Order not found" });
    }
    
    if (checkout.paymentMethod !== "Thanh toán khi nhận hàng") {
      return res.status(400).json({ message: "This order is not for cash payment" });
    }
    
    if (checkout.isPaid) {
      return res.status(400).json({ message: "Order already paid" });
    }
    
    // Cập nhật trạng thái thanh toán
    checkout.paymentStatus = "Đã thanh toán";
    checkout.isPaid = true;
    checkout.paymentDetail = {
      method: "Cash on Delivery",
      amount: checkout.totalPrice,
      confirmedAt: new Date(),
      confirmedBy: req.user._id,
      note: note || "Admin confirmed cash payment"
    };
    checkout.paidAt = Date.now();
    await checkout.save();
    
    console.log(`Admin ${req.user._id} confirmed cash payment for checkout ${orderCode}`);
    
    res.json({
      success: true,
      message: "Cash payment confirmed successfully",
      checkout: checkout
    });
    
  } catch (error) {
    console.log("Error confirming cash payment:", error);
    res.status(500).json({ message: error.message });
  }
};

// Admin quản lý checkout
export const getCheckouts = async (req, res) => {
  try {
    const checkouts = await Checkout.find({})
      .populate("user", "name email")
      .sort({ createdAt: -1 }); // Sắp xếp theo thời gian tạo mới nhất
    res.json(checkouts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const updateCheckout = async (req, res) => {
  try {
    const checkout = await Checkout.findById(req.params.id).populate("user", "name email");
    if (!checkout) {
      return res.status(404).json({ message: "Checkout not found" });
    }

    const { paymentStatus, isPaid, note } = req.body;
    
    // Cập nhật trạng thái thanh toán
    if (paymentStatus) {
      checkout.paymentStatus = paymentStatus;
    }
    
    if (isPaid !== undefined) {
      checkout.isPaid = isPaid;
      if (isPaid && !checkout.paidAt) {
        checkout.paidAt = Date.now();
        checkout.paymentDetail = {
          method: "Admin Update",
          amount: checkout.totalPrice,
          confirmedAt: new Date(),
          confirmedBy: req.user._id,
          note: note || "Admin confirmed payment"
        };
      }
    }

    const updatedCheckout = await checkout.save();
    
    console.log(`Admin ${req.user._id} updated checkout ${checkout._id} to ${paymentStatus}, isPaid: ${isPaid}`);
    
    res.json({
      success: true,
      message: "Checkout updated successfully",
      checkout: updatedCheckout
    });
  } catch (error) {
    console.log("Error updating checkout:", error);
    res.status(500).json({ message: error.message });
  }
};

export const getCheckoutById = async (req, res) => {
  try {
    const checkout = await Checkout.findById(req.params.id)
      .populate("user", "name email");
    if (!checkout) {
      return res.status(404).json({ message: "Checkout not found" });
    }
    res.json(checkout);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
