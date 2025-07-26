import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../shared/models/notification_model.dart';

class NotificationController extends GetxController {
  var notifications = <AppNotification>[].obs;
  var isLoading = false.obs;

  /// Base URL tự động: Render (production) hoặc localhost (development)
  String baseUrl =
      const String.fromEnvironment(
        'API_URL',
        defaultValue: 'https://burgerking-j92p.onrender.com',
      ) +
      '/api';
  String token = '';

  void setToken(String newToken) {
    token = newToken;
  }

  /// Fetch danh sách thông báo
  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: _headers(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        notifications.value =
            data.map((json) => AppNotification.fromJson(json)).toList();
      } else {
        print('Fetch error: ${response.statusCode} - ${response.body}');
        Get.snackbar('Lỗi', 'Không lấy được thông báo');
      }
    } catch (e) {
      print('Fetch Exception: $e');
      Get.snackbar('Lỗi', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Đánh dấu tất cả thông báo đã đọc
  Future<void> markAllAsRead() async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/mark-read'),
        headers: _headers(),
      );
      if (response.statusCode == 200) {
        await fetchNotifications();
      } else {
        print('MarkAllAsRead error: ${response.statusCode} - ${response.body}');
        Get.snackbar('Lỗi', 'Không thể đánh dấu đã đọc');
      }
    } catch (e) {
      print('MarkAllAsRead Exception: $e');
      Get.snackbar('Lỗi', e.toString());
    }
  }

  /// Xóa tất cả thông báo
  Future<void> deleteAllNotifications() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications'),
        headers: _headers(),
      );
      if (response.statusCode == 200) {
        notifications.clear();
        Get.snackbar('Thành công', 'Đã xóa tất cả thông báo');
      } else {
        print('DeleteAll error: ${response.statusCode} - ${response.body}');
        Get.snackbar('Lỗi', 'Không thể xóa tất cả thông báo');
      }
    } catch (e) {
      print('DeleteAll Exception: $e');
      Get.snackbar('Lỗi', e.toString());
    }
  }

  /// Header với token
  Map<String, String> _headers() {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
}
