import express from "express";
import { getNotifications, createNotification, markAllAsRead } from "../controllers/notification.controller.js";
import { verifyToken } from "../middleware/auth.middleware.js";

const router = express.Router();

router.get("/", verifyToken, getNotifications);
router.post("/", createNotification); // Có thể cần verifyToken nếu chỉ cho phép user đã đăng nhập
router.post("/mark-all-read", verifyToken, markAllAsRead);

export default router; 