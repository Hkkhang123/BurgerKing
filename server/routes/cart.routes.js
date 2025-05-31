import express from "express";
import { protectRoutes } from "../middleware/auth.middleware.js";
import { addToCart, deleteCart, getCart, mergeCart, updateCart } from "../controller/cart.controller.js";

const router = express.Router();

router.post("/", addToCart)
router.put("/", updateCart)
router.delete("/", deleteCart)
router.get("/", getCart) 
router.post("/merge", protectRoutes, mergeCart)
export default router