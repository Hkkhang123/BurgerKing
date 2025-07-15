import Notification from "../models/Notification.js";

// Lấy danh sách thông báo của user
export const getNotifications = async (req, res) => {
  try {
    const userId = req.user._id; // Lấy từ middleware xác thực
    const notifications = await Notification.find({ user: userId }).sort({ createdAt: -1 });
    res.json(notifications);
  } catch (e) {
    res.status(500).json({ message: "Server error", error: e.message });
  }
};

// Thêm thông báo mới
export const createNotification = async (req, res) => {
  try {
    const { user, title, message } = req.body;
    const notification = await Notification.create({ user, title, message });
    res.status(201).json(notification);
  } catch (e) {
    res.status(500).json({ message: "Server error", error: e.message });
  }
};

// Đánh dấu tất cả là đã đọc
export const markAllAsRead = async (req, res) => {
  try {
    const userId = req.user._id;
    await Notification.updateMany({ user: userId, isRead: false }, { isRead: true });
    res.json({ message: "All notifications marked as read" });
  } catch (e) {
    res.status(500).json({ message: "Server error", error: e.message });
  }
}; 