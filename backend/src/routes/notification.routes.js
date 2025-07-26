import express from "express";
import {
  getNotifications,
  getAllNotifications,
  createNotification,
  sendCustomNotification,
  markAllAsRead,
  deleteAllNotifications,
  checkNotificationsCount
} from "../controllers/notification.controller.js";
import { protectRoutes, isAdmin } from "../middleware/auth.middleware.js";

const router = express.Router();

// Lấy danh sách thông báo của user
router.get("/", protectRoutes, getNotifications);

// Lấy tất cả thông báo (cho admin)
router.get("/all", protectRoutes, isAdmin, getAllNotifications);

// Tạo thông báo mới cho user cụ thể
router.post("/", protectRoutes, createNotification);

// Gửi thông báo tùy chỉnh đến tất cả user (Observer)
router.post("/send", protectRoutes, sendCustomNotification);

// Đánh dấu tất cả thông báo là đã đọc
router.put("/mark-read", protectRoutes, markAllAsRead);

// Xóa tất cả thông báo của user
router.delete("/", protectRoutes, deleteAllNotifications);

// Kiểm tra số lượng notifications của tất cả users (cho admin)
router.get("/count", protectRoutes, isAdmin, checkNotificationsCount);

export default router;
