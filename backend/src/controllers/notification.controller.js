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

// Tạo thông báo cho một user cụ thể
export const createNotification = async (req, res) => {
  try {
    const { user, title, message } = req.body;
    const notification = await Notification.create({ user, title, message });
    res.status(201).json(notification);
  } catch (e) {
    res.status(500).json({ message: "Server error", error: e.message });
  }
};

// Kiểm tra admin users
export const checkAdminUsers = async (req, res) => {
  try {
    const adminUsers = await User.find({ role: 'admin' });
    const allUsers = await User.find({});
    
    console.log(`[checkAdminUsers] Tổng users: ${allUsers.length}`);
    console.log(`[checkAdminUsers] Admin users: ${adminUsers.length}`);
    console.log(`[checkAdminUsers] All users:`, allUsers.map(u => ({ id: u._id, name: u.name, email: u.email, role: u.role })));
    
    res.json({
      totalUsers: allUsers.length,
      adminUsers: adminUsers.length,
      admins: adminUsers.map(u => ({ id: u._id, name: u.name, email: u.email, role: u.role })),
      allUsers: allUsers.map(u => ({ id: u._id, name: u.name, email: u.email, role: u.role }))
    });
  } catch (e) {
    console.log("[checkAdminUsers] Lỗi:", e.message);
    res.status(500).json({ message: "Server error", error: e.message });
  }
};

// Tạo thông báo test cho admin
export const createTestNotification = async (req, res) => {
  try {
    // Tìm tất cả admin users
    const adminUsers = await User.find({ role: 'admin' });
    console.log(`[createTestNotification] Tìm thấy ${adminUsers.length} admin users`);
    console.log(`[createTestNotification] Admin users:`, adminUsers.map(u => ({ id: u._id, name: u.name, email: u.email, role: u.role })));
    
    if (adminUsers.length === 0) {
      return res.status(404).json({ message: "Không tìm thấy admin nào" });
    }

    // Tạo thông báo test cho mỗi admin
    const testNotifications = [];
    for (const admin of adminUsers) {
      const notification = await Notification.create({
        user: admin._id,
        title: "Thông báo test",
        message: `Đây là thông báo test cho admin ${admin.name} - ${new Date().toLocaleString('vi-VN')}`,
      });
      testNotifications.push(notification);
      console.log(`[createTestNotification] Đã tạo thông báo test cho admin ${admin.name}`);
    }

    console.log(`[createTestNotification] Đã tạo ${testNotifications.length} thông báo test`);
    res.status(201).json({ 
      message: `Đã tạo ${testNotifications.length} thông báo test`,
      notifications: testNotifications 
    });
  } catch (e) {
    console.log("[createTestNotification] Lỗi:", e.message);
    res.status(500).json({ message: "Server error", error: e.message });
  }
};

// Gửi thông báo tùy chỉnh cho tất cả user (dùng Observer)
export const sendCustomNotification = async (req, res) => {
  try {
    const { title, message } = req.body;
    if (!title || !message) {
      return res.status(400).json({ message: "Thiếu title hoặc message" });
    }

    const customNotificationSubject = new Subject();
    const users = await User.find({});

    users.forEach(user => {
      customNotificationSubject.subscribe(new NotificationObserver(user._id));
    });

    await customNotificationSubject.notify({ title, message });

    res.status(200).json({ message: "Đã gửi thông báo tùy chỉnh (Observer)" });
  } catch (e) {
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

