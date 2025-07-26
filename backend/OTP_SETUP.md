# OTP Authentication Setup

## 🔧 Backend Setup

### 1. Environment Variables
Thêm các biến môi trường sau vào file `.env`:

```env
# Email Configuration (Gmail)
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password

# JWT Secret
JWT_SECRET=your-jwt-secret

# Database
MONGODB_URI=your-mongodb-uri
```

### 2. Gmail App Password
Để sử dụng Gmail để gửi OTP:

1. Bật 2FA cho Gmail
2. Tạo App Password:
   - Vào Google Account Settings
   - Security > 2-Step Verification > App passwords
   - Tạo password cho "Mail"
3. Sử dụng App Password thay vì password thường

### 3. API Endpoints

#### Đăng nhập bằng OTP:
- `POST /api/auth/send-login-otp`
  - Body: `{ "email": "user@example.com" }`
  - Response: `{ "success": true, "message": "Đã gửi OTP về email!" }`

- `POST /api/auth/verify-login-otp`
  - Body: `{ "email": "user@example.com", "otp": "123456" }`
  - Response: `{ "success": true, "user": {...}, "token": "jwt-token" }`

#### Đăng ký bằng OTP:
- `POST /api/auth/send-signup-otp`
  - Body: `{ "email": "newuser@example.com" }`
  - Response: `{ "success": true, "message": "Đã gửi OTP về email!" }`

- `POST /api/auth/register-with-otp`
  - Body: `{ "name": "User Name", "email": "newuser@example.com", "password": "password123", "otp": "123456" }`
  - Response: `{ "success": true, "user": {...}, "token": "jwt-token" }`

### 4. Database Schema

User model đã được cập nhật với các fields:
- `signupOTP`: OTP cho đăng ký
- `signupOTPExpires`: Thời gian hết hạn OTP đăng ký
- `isTemporary`: Trạng thái user tạm thời

### 5. Testing

Test các endpoints bằng Postman hoặc curl:

```bash
# Gửi OTP đăng nhập
curl -X POST http://localhost:5000/api/auth/send-login-otp \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'

# Xác thực OTP đăng nhập
curl -X POST http://localhost:5000/api/auth/verify-login-otp \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "otp": "123456"}'
```

## 📱 Frontend Integration

Frontend đã được tích hợp đầy đủ với:
- `LoginOtpScreen`: Màn hình xác thực OTP đăng nhập
- `SignupOtpScreen`: Màn hình xác thực OTP đăng ký
- Nút "Đăng nhập bằng OTP" và "Đăng ký bằng OTP"

## 🔒 Security Notes

1. OTP có hiệu lực trong 10 phút
2. OTP được xóa sau khi xác thực thành công
3. User tạm thời được đánh dấu `isTemporary: true`
4. Email validation được thực hiện ở cả frontend và backend 