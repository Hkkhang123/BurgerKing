import express from "express";
import { protectRoutes } from "../middleware/auth.middleware.js";
import { addToCart, deleteCart, getCart, mergeCart, updateCart } from "../controller/cart.controller.js";

const router = express.Router();

router.post("/", protectRoutes, addToCart)
router.put("/", protectRoutes, updateCart)
router.delete("/", protectRoutes, deleteCart)
router.get("/", protectRoutes, getCart) 
router.post("/merge", protectRoutes, mergeCart)

export default router;