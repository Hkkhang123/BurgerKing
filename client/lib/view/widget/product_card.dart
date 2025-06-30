import 'package:client/utils/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:client/utils/api_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class ProductCard extends StatefulWidget {
  final dynamic product;
  final List<String>? userFavorites;
  final Function(String productId, bool isFavorite)? onFavoriteToggle;
  final String? userToken;

  const ProductCard({
    super.key,
    required this.product,
    this.userFavorites,
    this.onFavoriteToggle,
    this.userToken,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool isFavorite;
  bool _isProcessing = false; // Thêm flag để tránh double tap

  @override
  void initState() {
    super.initState();
    isFavorite = widget.userFavorites?.contains(widget.product['_id']) ?? false;
  }

  @override
  void didUpdateWidget(ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cập nhật isFavorite khi userFavorites thay đổi
    if (oldWidget.userFavorites != widget.userFavorites) {
      final newFavoriteState = widget.userFavorites?.contains(widget.product['_id']) ?? false;
      setState(() {
        isFavorite = newFavoriteState;
      });
    }
  }

  // Helper function to determine image type and get the correct path
  String? _getImagePath() {
    final imageData = widget.product['image']?[0];
    if (imageData == null) return null;

    final url = imageData['url'];
    if (url == null) return null;

    // Check if it's a local asset (starts with 'assets/' or doesn't have http/https)
    if (url.startsWith('assets/') ||
        (!url.startsWith('http://') && !url.startsWith('https://'))) {
      return url;
    }

    // It's a network URL
    return url;
  }

  // Helper function to check if image is a network URL
  bool _isNetworkImage(String? url) {
    if (url == null) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  // Helper function to check if image is a local asset
  bool _isAssetImage(String? url) {
    if (url == null) return false;
    return url.startsWith('assets/') ||
        (!url.startsWith('http://') && !url.startsWith('https://'));
  }


  // Function to handle favorite toggle
  Future<void> _handleFavoriteToggle() async {
    if (_isProcessing) {
      return;
    }
    if (widget.userToken == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Bạn chưa đăng nhập'),
          content: const Text('Vui lòng đăng nhập để sử dụng tính năng yêu thích.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Điều hướng sang màn hình đăng nhập
                Navigator.of(context).pushNamed('/signin');
              },
              child: const Text('Đăng nhập'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
          ],
        ),
      );
      return;
    }
    // Optimistic UI: cập nhật trạng thái ngay
    final oldFavorite = isFavorite;
    setState(() {
      isFavorite = !isFavorite;
    });
    // Gọi callback nếu có
    if (widget.onFavoriteToggle != null) {
      widget.onFavoriteToggle!(widget.product['_id'], isFavorite);
    }
    // Gọi API ở background
    final result = await ApiService.toggleFavoriteProduct(widget.userToken!, widget.product['_id']);
    if (!result['success']) {
      // Rollback nếu lỗi
      setState(() {
        isFavorite = oldFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Lỗi cập nhật yêu thích')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imagePath = _getImagePath();

    return Container(
      constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withValues(alpha: 300)
                    : Colors.grey.withValues(alpha: 100),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: _buildImageWidget(imagePath),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: _isProcessing 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      )
                    : Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color:
                            isFavorite
                                ? Theme.of(context).primaryColor
                                : isDark
                                ? Colors.grey[400]
                                : Colors.grey,
                      ),
                  onPressed: _isProcessing ? null : _handleFavoriteToggle,
                ),
              ),
              if (widget.product['discountPrice'] != null)
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${caculateDiscount()} %',
                      style: AppTextStyle.withColor(
                        AppTextStyle.withWeight(
                          AppTextStyle.bodySmall,
                          FontWeight.bold,
                        ),
                        Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product['name'],
                    style: AppTextStyle.withColor(
                      AppTextStyle.withWeight(AppTextStyle.h3, FontWeight.bold),
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    widget.product['category'],
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodyMedium,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Row(
                    children: [
                      Text(
                        '${widget.product['discountPrice'].toStringAsFixed(0)} đ',
                        style: AppTextStyle.withColor(
                          AppTextStyle.withWeight(
                            AppTextStyle.bodyLarge,
                            FontWeight.bold,
                          ),
                          Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
                      ),
                      if (widget.product['price'] != null)
                        SizedBox(width: screenWidth * 0.01),
                      Text(
                        '${widget.product['price'].toStringAsFixed(0)} đ',
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodySmall,
                          isDark ? Colors.grey[400]! : Colors.grey[600]!,
                        ).copyWith(
                          decoration: TextDecoration.lineThrough
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        String? token = widget.userToken;
                        if (token == null) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Bạn chưa đăng nhập'),
                              content: const Text('Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Get.toNamed('/signin');
                                  },
                                  child: const Text('Đăng nhập'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Hủy'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }
                        print('[AddToCart] Sản phẩm: ' + widget.product.toString());
                        print('[AddToCart] Token: ' + (token ?? 'null'));
                        final result = await ApiService.addToCart(token, widget.product['_id']);
                        print('[AddToCart] Kết quả API: ' + result.toString());
                        if (result['success']) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã thêm vào giỏ hàng!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result['error'] ?? 'Lỗi khi thêm vào giỏ hàng')),
                          );
                        }
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Thêm vào giỏ hàng'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String? imagePath) {
    // No image available
    if (imagePath == null) {
      return _buildPlaceholder();
    }

    // Network image
    if (_isNetworkImage(imagePath)) {
      return Image.network(
        imagePath,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }

    // Asset image
    if (_isAssetImage(imagePath)) {
      return Image.asset(
        imagePath,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }

    // Fallback to placeholder
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[300],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 50,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'Không có hình ảnh',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  int caculateDiscount() {
    double discount = (widget.product['price'] - widget.product['discountPrice']) / widget.product['price'] * 100;
    return discount.toInt();
  }
}
