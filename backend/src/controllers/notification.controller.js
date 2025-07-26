import Notification from "../models/Notification.js";
import User from "../models/User.js";
import { Subject } from "../config/observer.js";
import NotificationObserver from "../config/notificationobserver.js";

// Lấy danh sách thông báo của user
export const getNotifications = async (req, res) => {
  try {
    const userId = req.user._id;
    const notifications = await Notification.find({ user: userId }).sort({ createdAt: -1 });
    res.json(notifications);
  } catch (e) {
    res.status(500).json({ message: "Server error", error: e.message });
  }
};

// Lấy tất cả thông báo (cho admin)
export const getAllNotifications = async (req, res) => {
  try {
    console.log("[getAllNotifications] Đang lấy tất cả thông báo...");
    const notifications = await Notification.find({})
      .populate('user', 'name email')
      .sort({ createdAt: -1 });
    
    console.log(`[getAllNotifications] Tìm thấy ${notifications.length} thông báo`);
    res.json(notifications);
  } catch (e) {
    console.log("[getAllNotifications] Lỗi:", e.message);
    res.status(500).json({ message: "Server error", error: e.message });
  }
};

// Tạo thông báo mới cho user cụ thể
export const createNotification = async (req, res) => {
  try {
    const { user, title, message } = req.body;
    const notification = await Notification.create({
      user,
      title,
      message,
    });
    res.status(201).json(notification);
  } catch (e) {
    res.status(500).json({ message: "Server error", error: e.message });
  }
};

// Gửi thông báo tùy chỉnh đến tất cả user (Observer)
export const sendCustomNotification = async (req, res) => {
  try {
    const { title, message } = req.body;
    console.log(`[sendCustomNotification] Bắt đầu gửi thông báo: "${title}" - "${message}"`);
    
    // Lấy tất cả users (trừ admin)
    const users = await User.find({ role: { $ne: 'admin' } });
    console.log(`[sendCustomNotification] Tìm thấy ${users.length} users để gửi thông báo`);
    
    // Tạo thông báo cho mỗi user
    const notifications = [];
    for (const user of users) {
      console.log(`[sendCustomNotification] Đang tạo notification cho user: ${user.email} (${user._id})`);
      const notification = await Notification.create({
        user: user._id,
        title,
        message,
        isRead: false,
        createdAt: new Date()
      });
      notifications.push(notification);
      console.log(`[sendCustomNotification] Đã tạo notification: ${notification._id} cho user: ${user.email}`);
    }
    
    console.log(`[sendCustomNotification] Hoàn thành! Đã tạo ${notifications.length} notifications`);
    
    // Trả về notification đầu tiên để frontend có thể thêm vào state
    const firstNotification = notifications[0];
    res.status(201).json(firstNotification);
  } catch (e) {
    console.log('sendCustomNotification error:', e.message);
    res.status(500).json({ message: "Server error", error: e.message });
  }
};

// Đánh dấu tất cả thông báo là đã đọc
export const markAllAsRead = async (req, res) => {
  try {
    const userId = req.user._id;
    await Notification.updateMany(
      { user: userId, isRead: false },
      { isRead: true }
    );
    res.json({ message: "All notifications marked as read" });
  } catch (e) {
    res.status(500).json({ message: "Server error", error: e.message });
  }
};

// Xóa tất cả thông báo của user
export const deleteAllNotifications = async (req, res) => {
  try {
    const userId = req.user._id;
    await Notification.deleteMany({ user: userId });
    res.json({ message: "All notifications deleted" });
  } catch (e) {
    res.status(500).json({ message: "Server error", error: e.message });
  }
};

// Kiểm tra số lượng notifications của tất cả users (cho admin)
export const checkNotificationsCount = async (req, res) => {
  try {
    const notifications = await Notification.find({}).populate('user', 'name email role');
    
    // Nhóm theo user
    const userNotificationCounts = {};
    notifications.forEach(notification => {
      const userEmail = notification.user.email;
      if (!userNotificationCounts[userEmail]) {
        userNotificationCounts[userEmail] = {
          total: 0,
          unread: 0,
          user: notification.user
        };
      }
      userNotificationCounts[userEmail].total++;
      if (!notification.isRead) {
        userNotificationCounts[userEmail].unread++;
      }
    });
    
    res.json({
      totalNotifications: notifications.length,
      userCounts: userNotificationCounts
    });
  } catch (e) {
    console.log('checkNotificationsCount error:', e.message);
    res.status(500).json({ message: "Server error", error: e.message });
  }
};

