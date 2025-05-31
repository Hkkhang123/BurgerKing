import express from "express";
import { isAdmin, protectRoutes } from "../middleware/auth.middleware.js";
import {
  createProducts,
  deleteProduct,
  getBestSellerProducts,
  getNewArrivalProducts,
  getProductById,
  getProducts,
  getSimilarProducts,
  updateProduct,
} from "../controller/product.controller.js";

const router = express.Router();

router.post("/", protectRoutes, isAdmin, createProducts);
router.put("/:id", protectRoutes, isAdmin, updateProduct);
router.delete("/:id", protectRoutes, isAdmin, deleteProduct);
router.get("/", getProducts);
router.get("/best-seller", getBestSellerProducts); 
router.get("/new-arrival", getNewArrivalProducts)
router.get("/:id", getProductById);
router.get("/similar/:id", getSimilarProducts);

export default router;
