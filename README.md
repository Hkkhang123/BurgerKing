# Pizza App - Flutter + Node.js

Ứng dụng đặt pizza được xây dựng với Flutter cho client và Node.js cho server.

## 📋 Yêu cầu hệ thống

- **Node.js** (v16 trở lên)
- **Flutter** (v3.0 trở lên)
- **MongoDB** (local hoặc cloud)
- **Git**

## 🚀 Cài đặt và Khởi chạy

### 1. Clone Repository

```bash
git clone <repository-url>
cd Pizza
```

### 2. Cài đặt Environment Variables

#### Server Environment (.env)

Tạo file `.env` trong thư mục `server/`:

```bash
cd server
cp .env.example .env
```

Hoặc tạo file `.env` mới với nội dung:

```env
# Database Configuration
MONGODB_URI=mongodb://localhost:27017/pizza_app
# Hoặc MongoDB Atlas: mongodb+srv://username:password@cluster.mongodb.net/pizza_app

# JWT Configuration
JWT_SECRET=your_jwt_secret_key_here
JWT_EXPIRE=7d

# Server Configuration
PORT=5000
NODE_ENV=development

# Cloudinary Configuration (cho upload ảnh)
CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
CLOUDINARY_API_KEY=your_cloudinary_api_key
CLOUDINARY_API_SECRET=your_cloudinary_api_secret

# CORS Configuration
CORS_ORIGIN=http://localhost:3000
```

#### Client Environment

Flutter app không cần file `.env` riêng, các cấu hình API được lưu trong code.

### 3. Cài đặt và Khởi động Server

#### Bước 1: Cài đặt dependencies

```bash
cd server
npm install
```

#### Bước 2: Khởi động MongoDB

**Local MongoDB:**
```bash
# Windows
"C:\Program Files\MongoDB\Server\{version}\bin\mongod.exe"

# macOS/Linux
mongod
```

**Hoặc sử dụng MongoDB Atlas (cloud)**

#### Bước 3: Khởi động server

```bash
# Development mode
npm run dev

# Production mode
npm start
```

Server sẽ chạy tại: `http://localhost:5000`

**Các lệnh có sẵn:**
- `npm run dev`: Khởi động với nodemon (auto restart)
- `npm start`: Khởi động production
- `npm test`: Chạy tests

### 4. Cài đặt và Khởi động Client (Flutter)

#### Bước 1: Cài đặt Flutter dependencies

```bash
cd client
flutter pub get
```

#### Bước 2: Cấu hình API URL

Mở file `lib/controller/auth_controller.dart` và cập nhật URL server:

```dart
// Thay đổi URL này theo server của bạn
static const String baseUrl = 'http://localhost:5000';
// Hoặc IP của máy: 'http://192.168.1.100:5000'
```

#### Bước 3: Khởi động Flutter app

```bash
# Kiểm tra devices có sẵn
flutter devices

# Khởi động trên device cụ thể
flutter run -d <device-id>

# Hoặc khởi động trên device đầu tiên
flutter run
```

**Các lệnh hữu ích:**
- `flutter run`: Khởi động app
- `flutter build apk`: Build APK cho Android
- `flutter build ios`: Build cho iOS
- `flutter clean`: Xóa cache
- `flutter pub get`: Cài đặt dependencies

## 📱 Tính năng chính

### Server (Node.js)
- ✅ Authentication (Đăng ký/Đăng nhập)
- ✅ JWT Token Management
- ✅ Product Management
- ✅ Cart Management
- ✅ Order Management
- ✅ File Upload (Cloudinary)
- ✅ Admin Routes

### Client (Flutter)
- ✅ Onboarding Screens
- ✅ Authentication (Sign In/Sign Up)
- ✅ Product Browsing
- ✅ Shopping Cart
- ✅ Order Management
- ✅ Profile Management
- ✅ Offline Support (GetStorage)

## 🔧 Cấu trúc Project

```
Pizza/
├── client/                 # Flutter App
│   ├── lib/
│   │   ├── controller/     # GetX Controllers
│   │   ├── view/          # UI Screens
│   │   ├── utils/         # Utilities
│   │   └── main.dart      # Entry point
│   └── pubspec.yaml       # Flutter dependencies
├── server/                # Node.js Backend
│   ├── config/           # Configuration files
│   ├── controller/       # Route controllers
│   ├── middleware/       # Custom middleware
│   ├── models/          # MongoDB models
│   ├── routes/          # API routes
│   └── server.js        # Entry point
└── README.md
```

## 🌐 API Endpoints

### Authentication
- `POST /api/auth/dangky` - Đăng ký
- `POST /api/auth/dangNhap` - Đăng nhập

### Products
- `GET /api/products` - Lấy danh sách sản phẩm
- `GET /api/products/:id` - Lấy chi tiết sản phẩm

### Cart
- `POST /api/cart/add` - Thêm vào giỏ hàng
- `GET /api/cart` - Lấy giỏ hàng
- `DELETE /api/cart/:id` - Xóa item khỏi giỏ hàng

### Orders
- `POST /api/orders` - Tạo đơn hàng
- `GET /api/orders` - Lấy danh sách đơn hàng

## 🛠️ Troubleshooting

### Server Issues
1. **MongoDB Connection Error:**
   - Kiểm tra MongoDB đã chạy chưa
   - Kiểm tra MONGODB_URI trong .env

2. **Port Already in Use:**
   ```bash
   # Windows
   netstat -ano | findstr :5000
   taskkill /PID <PID> /F
   
   # macOS/Linux
   lsof -i :5000
   kill -9 <PID>
   ```

### Client Issues
1. **API Connection Error:**
   - Kiểm tra server đã chạy chưa
   - Kiểm tra URL trong auth_controller.dart
   - Sử dụng debug connection trong app

2. **Flutter Build Issues:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## 📝 Development Notes

- Server sử dụng Express.js với MongoDB
- Client sử dụng Flutter với GetX state management
- Authentication sử dụng JWT tokens
- File upload sử dụng Cloudinary
- Local storage sử dụng GetStorage

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License.
