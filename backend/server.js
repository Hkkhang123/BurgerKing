import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import path from "path";
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

dotenv.config();
const app = express();
app.use(express.json());
app.use(
  cors({ origin: "*", methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"] })
);
const port = process.env.PORT || 5000;
const __dirname = path.resolve();


app.get("/", (req, res) => {
  res.send("HELLO WORLD");
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

if (process.env.NODE_ENV === "production") {
  app.use(express.static(path.join(__dirname, "/client/build")));

  app.get("*", (req, res) => {
    res.sendFile(path.resolve(__dirname, "client", "build", "index.html"));
  });
}

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
  connectDB();
});

//ngrok.connect({ addr: port, authtoken_from_env: true, domain: "stirred-skink-live.ngrok-free.app" }).then(listener => console.log(`Ingress established at: ${listener.url()}`));