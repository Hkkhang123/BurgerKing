import express from "express";
import {
  getNotifications,
  getAllNotifications,
  createNotification,
  createTestNotification,
  testOrderNotification,
  checkAdminUsers,
  sendCustomNotification,
  markAllAsRead,
  deleteAllNotifications
} from "../controllers/notification.controller.js";
import { protectRoutes, isAdmin } from "../middleware/auth.middleware.js";

const router = express.Router();

// Lấy danh sách thông báo của user
router.get("/", protectRoutes, getNotifications);

// Lấy tất cả thông báo (cho admin)
router.get("/all", protectRoutes, isAdmin, getAllNotifications);

// Kiểm tra admin users
router.get("/check-admins", protectRoutes, isAdmin, checkAdminUsers);

// Tạo thông báo mới cho user cụ thể
router.post("/", protectRoutes, createNotification);

// Tạo thông báo test cho admin
router.post("/test", protectRoutes, isAdmin, createTestNotification);

// Test tạo thông báo đơn hàng mới
router.post("/test-order", protectRoutes, isAdmin, testOrderNotification);

// Gửi thông báo tùy chỉnh đến tất cả user (Observer)
router.post("/send", protectRoutes, sendCustomNotification);

// Đánh dấu tất cả thông báo là đã đọc
router.put("/mark-read", protectRoutes, markAllAsRead);

// Xóa tất cả thông báo của user
router.delete("/", protectRoutes, deleteAllNotifications);

export default router;
