import express from "express";
import { protectRoutes } from "../middleware/auth.middleware.js";
import { getOrders, myOrder, reorderOrder } from "../controllers/order.controller.js";

const router = express.Router();

// ---- TEST ROUTES (debug) ----
router.get("/debug/test", (req, res) => {
  res.json({ message: "GET /debug/test is working!" });
});

router.post("/debug/test", (req, res) => {
  res.json({ message: "POST /debug/test is working!" });
});

// ---- CÁC ROUTES CHÍNH ----
router.get("/my-order", protectRoutes, myOrder);
router.post("/:id/reorder", protectRoutes, reorderOrder);
router.get("/:id", protectRoutes, getOrders);

export default router;
