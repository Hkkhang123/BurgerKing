# 🍕 Pizza App - Frontend Structure

## 📁 Cấu trúc thư mục đã được tổ chức lại

```
lib/
├── 📁 core/                    # Core functionality
│   ├── 📁 constants/          # Constants và configuration
│   ├── 📁 utils/              # Utility functions
│   │   ├── api_service.dart
│   │   ├── debug_connection.dart
│   │   ├── google_auth_service.dart
│   │   └── success_dialog.dart
│   └── 📁 services/           # Business logic services
│       ├── auth_controller.dart
│       ├── filter_controller.dart
│       └── navigation_controller.dart
├── 📁 features/               # Feature-based organization
│   ├── 📁 auth/              # Authentication screens
│   │   ├── account_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── signin_screen.dart
│   │   └── signup_screen.dart
│   ├── 📁 home/              # Home screen
│   │   ├── home_screen.dart
│   │   ├── main_screen.dart
│   │   └── splash_screen.dart
│   ├── 📁 product/           # Product-related screens
│   │   ├── demo_filter_screen.dart
│   │   └── shopping_screen.dart
│   ├── 📁 cart/              # Cart functionality
│   └── 📁 order/             # Order management
├── 📁 shared/                 # Shared components
│   ├── 📁 widgets/           # Reusable widgets
│   │   ├── all_product.dart
│   │   ├── best_seller_product_list.dart
│   │   ├── cart_screen.dart
│   │   ├── category_chip.dart
│   │   ├── custom_bottom_navbar.dart
│   │   ├── custom_searchbar.dart
│   │   ├── custom_textfield.dart
│   │   ├── favorite_screen.dart
│   │   ├── filter_bottom_sheet.dart
│   │   ├── product_card.dart
│   │   ├── product_detail.dart
│   │   ├── product_grid.dart
│   │   └── sale_banner.dart
│   ├── 📁 themes/            # App themes và styling
│   │   ├── app_textstyle.dart
│   │   └── app_themes.dart
│   └── 📁 models/            # Data models
└── 📄 main.dart              # Entry point
```

## 🎯 Lợi ích của cấu trúc mới

### ✅ **Core**
- **constants/**: Chứa các hằng số, configuration
- **utils/**: Các utility functions dùng chung
- **services/**: Business logic và controllers

### ✅ **Features**
- **auth/**: Tất cả màn hình liên quan đến xác thực
- **home/**: Màn hình chính và khởi động
- **product/**: Màn hình sản phẩm và lọc
- **cart/**: Chức năng giỏ hàng
- **order/**: Quản lý đơn hàng

### ✅ **Shared**
- **widgets/**: Components có thể tái sử dụng
- **themes/**: Theme và style dùng chung
- **models/**: Data models

## 🔄 Cách sử dụng

### Import từ core:
```dart
import 'package:pizza_app/core/services/auth_controller.dart';
import 'package:pizza_app/core/utils/api_service.dart';
```

### Import từ features:
```dart
import 'package:pizza_app/features/auth/signin_screen.dart';
import 'package:pizza_app/features/home/home_screen.dart';
```

### Import từ shared:
```dart
import 'package:pizza_app/shared/widgets/product_card.dart';
import 'package:pizza_app/shared/themes/app_themes.dart';
```

## 📝 Lưu ý
- Cấu trúc này giúp code dễ maintain và scale
- Mỗi feature có thể phát triển độc lập
- Shared components có thể tái sử dụng across features
- Core chứa logic business chung cho toàn app 