# 🔧 Sửa lỗi hình ảnh 404

## 🚨 Vấn đề
Lỗi `NetworkImageLoadException` với status code 404 khi tải hình ảnh từ Unsplash URLs.

## ✅ Giải pháp

### 1. Chạy seeder mới với hình ảnh đáng tin cậy

```bash
cd server
npm run seed:fixed
```

### 2. Hoặc chạy thủ công

```bash
cd server
node seeder_fixed.js
```

### 3. Kiểm tra kết quả

Seeder sẽ tạo:
- ✅ 8 sản phẩm với hình ảnh từ Pexels (đáng tin cậy hơn)
- ✅ User admin: admin@example.com / 123456
- ✅ Categories: burger, pizza, sushi, vietnamese, drink, dessert

### 4. Test API

```bash
# Kiểm tra sản phẩm
curl http://localhost:5000/api/products

# Filter theo category
curl http://localhost:5000/api/products?category=pizza

# Filter theo giá
curl http://localhost:5000/api/products?minPrice=50000&maxPrice=150000
```

## 🎯 Các thay đổi

### Dữ liệu sản phẩm mới (`server/data/products_fixed.js`)
- ✅ Thay thế Unsplash URLs bằng Pexels URLs
- ✅ Cập nhật categories phù hợp với filter
- ✅ Giảm số lượng sản phẩm để test dễ dàng hơn

### Categories mới
- `burger` - Burger các loại
- `pizza` - Pizza các loại  
- `sushi` - Sushi các loại
- `vietnamese` - Món Việt Nam
- `drink` - Thức uống
- `dessert` - Tráng miệng

## 🚀 Chạy ứng dụng

```bash
# Terminal 1 - Server
cd server
npm start

# Terminal 2 - Flutter App
cd client
flutter run
```

## 📱 Test trên Flutter

1. Mở app Flutter
2. Vào màn hình Shopping hoặc Demo Filter
3. Test các tính năng filter:
   - Tìm kiếm theo tên
   - Filter theo category
   - Filter theo giá
   - Filter theo đánh giá
   - Sắp xếp theo các tiêu chí

## 🔍 Debug

Nếu vẫn có lỗi hình ảnh:

1. Kiểm tra kết nối internet
2. Thử URL hình ảnh trực tiếp trên browser
3. Sử dụng placeholder images nếu cần

## 📝 Ghi chú

- Pexels URLs ổn định hơn Unsplash
- Có thể thay thế bằng local assets nếu cần
- Error handling đã được implement trong ProductCard 