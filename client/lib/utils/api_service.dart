import 'package:http/http.dart' as http;
import 'dart:convert';


class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000'; // For Android emulator - port 5000
  // static const String baseUrl = 'http://localhost:5000'; // For iOS simulator - port 5000

  // Headers
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  static Map<String, String> getAuthHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Login API
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/dangnhap'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'statusCode': response.statusCode,
        };
      } else {
        // Xử lý các lỗi HTTP cụ thể
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
          'error': _getErrorMessage(response.statusCode, errorData['message']),
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
      
      // Kiểm tra loại lỗi cụ thể
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

  // Helper method để tạo thông báo lỗi
  static String _getErrorMessage(int statusCode, String? serverMessage) {
    switch (statusCode) {
      case 400:
        return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại thông tin.';
      case 401:
        return 'Email hoặc mật khẩu không đúng.';
      case 404:
        return 'Không tìm thấy tài khoản với email này.';
      case 500:
        return 'Lỗi server. Vui lòng thử lại sau.';
      case 503:
        return 'Server đang bảo trì. Vui lòng thử lại sau.';
      default:
        return serverMessage ?? 'Đã xảy ra lỗi không xác định.';
    }
  }

  // Register API
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/dangky'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'statusCode': response.statusCode,
        };
      } else {
        // Xử lý các lỗi HTTP cụ thể
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
          'error': _getRegisterErrorMessage(response.statusCode, errorData['message']),
        };
      }
    } on http.ClientException  {
      return {
        'success': false,
        'error': 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.',
        'statusCode': 0,
      };
    } catch (e) {
      String errorMessage = 'Lỗi kết nối: $e';
      
      // Kiểm tra loại lỗi cụ thể
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

  // Helper method để tạo thông báo lỗi cho đăng ký
  static String _getRegisterErrorMessage(int statusCode, String? serverMessage) {
    switch (statusCode) {
      case 400:
        return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại thông tin.';
      case 409:
        return 'Email đã tồn tại. Vui lòng sử dụng email khác.';
      case 500:
        return 'Lỗi server. Vui lòng thử lại sau.';
      case 503:
        return 'Server đang bảo trì. Vui lòng thử lại sau.';
      default:
        return serverMessage ?? 'Đã xảy ra lỗi không xác định.';
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/profile'),
        headers: getAuthHeaders(token),
      );

      return {
        'success': response.statusCode == 200,
        'data': jsonDecode(response.body),
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Lỗi kết nối: $e',
        'statusCode': 0,
      };
    }
  }

  // Upload avatar
  static Future<Map<String, dynamic>> uploadAvatar(String token, List<int> imageBytes, String fileName) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/auth/avatar'),
      );
      
      request.headers.addAll(getAuthHeaders(token));
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: fileName,
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseData);

      return {
        'success': response.statusCode == 200,
        'data': jsonData,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Lỗi kết nối: $e',
        'statusCode': 0,
      };
    }
  }

  // Test connection to server
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));

      return {
        'success': true,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Không thể kết nối đến server',
        'statusCode': 0,
      };
    }
  }

  // Lấy danh sách sản phẩm bán chạy
  static Future<List<dynamic>> fetchBestSellerProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/products/best-seller'),
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

  // Toggle favorite product
  static Future<Map<String, dynamic>> toggleFavoriteProduct(String token, String productId) async {
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

  // Lấy danh sách đánh giá sản phẩm
  static Future<List<dynamic>> fetchProductReviews(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/products/$productId/reviews'),
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

  static Future<Map<String, dynamic>> submitProductReview(
      String productId, double rating, String comment, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/products/$productId/reviews'),
        headers: getAuthHeaders(token),
        body: jsonEncode({'rating': rating, 'comment': comment}),
      );
      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'error': data['message'] ?? 'Lỗi'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Generic GET method for making HTTP GET requests
  static Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParams, String? token}) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');
      
      // Add query parameters if provided
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())));
      }
      
      final headers = token != null ? getAuthHeaders(token) : _headers;
      
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      
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

  // Thêm sản phẩm vào giỏ hàng
  static Future<Map<String, dynamic>> addToCart(String? token, String productId, {int quantity = 1, String? guestId}) async {
    try {
      final body = {
        'productId': productId,
        'quantity': quantity,
      };
      if (guestId != null) body['guestId'] = guestId;
      final response = await http.post(
        Uri.parse('$baseUrl/api/cart'),
        headers: token != null ? getAuthHeaders(token) : _headers,
        body: jsonEncode(body),
      );
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'data': jsonDecode(response.body),
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Lỗi kết nối: $e',
        'statusCode': 0,
      };
    }
  }

  // Lấy thông tin giỏ hàng
  static Future<Map<String, dynamic>> getCart(String? token, {String? guestId}) async {
    try {
      final uri = guestId != null
          ? Uri.parse('$baseUrl/api/cart?guestId=$guestId')
          : Uri.parse('$baseUrl/api/cart');
      final response = await http.get(
        uri,
        headers: token != null ? getAuthHeaders(token) : _headers,
      );
      return {
        'success': response.statusCode == 200,
        'data': jsonDecode(response.body),
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Lỗi kết nối: $e',
        'statusCode': 0,
      };
    }
  }

  // Xóa sản phẩm khỏi giỏ hàng
  static Future<Map<String, dynamic>> deleteFromCart(String? token, String productId, {String? guestId}) async {
    try {
      final body = {
        'productId': productId,
      };
      if (guestId != null) body['guestId'] = guestId;
      final response = await http.delete(
        Uri.parse('$baseUrl/api/cart'),
        headers: token != null ? getAuthHeaders(token) : _headers,
        body: jsonEncode(body),
      );
      return {
        'success': response.statusCode == 200,
        'data': jsonDecode(response.body),
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Lỗi kết nối: $e',
        'statusCode': 0,
      };
    }
  }

  // Cập nhật số lượng sản phẩm trong giỏ hàng
  static Future<Map<String, dynamic>> updateCart(String? token, String productId, int quantity, {String? guestId}) async {
    try {
      final body = {
        'productId': productId,
        'quantity': quantity,
      };
      if (guestId != null) body['guestId'] = guestId;
      final response = await http.put(
        Uri.parse('$baseUrl/api/cart'),
        headers: token != null ? getAuthHeaders(token) : _headers,
        body: jsonEncode(body),
      );
      return {
        'success': response.statusCode == 200,
        'data': jsonDecode(response.body),
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Lỗi kết nối: $e',
        'statusCode': 0,
      };
    }
  }
} 