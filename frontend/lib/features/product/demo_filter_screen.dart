import 'package:flutter/material.dart';
import 'package:client/shared/widgets/filter_bottom_sheet.dart';
import 'package:client/shared/widgets/best_seller_product_list.dart';
import 'package:client/shared/themes/app_textstyle.dart';

class DemoFilterScreen extends StatelessWidget {
  const DemoFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Demo Bộ lọc sản phẩm',
          style: AppTextStyle.withColor(
            AppTextStyle.h2,
            Theme.of(context).textTheme.bodyLarge!.color!,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Test Filter Button
          IconButton(
            icon: Icon(
              Icons.filter_alt,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              FilterBottomSheet.show(context, (filterParams) {
                print('Filter applied: $filterParams');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bộ lọc đã được áp dụng: $filterParams'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Info Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 100),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 300),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tính năng bộ lọc',
                      style: AppTextStyle.withColor(
                        AppTextStyle.h3,
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Tìm kiếm theo tên sản phẩm\n'
                  '• Lọc theo danh mục (Pizza, Burger, Sushi...)\n'
                  '• Lọc theo khoảng giá\n'
                  '• Lọc theo đánh giá (số sao)\n'
                  '• Sắp xếp theo giá, đánh giá, độ phổ biến\n'
                  '• Phân trang tự động\n\n'
                  '💡 Nhấn nút filter ở góc phải để test bộ lọc',
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodyMedium,
                    (isDark ? Colors.grey[300] : Colors.grey[700])!,
                  ),
                ),
              ],
            ),
          ),
          
          // Filtered Product List
          const Expanded(
            child: BestSellerProductList(),
          ),
        ],
      ),
    );
  }
} 