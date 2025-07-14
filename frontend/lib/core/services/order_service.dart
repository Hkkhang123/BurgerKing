import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderService {
  static const String baseUrl = 'https://burgerking-j92p.onrender.com';

  // Lấy thông tin đơn hàng chi tiết theo ID
  static Future<Map<String, dynamic>> getOrderById(String token, String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/order/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'data': errorData};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Lấy thông tin checkout chi tiết theo ID
  static Future<Map<String, dynamic>> getCheckoutById(String token, String checkoutId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/checkout/$checkoutId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'data': errorData};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Lấy danh sách đơn hàng của user
  static Future<Map<String, dynamic>> getMyOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/order/my-order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'data': errorData};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Lấy thông tin sản phẩm chi tiết theo ID
  static Future<Map<String, dynamic>> getProductById(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/product/$productId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'data': errorData};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Lấy thông tin sản phẩm theo danh sách ID
  static Future<Map<String, dynamic>> getProductsByIds(List<String> productIds) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/product/get-by-ids'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'ids': productIds}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'data': errorData};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
} 