# Product API Documentation

## Tạo Sản Phẩm với Images

### 1. Tạo sản phẩm với URL images (không upload file)

**Endpoint:** `POST /api/products/`

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Body:**
```json
{
  "name": "Burger Bò Phô Mai",
  "description": "Burger bò thơm ngon với phô mai tan chảy",
  "price": 85000,
  "discountPrice": 75000,
  "countInStock": 50,
  "sku": "BURGER-001",
  "category": "Đồ ăn",
  "material": "Bò, phô mai, rau xanh, bánh mì",
  "image": [
    {
      "url": "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500",
      "altText": "Burger bò phô mai"
    }
  ],
  "tag": ["burger", "bò", "phô mai", "đồ ăn"],
  "dimension": {
    "length": 15,
    "width": 12,
    "height": 8
  }
}
```

### 2. Tạo sản phẩm với single file upload

**Endpoint:** `POST /api/products/with-image`

**Headers:**
```
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**Form Data:**
- `image`: File hình ảnh (tối đa 5MB)
- `name`: Tên sản phẩm
- `description`: Mô tả sản phẩm
- `price`: Giá sản phẩm
- `discountPrice`: Giá khuyến mãi
- `countInStock`: Số lượng tồn kho
- `sku`: Mã SKU
- `category`: Danh mục
- `material`: Nguyên liệu
- `tag`: Tags (JSON string)
- `dimension`: Kích thước (JSON string)

**Ví dụ với cURL:**
```bash
curl -X POST \
  http://localhost:5000/api/products/with-image \
  -H 'Authorization: Bearer <token>' \
  -F 'image=@/path/to/image.jpg' \
  -F 'name=Burger Bò Phô Mai' \
  -F 'description=Burger bò thơm ngon' \
  -F 'price=85000' \
  -F 'category=Đồ ăn' \
  -F 'sku=BURGER-001'
```

### 3. Tạo sản phẩm với multiple files upload

**Endpoint:** `POST /api/products/with-images`

**Headers:**
```
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**Form Data:**
- `images`: Multiple files hình ảnh (tối đa 10 files, mỗi file 5MB)
- Các field khác giống như single file upload

**Ví dụ với cURL:**
```bash
curl -X POST \
  http://localhost:5000/api/products/with-images \
  -H 'Authorization: Bearer <token>' \
  -F 'images=@/path/to/image1.jpg' \
  -F 'images=@/path/to/image2.jpg' \
  -F 'name=Burger Bò Phô Mai' \
  -F 'description=Burger bò thơm ngon' \
  -F 'price=85000' \
  -F 'category=Đồ ăn' \
  -F 'sku=BURGER-001'
```

## Upload Images API

### 1. Upload single file

**Endpoint:** `POST /api/upload/single`

**Headers:**
```
Content-Type: multipart/form-data
```

**Form Data:**
- `image`: File hình ảnh

**Response:**
```json
{
  "success": true,
  "imageUrl": "https://res.cloudinary.com/...",
  "publicId": "product/..."
}
```

### 2. Upload multiple files

**Endpoint:** `POST /api/upload/multiple`

**Headers:**
```
Content-Type: multipart/form-data
```

**Form Data:**
- `images`: Multiple files hình ảnh (tối đa 10 files)

**Response:**
```json
{
  "success": true,
  "images": [
    {
      "url": "https://res.cloudinary.com/...",
      "publicId": "product/...",
      "altText": "image1.jpg"
    }
  ]
}
```

### 3. Upload từ URL

**Endpoint:** `POST /api/upload/url`

**Headers:**
```
Content-Type: application/json
```

**Body:**
```json
{
  "imageUrl": "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500",
  "altText": "Burger image"
}
```

**Response:**
```json
{
  "success": true,
  "imageUrl": "https://res.cloudinary.com/...",
  "publicId": "product/...",
  "altText": "Burger image"
}
```

## Tính năng của Image Processing

### ✅ **Hỗ trợ nhiều loại input:**
- URL images từ internet
- File upload (single/multiple)
- Cloudinary URLs (sử dụng trực tiếp)

### ✅ **Tự động xử lý:**
- Upload lên Cloudinary với folder "product"
- Tự động detect resource type
- Giới hạn file size (5MB)
- Chỉ cho phép image files

### ✅ **Error handling:**
- Nếu upload thất bại, vẫn lưu URL gốc
- Log lỗi chi tiết
- Response error messages rõ ràng

### ✅ **Performance:**
- Sử dụng memory storage cho upload
- Stream upload để tiết kiệm memory
- Parallel upload cho multiple files

## Lưu ý sử dụng

1. **File size limit:** Tối đa 5MB cho mỗi file
2. **File type:** Chỉ chấp nhận image files (jpg, png, gif, webp, etc.)
3. **Multiple files:** Tối đa 10 files cho mỗi request
4. **Authentication:** Cần token admin để tạo sản phẩm
5. **Cloudinary:** Tự động tạo folder "product" trên Cloudinary 