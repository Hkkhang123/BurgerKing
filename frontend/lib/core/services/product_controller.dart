import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductController extends GetxController {
  static const String baseUrl = 'https://burgerking-j92p.onrender.com';
  
  // Observable variables
  final RxList<dynamic> bestSellerProducts = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Headers
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  static Map<String, String> getAuthHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  @override
  void onInit() {
    super.onInit();
    fetchBestSellerProducts();
  }

  // Lấy danh sách sản phẩm bán chạy
  Future<List<dynamic>> fetchBestSellerProducts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/products/best-seller'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        bestSellerProducts.value = jsonDecode(response.body);
        return bestSellerProducts.value;
      } else {
        bestSellerProducts.value = [];
        errorMessage.value = 'Không thể tải danh sách sản phẩm bán chạy';
        return [];
      }
    } catch (e) {
      bestSellerProducts.value = [];
      errorMessage.value = 'Lỗi kết nối: $e';
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle favorite product
  Future<Map<String, dynamic>> toggleFavoriteProduct(String token, String productId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/products/favorite/$productId'),
        headers: getAuthHeaders(token),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'statusCode': response.statusCode,
        };
      } else {
        Map<String, dynamic> errorData = {};
        try {
          errorData = jsonDecode(response.body);
        } catch (e) {
          errorData = {'message': 'Lỗi không xác định'};
        }

        return {
          'success': false,
          'data': errorData,
          'statusCode': response.statusCode,
          'error': errorData['message'] ?? 'Đã xảy ra lỗi không xác định.',
        };
      }
    } on http.ClientException {
      return {
        'success': false,
        'error': 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.',
        'statusCode': 0,
      };
    } catch (e) {
      String errorMessage = 'Lỗi kết nối: $e';
      
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        errorMessage = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Kết nối bị timeout. Vui lòng thử lại.';
      }
      
      return {
        'success': false,
        'error': errorMessage,
        'statusCode': 0,
      };
    }
  }

  // Lấy chi tiết nhiều sản phẩm theo danh sách ID
  Future<List<Map<String, dynamic>>> getProductsByIds(List<String> ids) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/products/by-ids'),
        headers: _headers,
        body: jsonEncode({'ids': ids}),
      );
      
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['products'] != null) {
        return List<Map<String, dynamic>>.from(data['products']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Lấy danh sách tất cả sản phẩm
  Future<List<dynamic>> fetchAllProducts({Map<String, dynamic>? filters}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      Uri uri = Uri.parse('$baseUrl/api/products');
      if (filters != null) {
        uri = uri.replace(queryParameters: filters.map((key, value) => MapEntry(key, value.toString())));
      }
      
      final response = await http.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['products'] ?? [];
      } else {
        errorMessage.value = 'Không thể tải danh sách sản phẩm';
        return [];
      }
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: $e';
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // Lấy chi tiết sản phẩm theo ID
  Future<Map<String, dynamic>?> fetchProductById(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/products/$productId'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        errorMessage.value = 'Không thể tải thông tin sản phẩm';
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: $e';
      return null;
    }
  }

  // Tìm kiếm sản phẩm
  Future<List<dynamic>> searchProducts(String query) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/products/search?q=$query'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['products'] ?? [];
      } else {
        errorMessage.value = 'Không thể tìm kiếm sản phẩm';
        return [];
      }
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: $e';
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // Lấy sản phẩm theo danh mục
  Future<List<dynamic>> fetchProductsByCategory(String categoryId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/products/category/$categoryId'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['products'] ?? [];
      } else {
        errorMessage.value = 'Không thể tải sản phẩm theo danh mục';
        return [];
      }
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: $e';
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // Lấy danh sách danh mục
  Future<List<dynamic>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/categories'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  // Clear products
  void clearProducts() {
    bestSellerProducts.value = [];
  }

  // Refresh best seller products
  Future<void> refreshBestSellerProducts() async {
    await fetchBestSellerProducts();
  }
} 