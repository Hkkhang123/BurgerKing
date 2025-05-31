import User from "../models/User.js";
import Product from "../models/Product.js";
import Order from "../models/Order.js";
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

export const updateOrder = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id).populate("user", "name");
    if (order) {
      order.status = req.body.status || order.status;
      order.isDelivered =
        req.body.status === "Đã giao hàng" ? true : order.isDelivered;
      order.deliveredAt =
        req.body.status === "Đã giao hàng" ? Date.now() : order.deliveredAt;
      const updatedOrder = await order.save();
      res.json(updatedOrder);
    } else {
      res.status(404).json({ message: "Order not found" });
    }
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
