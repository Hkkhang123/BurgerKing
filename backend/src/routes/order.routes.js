import express from "express";
import { protectRoutes } from "../middleware/auth.middleware.js";
import { getOrders, myOrder } from "../controllers/order.controller.js";

const router = express.Router();

router.get("/my-order", protectRoutes, myOrder)
router.get("/:id", protectRoutes, getOrders)

export default router;