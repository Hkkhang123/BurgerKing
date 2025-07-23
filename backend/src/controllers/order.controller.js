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
    const { id } = req.params; // ID của order
    const userId = req.user.id; // User từ middleware bảo vệ route

    console.log('[Reorder] Start', { orderId: id, userId });

    // 1. Kiểm tra order
    const order = await Order.findOne({ _id: id, user: userId });
    if (!order) {
      console.log('[Reorder] Order not found');
      return res.status(404).json({ message: "Order not found" });
    }

    // 2. Lấy danh sách orderItems
    const items = order.orderItems || [];
    console.log('[Reorder] Order items:', items);

    if (items.length === 0) {
      console.log('[Reorder] No products in order');
      return res.status(400).json({ message: "No products in order" });
    }

    // 3. Lấy hoặc tạo giỏ hàng cho user
    let cart = await Cart.findOne({ user: userId });
    if (!cart) {
      console.log('[Reorder] No cart found, creating new');
      cart = await Cart.create({ user: userId, products: [], totalPrice: 0 });
    }

    // 4. Duyệt từng sản phẩm trong orderItems
    for (const item of items) {
      console.log(`[Reorder] Processing item: ${item.name} (${item.productId})`);

      // Kiểm tra sản phẩm tồn tại trong DB
      const product = await Product.findById(item.productId);
      if (!product) {
        console.warn(`[Reorder] Product not found: ${item.productId}`);
        continue;
      }

      // Kiểm tra nếu sản phẩm đã có trong giỏ hàng
      const existingItem = cart.products.find(
        (p) => p.productId.toString() === product._id.toString()
      );

      if (existingItem) {
        console.log(`[Reorder] Product exists in cart, increasing quantity`);
        existingItem.quantity += item.quantity;
      } else {
        console.log(`[Reorder] Adding new product to cart`);
        cart.products.push({
          productId: product._id,
          name: product.name,
          price: product.price,
          image: product.image,
          quantity: item.quantity,
        });
      }
    }

    // 5. Cập nhật tổng tiền
    cart.totalPrice = cart.products.reduce(
      (sum, p) => sum + p.price * p.quantity,
      0
    );

    await cart.save();

    console.log('[Reorder] Success, final cart:', cart);
    return res.status(200).json({ message: "Reorder success", cart });
  } catch (error) {
    console.error('[Reorder] Error:', error);
    return res.status(500).json({ message: "Server error" });
  }
};
