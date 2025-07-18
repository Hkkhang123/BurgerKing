import express from "express";
import {
  getNotifications,
  createNotification,
  sendCustomNotification,
  markAllAsRead,
  deleteAllNotifications
} from "../controllers/notification.controller.js";
import { protectRoutes } from "../middleware/auth.middleware.js";

const router = express.Router();

// Lấy danh sách thông báo
router.get("/", protectRoutes, getNotifications);

// Tạo thông báo mới cho user cụ thể
router.post("/", protectRoutes, createNotification);

// Gửi thông báo tùy chỉnh đến tất cả user (Observer)
router.post("/send", protectRoutes, sendCustomNotification);

// Đánh dấu tất cả thông báo là đã đọc
router.post("/mark-all-read", protectRoutes, markAllAsRead);

// Xóa tất cả thông báo
router.delete("/delete-all", protectRoutes, deleteAllNotifications);

export default router;
