import 'package:client/core/services/auth_controller.dart';
import 'package:client/shared/themes/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:client/core/services/review_controller.dart';

class ProductDetail extends StatefulWidget {
  final Map<String, dynamic> product;
  final List<String>? userFavorites;
  const ProductDetail({super.key, required this.product, this.userFavorites});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  double _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  late Future<List<dynamic>> _reviewsFuture;
  late ReviewController reviewController;

  @override
  void initState() {
    super.initState();
    reviewController = Get.find<ReviewController>();
    _reviewsFuture = reviewController.fetchProductReviews(widget.product['_id']);
  }

  void _reloadReviews() {
    if (mounted) {
      setState(() {
        _reviewsFuture = reviewController.fetchProductReviews(widget.product['_id']);
      });
    }
  }

  Widget _buildReviewForm(BuildContext context) {
    final authController = Get.find<AuthController>();
    final String? token = authController.getToken();
    if (token == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('Bạn cần đăng nhập để đánh giá sản phẩm.'),
      );
    }
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Đánh giá của bạn:', style: AppTextStyle.h3),
          const SizedBox(height: 8),
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Bình luận (không bắt buộc)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      if (!mounted) return;
                      setState(() => _isSubmitting = true);
                      final res = await reviewController.submitProductReview(
                        widget.product['_id'],
                        _rating,
                        _commentController.text,
                        token,
                      );
                      if (mounted) {
                        setState(() => _isSubmitting = false);
                        if (res['success']) {
                          _commentController.clear();
                          _reloadReviews();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đánh giá thành công!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(res['error'] ?? 'Lỗi gửi đánh giá')),
                          );
                        }
                      }
                    },
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Gửi đánh giá'),
            ),
          ),
        ],
      ),
    );
  }

  bool _isProductFavorite() {
    if (widget.userFavorites == null || widget.product['_id'] == null) return false;
    return widget.userFavorites!.contains(widget.product['_id']);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFavorite = _isProductFavorite();
    dynamic rawImage = widget.product['image'];
    String? image;
    if (rawImage is List && rawImage.isNotEmpty) {
      var first = rawImage[0];
      if (first is Map && first['url'] != null) {
        image = first['url'];
      } else if (first is String) {
        image = first;
      }
    } else if (rawImage is Map && rawImage['url'] != null) {
      image = rawImage['url'];
    } else if (rawImage is String) {
      image = rawImage;
    }

    final double avgRating = (widget.product['rating'] ?? 0).toDouble();
    final int numReviews = widget.product['numReviews'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'Chi tiết',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                () => _shareProduct(
                  context,
                  widget.product['name'],
                  widget.product['description'],
                ),
            icon: Icon(
              Icons.share,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: (image != null && image.toString().startsWith('http'))
                      ? Image.network(
                          image,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset('assets/images/burger.jpg', fit: BoxFit.cover),
                        )
                      : Image.asset(
                          image ?? 'assets/images/burger.jpg',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color:
                          isFavorite
                              ? Theme.of(context).primaryColor
                              : isDark
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product['name'],
                          style: AppTextStyle.withColor(
                            AppTextStyle.h2,
                            Theme.of(context).textTheme.headlineMedium!.color!,
                          ),
                        ),
                      ),
                      Text(
                        '${widget.product['price'].toStringAsFixed(0)} đ',
                        style: AppTextStyle.withColor(
                          AppTextStyle.h2,
                          Theme.of(context).textTheme.headlineMedium!.color!,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.product['description'],
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodyMedium,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Đánh giá sản phẩm',
                    style: AppTextStyle.withColor(
                      AppTextStyle.h3,
                      Theme.of(context).textTheme.headlineMedium!.color!,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (i) => Icon(
                          i < avgRating.round() ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        )),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: AppTextStyle.bodyLarge,
                      ),
                      const SizedBox(width: 8),
                      Text('($numReviews đánh giá)', style: AppTextStyle.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FutureBuilder<List<dynamic>>(
                      future: _reviewsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Text('Lỗi khi tải đánh giá.');
                        } else {
                          final reviews = snapshot.data ?? [];
                          if (reviews.isEmpty) {
                            return const Text('Chưa có đánh giá nào.');
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            separatorBuilder: (context, idx) => const Divider(height: 24),
                            itemBuilder: (context, idx) {
                              final review = reviews[idx];
                              final String dateStr = review['createdAt'] != null
                                  ? DateFormat('dd/MM/yyyy').format(DateTime.tryParse(review['createdAt']) ?? DateTime.now())
                                  : '';
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    child: Text(
                                      review['name'] != null && review['name'].isNotEmpty
                                          ? review['name'][0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              review['name'] ?? '',
                                              style: AppTextStyle.withWeight(AppTextStyle.bodyLarge, FontWeight.bold),
                                            ),
                                            const SizedBox(width: 8),
                                            Row(
                                              children: List.generate(5, (i) => Icon(
                                                i < (review['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                                color: Colors.amber,
                                                size: 18,
                                              )),
                                            ),
                                          ],
                                        ),
                                        if (review['comment'] != null && review['comment'].toString().isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                                            child: Text(review['comment'], style: AppTextStyle.bodyMedium),
                                          ),
                                        if (dateStr.isNotEmpty)
                                          Text(
                                            dateStr,
                                            style: AppTextStyle.bodySmall.copyWith(color: Colors.grey),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                  _buildReviewForm(context),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                    ),
                    side: BorderSide(
                      color: isDark ? Colors.white70 : Colors.black12,
                    ),
                  ),
                  child: Text(
                    'Thêm vào giỏ hàng',
                    style: AppTextStyle.withColor(
                      AppTextStyle.buttonMedium,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    'Mua ngay',
                    style: AppTextStyle.withColor(
                      AppTextStyle.buttonMedium,
                      Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _shareProduct(
  BuildContext context,
  String productName,
  String description,
) async {
  final box = context.findRenderObject() as RenderBox?;

  const String shopLink =
      'http://burgerking.com/products/burger-king-bacon-cheeseburger';
  final String shareMessage = '$description\n\ Đặt đồ ăn tại: $shopLink';

  try {
    final ShareResult result = await Share.share(
      shareMessage,
      subject: productName,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );

    if (result.status == ShareResultStatus.success) {
      print('Cảm ơn bạn đã chia sẻ');
    }
  } catch (e) {
    debugPrint('Lỗi chia sẻ: $e');
  }
}
