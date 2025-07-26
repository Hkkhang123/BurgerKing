import express from "express";
import { 
  dangky, 
  dangNhap, 
  getProfile, 
  uploadAvatar, 
  loginWithGoogle, 
  updateProfile, 
  forgotPassword, 
  resetPassword, 
  loginWithFacebook, 
  getAddresses, 
  addAddress, 
  updateAddress, 
  deleteAddress,
  sendLoginOtp,
  verifyLoginOtp,
  sendSignupOtp,
  registerWithOtp
} from "../controllers/auth.controller.js";
import { protectRoutes } from "../middleware/auth.middleware.js";

const router = express.Router();

router.post("/dangky",dangky)
router. post("/dangnhap",dangNhap)
router.get("/profile", protectRoutes, getProfile)
router.post("/avatar", protectRoutes, uploadAvatar)
router.post("/google", loginWithGoogle)
router.post("/facebook", loginWithFacebook);
router.put("/profile", protectRoutes, updateProfile);
router.post("/forgot-password", forgotPassword);
router.post("/reset-password", resetPassword);

// OTP Authentication
router.post("/send-login-otp", sendLoginOtp);
router.post("/verify-login-otp", verifyLoginOtp);
router.post("/send-signup-otp", sendSignupOtp);
router.post("/register-with-otp", registerWithOtp);

// Địa chỉ giao hàng
router.get("/addresses", protectRoutes, getAddresses);
router.post("/addresses", protectRoutes, addAddress);
router.put("/addresses/:addressId", protectRoutes, updateAddress);
router.delete("/addresses/:addressId", protectRoutes, deleteAddress);

export default router;