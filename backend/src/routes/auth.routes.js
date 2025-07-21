import express from "express";
import { dangky, dangNhap, getProfile, uploadAvatar, loginWithGoogle, updateProfile, forgotPassword, resetPassword } from "../controllers/auth.controller.js";
import { protectRoutes } from "../middleware/auth.middleware.js";

const router = express.Router();

router.post("/dangky",dangky)
router. post("/dangnhap",dangNhap)
router.get("/profile", protectRoutes, getProfile)
router.post("/avatar", protectRoutes, uploadAvatar)
router.post("/google", loginWithGoogle)
router.put("/profile", protectRoutes, updateProfile);
router.post("/forgot-password", forgotPassword);
router.post("/reset-password", resetPassword);

export default router;