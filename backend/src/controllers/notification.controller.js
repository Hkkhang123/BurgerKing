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
    await Notification.updateMany({ user: userId, isRead: false }, { isRead: true });
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