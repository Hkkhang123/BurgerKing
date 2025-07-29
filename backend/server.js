
import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import path from "path";
import fs from "fs";
import ngrok from "@ngrok/ngrok";

import { connectDB } from "./src/config/db.js";
import authRoutes from "./src/routes/auth.routes.js";
import productRoutes from "./src/routes/product.routes.js";
import cartRoutes from "./src/routes/cart.routes.js";
import checkoutRoutes from "./src/routes/checkout.routes.js";
import orderRoutes from "./src/routes/order.routes.js";
import uploadRoutes from "./src/config/uploadRoute.js";
import adminRoutes from "./src/routes/admin.routes.js";
import paymentRoutes from "./src/routes/payment.routes.js";
import notificationRoutes from "./src/routes/notification.routes.js";
import couponRoutes from "./src/routes/coupon.routes.js";
import shippingRoutes from "./src/routes/shipping.routes.js";


dotenv.config();
const app = express();
app.use(express.json());

// CORS configuration
const corsOptions = {
  origin: process.env.NODE_ENV === 'production' 
  ? [
      "https://burgerking-j92p.onrender.com",
      "https://burger-king-omega-three.vercel.app",
      "http://localhost:5173" // Thêm dòng này để cho phép truy cập từ local
    ]
  : true, // Allow all origins in development
  credentials: true,
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization", "ngrok-skip-browser-warning"]
};

app.use(cors(corsOptions));

// Handle preflight requests
app.options('*', cors(corsOptions));
const port = process.env.PORT || 5000;
const __dirname = path.resolve();


app.get("/", (req, res) => {
  res.send("HELLO WORLD - Backend API Server");
});

app.use("/api/auth", authRoutes);
app.use("/api/products", productRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/checkout", checkoutRoutes);
app.use("/api/order", orderRoutes);
app.use("/api/upload", uploadRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/payment", paymentRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/coupons", couponRoutes);

app.use("/api/shipping", shippingRoutes);

// Chỉ serve static files nếu thư mục client/build tồn tại
if (process.env.NODE_ENV === "production") {
  const clientBuildPath = path.join(__dirname, "/client/build");
  
  try {
    // Kiểm tra xem thư mục client/build có tồn tại không
    if (fs.existsSync(clientBuildPath)) {
      app.use(express.static(clientBuildPath));
      
      app.get("*", (req, res) => {
        res.sendFile(path.resolve(__dirname, "client", "build", "index.html"));
      });
      console.log("✅ Serving static files from client/build");
    } else {
      console.log("⚠️ Client build directory not found, serving API only");
      // Nếu không có client build, chỉ serve API
      app.get("*", (req, res) => {
        res.json({ 
          message: "Backend API Server", 
          status: "running",
          endpoints: [
            "/api/auth",
            "/api/products", 
            "/api/cart",
            "/api/checkout",
            "/api/order",
            "/api/admin",
            "/api/payment",
            "/api/notifications",
            "/api/coupons"
          ]
        });
      });
    }
  } catch (error) {
    console.log("⚠️ Error checking client build directory:", error.message);
    // Fallback: chỉ serve API
    app.get("*", (req, res) => {
      res.json({ 
        message: "Backend API Server", 
        status: "running",
        error: "Static files not available"
      });
    });
  }
}

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
  connectDB();
});

//ngrok.connect({ addr: port, authtoken_from_env: true, domain: "stirred-skink-live.ngrok-free.app" }).then(listener => console.log(`Ingress established at: ${listener.url()}`));
