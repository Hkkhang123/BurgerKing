import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartController extends GetxController {
  static const String baseUrl = 'https://burgerking-j92p.onrender.com';

  // Lấy giỏ hàng
  Future<Map<String, dynamic>> getCart(String? token, {String? guestId}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/cart'),
        headers:
            token != null
                ? {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                }
                : {
                  'Content-Type': 'application/json',
                  'guest-id': guestId ?? '',
                },
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return {'success': true, 'data': data};
        } catch (jsonError) {
          return {
            'success': false,
            'error': 'Invalid JSON response: $jsonError',
          };
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'data': errorData};
        } catch (jsonError) {
          return {
            'success': false,
            'error': 'HTTP ${response.statusCode}: ${response.body}',
          };
        }
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Thêm vào giỏ hàng
  Future<Map<String, dynamic>> addToCart(
    String? token,
    String productId, {
    int quantity = 1,
    String? guestId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/cart/'),
        headers:
            token != null
                ? {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                }
                : {
                  'Content-Type': 'application/json',
                  'guest-id': guestId ?? '',
                },
        body: jsonEncode({'productId': productId, 'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return {'success': true, 'data': data};
        } catch (jsonError) {
          return {
            'success': false,
            'error': 'Invalid JSON response: $jsonError',
          };
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'data': errorData};
        } catch (jsonError) {
          return {
            'success': false,
            'error': 'HTTP ${response.statusCode}: ${response.body}',
          };
        }
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Cập nhật giỏ hàng
  Future<Map<String, dynamic>> updateCart(
    String? token,
    String productId,
    int quantity, {
    String? guestId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/cart/'),
        headers:
            token != null
                ? {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                }
                : {
                  'Content-Type': 'application/json',
                  'guest-id': guestId ?? '',
                },
        body: jsonEncode({'productId': productId, 'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return {'success': true, 'data': data};
        } catch (jsonError) {
          return {
            'success': false,
            'error': 'Invalid JSON response: $jsonError',
          };
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'data': errorData};
        } catch (jsonError) {
          return {
            'success': false,
            'error': 'HTTP ${response.statusCode}: ${response.body}',
          };
        }
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Xóa khỏi giỏ hàng
  Future<Map<String, dynamic>> deleteFromCart(
    String? token,
    String productId, {
    String? guestId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/cart/'),
        headers:
            token != null
                ? {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                }
                : {
                  'Content-Type': 'application/json',
                  'guest-id': guestId ?? '',
                },
        body: jsonEncode({
          'productId': productId,
          if (guestId != null) 'guestId': guestId,
        }),
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return {'success': true, 'data': data};
        } catch (jsonError) {
          return {
            'success': false,
            'error': 'Invalid JSON response: $jsonError',
          };
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'data': errorData};
        } catch (jsonError) {
          return {
            'success': false,
            'error': 'HTTP ${response.statusCode}: ${response.body}',
          };
        }
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Thanh toán (Checkout)
  Future<Map<String, dynamic>> checkout(
    String? token, {
    required List<Map<String, dynamic>> checkoutItem,
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod,
    required double totalPrice,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/checkout'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'checkoutItem': checkoutItem,
          'shippingAddress': shippingAddress,
          'paymentMethod': paymentMethod,
          'totalPrice': totalPrice,
        }),
      );
      if (response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          // Backend đã trả về {success: true, data: ...} nên không cần wrap thêm
          return data;
        } catch (e) {
          return {'success': false, 'error': 'Invalid JSON response: $e'};
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'data': errorData};
        } catch (e) {
          return {
            'success': false,
            'error': 'HTTP ${response.statusCode}: ${response.body}',
          };
        }
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
