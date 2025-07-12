import express from "express";
import { protectRoutes } from "../middleware/auth.middleware.js";
import { 
  createCheckout, 
  finalizeCheckout, 
  updateCheckout, 
  getCheckoutById
} from "../controllers/checkout.controller.js";

const router = express.Router();

router.post("/", protectRoutes, createCheckout)
router.get("/:id", protectRoutes, getCheckoutById)
router.put("/:id/pay", protectRoutes, updateCheckout)
router.post("/:id/finalize", protectRoutes, finalizeCheckout)

export default router;