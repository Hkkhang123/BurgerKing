import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewController extends GetxController {
  static const String baseUrl = 'https://burgerking-j92p.onrender.com';
  
  // Observable variables
  final RxList<dynamic> productReviews = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Headers
  static Map<String, String> getAuthHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Lấy danh sách đánh giá sản phẩm
  Future<List<dynamic>> fetchProductReviews(String productId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/products/$productId/reviews'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        productReviews.value = jsonDecode(response.body);
        return productReviews.value;
      } else {
        productReviews.value = [];
        errorMessage.value = 'Không thể tải đánh giá sản phẩm';
        return [];
      }
    } catch (e) {
      productReviews.value = [];
      errorMessage.value = 'Lỗi kết nối: $e';
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // Submit đánh giá sản phẩm
  Future<Map<String, dynamic>> submitProductReview(
      String productId, double rating, String comment, String token) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/products/$productId/reviews'),
        headers: getAuthHeaders(token),
        body: jsonEncode({'rating': rating, 'comment': comment}),
      );
      
      if (response.statusCode == 201) {
        // Refresh reviews after successful submission
        await fetchProductReviews(productId);
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        errorMessage.value = data['message'] ?? 'Lỗi khi gửi đánh giá';
        return {'success': false, 'error': data['message'] ?? 'Lỗi'};
      }
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: $e';
      return {'success': false, 'error': e.toString()};
    } finally {
      isLoading.value = false;
    }
  }

  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  // Clear reviews
  void clearReviews() {
    productReviews.value = [];
  }
} 