import mongoose from "mongoose";
import dotenv from "dotenv";
import Product from "./models/Product.js";
import User from "./models/User.js";
import products from "./data/products.js";

dotenv.config();

mongoose.connect(process.env.MONGO_URL);

const seedData = async () => {
  try {
    // Xóa dữ liệu cũ
    await Product.deleteMany();
    await User.deleteMany();

    // Tạo user admin mẫu
    const createdUser = await User.create({
      name: "Admin User",
      email: "admin@example.com",
      password: "123456",
      role: "admin",
    });

    const userId = createdUser._id;
    
    // Tạo products với userId
    const sample = products.map((product) => {
      return {
        ...product, 
        user: userId,
      };
    });

    await Product.insertMany(sample);

    console.log("✅ Data imported successfully!");
    console.log(`📦 Created ${sample.length} products`);
    console.log(`👤 Created admin user: ${createdUser.email} (password: 123456)`);
    console.log(`🔗 User ID: ${userId}`);
    process.exit();
  } catch (error) {
    console.error("❌ Error seeding data:", error);
    process.exit(1);
  }
};

seedData();