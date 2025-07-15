import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  final NotificationController notificationController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => notificationController.markAllAsRead(),
            child: Text('Mark all as read', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
      body: Obx(() {
        if (notificationController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (notificationController.notifications.isEmpty) {
          return Center(child: Text('Không có thông báo nào.'));
        }
        return ListView.builder(
          itemCount: notificationController.notifications.length,
          itemBuilder: (context, index) {
            final n = notificationController.notifications[index];
            return ListTile(
              title: Text(n.title),
              subtitle: Text(n.message),
              trailing: n.isRead ? null : Icon(Icons.fiber_new, color: Colors.red),
              dense: true,
            );
          },
        );
      }),
    );
  }
} 