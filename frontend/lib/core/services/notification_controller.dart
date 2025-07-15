import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../shared/models/notification_model.dart';

class NotificationController extends GetxController {
  var notifications = <AppNotification>[].obs;
  var isLoading = false.obs;

  String baseUrl = 'https://burgerking-j92p.onrender.com'; // Thay bằng URL backend của bạn
  String token = '';

  void setToken(String newToken) {
    token = newToken;
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        notifications.value = data.map((json) => AppNotification.fromJson(json)).toList();
      } else {
        Get.snackbar('Lỗi', 'Không lấy được thông báo');
      }
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    }
    isLoading.value = false;
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/notifications/mark-all-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        await fetchNotifications();
      } else {
        Get.snackbar('Lỗi', 'Không thể đánh dấu đã đọc');
      }
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    }
  }
} 