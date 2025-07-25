import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://burgerking-j92p.onrender.com';

  // Headers
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  static Map<String, String> getAuthHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Generic GET method for making HTTP GET requests
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    String? token,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');

      // Add query parameters if provided
      if (queryParams != null) {
        uri = uri.replace(
          queryParameters: queryParams.map(
            (key, value) => MapEntry(key, value.toString()),
          ),
        );
      }

      final headers = token != null ? getAuthHeaders(token) : _headers;

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

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
        'error':
            'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.',
        'statusCode': 0,
      };
    } catch (e) {
      String errorMessage = 'Lỗi kết nối: $e';

      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        errorMessage =
            'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Kết nối bị timeout. Vui lòng thử lại.';
      }

      return {'success': false, 'error': errorMessage, 'statusCode': 0};
    }
  }

  // Generic POST method for making HTTP POST requests
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final headers = token != null ? getAuthHeaders(token) : _headers;

      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
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
        'error':
            'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.',
        'statusCode': 0,
      };
    } catch (e) {
      String errorMessage = 'Lỗi kết nối: $e';

      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        errorMessage =
            'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Kết nối bị timeout. Vui lòng thử lại.';
      }

      return {'success': false, 'error': errorMessage, 'statusCode': 0};
    }
  }

  // Generic PUT method for making HTTP PUT requests
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final headers = token != null ? getAuthHeaders(token) : _headers;

      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

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
        'error':
            'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.',
        'statusCode': 0,
      };
    } catch (e) {
      String errorMessage = 'Lỗi kết nối: $e';

      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        errorMessage =
            'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Kết nối bị timeout. Vui lòng thử lại.';
      }

      return {'success': false, 'error': errorMessage, 'statusCode': 0};
    }
  }

  // Generic DELETE method for making HTTP DELETE requests
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final headers = token != null ? getAuthHeaders(token) : _headers;

      final request = http.Request('DELETE', Uri.parse('$baseUrl$endpoint'));
      request.headers.addAll(headers);

      if (body != null) {
        request.body = jsonEncode(body);
      }

      final response = await http.Client()
          .send(request)
          .timeout(const Duration(seconds: 10));
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(responseData),
          'statusCode': response.statusCode,
        };
      } else {
        Map<String, dynamic> errorData = {};
        try {
          errorData = jsonDecode(responseData);
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
        'error':
            'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.',
        'statusCode': 0,
      };
    } catch (e) {
      String errorMessage = 'Lỗi kết nối: $e';

      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        errorMessage =
            'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Kết nối bị timeout. Vui lòng thử lại.';
      }

      return {'success': false, 'error': errorMessage, 'statusCode': 0};
    }
  }

  // ==== ĐỊA CHỈ GIAO HÀNG ====
  static Future<List<dynamic>> getAddresses(String token) async {
    final res = await get('/api/auth/addresses', token: token);
    if (res['success']) {
      return List<dynamic>.from(res['data']);
    } else {
      throw Exception(res['error'] ?? 'Lỗi lấy danh sách địa chỉ');
    }
  }

  static Future<List<dynamic>> addAddress(
    Map<String, dynamic> address,
    String token,
  ) async {
    final res = await post('/api/auth/addresses', address, token: token);
    if (res['success']) {
      return List<dynamic>.from(res['data']);
    } else {
      throw Exception(res['error'] ?? 'Lỗi thêm địa chỉ');
    }
  }

  static Future<List<dynamic>> updateAddress(
    String addressId,
    Map<String, dynamic> address,
    String token,
  ) async {
    final res = await put(
      '/api/auth/addresses/$addressId',
      address,
      token: token,
    );
    if (res['success']) {
      return List<dynamic>.from(res['data']);
    } else {
      throw Exception(res['error'] ?? 'Lỗi cập nhật địa chỉ');
    }
  }

  static Future<List<dynamic>> deleteAddress(
    String addressId,
    String token,
  ) async {
    final res = await delete('/api/auth/addresses/$addressId', token: token);
    if (res['success']) {
      return List<dynamic>.from(res['data']);
    } else {
      throw Exception(res['error'] ?? 'Lỗi xóa địa chỉ');
    }
  }

  // Helper method để tạo thông báo lỗi chung
  static String getErrorMessage(int statusCode, String? serverMessage) {
    switch (statusCode) {
      case 400:
        return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại thông tin.';
      case 401:
        return 'Không có quyền truy cập. Vui lòng đăng nhập lại.';
      case 403:
        return 'Truy cập bị từ chối.';
      case 404:
        return 'Không tìm thấy dữ liệu.';
      case 500:
        return 'Lỗi server. Vui lòng thử lại sau.';
      case 503:
        return 'Server đang bảo trì. Vui lòng thử lại sau.';
      default:
        return serverMessage ?? 'Đã xảy ra lỗi không xác định.';
    }
  }
}
