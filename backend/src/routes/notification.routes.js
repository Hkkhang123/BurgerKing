import express from "express";
import { getNotifications, createNotification, markAllAsRead } from "../controllers/notification.controller.js";
import { protectRoutes } from "../middleware/auth.middleware.js";

const router = express.Router();

router.get("/", protectRoutes, getNotifications);
router.post("/", createNotification); // Có thể cần verifyToken nếu chỉ cho phép user đã đăng nhập
router.post("/mark-all-read", protectRoutes, markAllAsRead);

export default router; 