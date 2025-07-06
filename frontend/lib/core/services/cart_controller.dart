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
        headers: token != null
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
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'data': jsonDecode(response.body)};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Thêm vào giỏ hàng
  Future<Map<String, dynamic>> addToCart(String? token, String productId, {int quantity = 1, String? guestId}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/cart/add'),
        headers: token != null
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
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'data': jsonDecode(response.body)};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Cập nhật giỏ hàng
  Future<Map<String, dynamic>> updateCart(String? token, String productId, int quantity, {String? guestId}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/cart/update'),
        headers: token != null
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
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'data': jsonDecode(response.body)};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Xóa khỏi giỏ hàng
  Future<Map<String, dynamic>> deleteFromCart(String? token, String productId, {String? guestId}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/cart/delete/$productId'),
        headers: token != null
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
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'data': jsonDecode(response.body)};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
} 