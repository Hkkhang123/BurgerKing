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
import multer from "multer";

const router = express.Router();

// Cấu hình multer cho upload files
const storage = multer.memoryStorage();
const upload = multer({ 
  storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Chỉ cho phép upload file hình ảnh!'), false);
    }
  }
});

// Route tạo sản phẩm với URL images (không có file upload)
router.post("/", protectRoutes, isAdmin, createProducts);

// Route tạo sản phẩm với single file upload
router.post("/with-image", protectRoutes, isAdmin, upload.single('image'), createProducts);

// Route tạo sản phẩm với multiple files upload
router.post("/with-images", protectRoutes, isAdmin, upload.array('images', 10), createProducts);

router.put("/:id", protectRoutes, isAdmin, updateProduct);
router.delete("/:id", protectRoutes, isAdmin, deleteProduct);
router.get("/", getProducts);
router.get("/best-seller", getBestSellerProducts); 
router.get("/new-arrival", getNewArrivalProducts)
router.get("/:id", getProductById);
router.get("/similar/:id", getSimilarProducts);

export default router;
