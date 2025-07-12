import express from "express";
import { protectRoutes, isAdmin } from "../middleware/auth.middleware.js";
import { 
  deleteOrder, 
  deleteUser, 
  getAllUsers, 
  getOrders, 
  getProducts, 
  newUser, 
  updateOrder, 
  updateUser,
  getCheckouts,
  updateCheckout,
  confirmCashPayment,
  getCheckoutById
} from "../controllers/admin.controller.js";

const router = express.Router();

//user
router.get("/", protectRoutes, isAdmin, getAllUsers)
router.post("/", protectRoutes, isAdmin, newUser)
router.put("/:id", protectRoutes, isAdmin, updateUser)
router.delete("/:id", protectRoutes, isAdmin, deleteUser)

//product
router.get("/product", protectRoutes, isAdmin, getProducts)

//order
router.get("/order", protectRoutes, isAdmin, getOrders)
router.put("/order/:id", protectRoutes, isAdmin, updateOrder)
router.delete("/order/:id", protectRoutes, isAdmin, deleteOrder)

//checkout
router.get("/checkout", protectRoutes, isAdmin, getCheckouts)
router.get("/checkout/:id", protectRoutes, isAdmin, getCheckoutById)
router.put("/checkout/:id", protectRoutes, isAdmin, updateCheckout)
router.post("/checkout/confirm-cash/:orderCode", protectRoutes, isAdmin, confirmCashPayment)

export default router;