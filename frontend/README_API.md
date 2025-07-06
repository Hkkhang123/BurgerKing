# Hướng dẫn sử dụng API Đăng nhập

## Tổng quan
Ứng dụng Flutter đã được tích hợp với API đăng nhập từ server Node.js. Hệ thống hỗ trợ đăng nhập và đăng ký với xác thực JWT.

## Cấu hình

### 1. URL API
- **Android Emulator**: `http://10.0.2.2:3000`
- **iOS Simulator**: `http://localhost:3000`
- **Thiết bị thật**: Cần thay đổi IP address phù hợp

### 2. Các endpoint
- **Đăng nhập**: `POST /api/auth/dangnhap`
- **Đăng ký**: `POST /api/auth/dangky`
- **Lấy thông tin profile**: `GET /api/auth/profile`

## Tính năng đã implement

### 1. AuthController
- `loginWithApi(email, password)`: Đăng nhập qua API
- `registerWithApi(name, email, password)`: Đăng ký qua API
- `logout()`: Đăng xuất và xóa dữ liệu local
- `getCurrentUser()`: Lấy thông tin user hiện tại
- `getToken()`: Lấy token JWT

### 2. ApiService
- Xử lý HTTP requests
- Quản lý headers và authentication
- Error handling

### 3. UI Features
- Form validation
- Loading states
- Error message display
- Auto-login khi khởi động app

## Cách sử dụng

### 1. Đăng nhập
```dart
final authController = Get.find<AuthController>();
final success = await authController.loginWithApi('email@example.com', 'password');
if (success) {
  // Chuyển đến màn hình chính
  Get.offAll(() => MainScreen());
}
```

### 2. Đăng ký
```dart
final authController = Get.find<AuthController>();
final success = await authController.registerWithApi('Tên người dùng', 'email@example.com', 'password');
if (success) {
  // Chuyển đến màn hình chính
  Get.offAll(() => MainScreen());
}
```

### 3. Kiểm tra trạng thái đăng nhập
```dart
final authController = Get.find<AuthController>();
if (authController.isLoggedIn) {
  // User đã đăng nhập
  final user = authController.getCurrentUser();
  final token = authController.getToken();
}
```

## Lưu trữ dữ liệu
- Sử dụng GetStorage để lưu trữ local
- Dữ liệu được lưu:
  - `isLoggedIn`: Trạng thái đăng nhập
  - `user`: Thông tin user
  - `token`: JWT token
  - `isFirstTime`: Lần đầu sử dụng app

## Error Handling
- Hiển thị thông báo lỗi bằng tiếng Việt
- Xử lý lỗi kết nối mạng
- Validation form phía client
- Auto-logout khi token không hợp lệ

## Lưu ý
1. Đảm bảo server đang chạy trên port 3000
2. Kiểm tra kết nối mạng
3. Cập nhật URL API phù hợp với môi trường
4. Xử lý timeout cho requests 