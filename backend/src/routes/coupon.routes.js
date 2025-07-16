import express from "express";
import { protectRoutes } from "../middleware/auth.middleware.js";
import { getAllCoupons, getCouponByCode } from "../controllers/coupon.controller.js";

const router = express.Router();

// Lấy danh sách tất cả coupon (có thể thêm protectRoutes nếu cần admin)
router.get("/", getAllCoupons);

// Kiểm tra và lấy thông tin mã giảm giá theo code
router.get("/:code", getCouponByCode);

export default router;
