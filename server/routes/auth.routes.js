import express from "express";
import { dangky, dangNhap, getProfile } from "../controller/auth.controller.js";
import { protectRoutes } from "../middleware/auth.middleware.js";


const router = express.Router();

router.post("/dangky",dangky)
router. post("/dangnhap",dangNhap)
router.get("/profile", protectRoutes, getProfile)

export default router