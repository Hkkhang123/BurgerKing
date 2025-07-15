import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  final NotificationController notificationController = Get.find();

  IconData getIcon(String title) {
    if (title.toLowerCase().contains('order')) return Icons.event_note;
    if (title.toLowerCase().contains('special')) return Icons.local_offer;
    if (title.toLowerCase().contains('delivery')) return Icons.local_shipping;
    if (title.toLowerCase().contains('payment')) return Icons.payment;
    return Icons.notifications;
  }

  Color getColor(String title) {
    if (title.toLowerCase().contains('order')) return Colors.orange.shade100;
    if (title.toLowerCase().contains('special')) return Colors.amber.shade100;
    if (title.toLowerCase().contains('delivery')) return Colors.green.shade100;
    if (title.toLowerCase().contains('payment')) return Colors.pink.shade100;
    return Colors.grey.shade200;
  }

  Color getIconColor(String title) {
    if (title.toLowerCase().contains('order')) return Colors.orange;
    if (title.toLowerCase().contains('special')) return Colors.amber;
    if (title.toLowerCase().contains('delivery')) return Colors.green;
    if (title.toLowerCase().contains('payment')) return Colors.pink;
    return Colors.grey;
  }

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
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notificationController.notifications.length,
          separatorBuilder: (_, __) => SizedBox(height: 16),
          itemBuilder: (context, index) {
            final n = notificationController.notifications[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: getColor(n.title),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: getIconColor(n.title).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      getIcon(n.title),
                      color: getIconColor(n.title),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          n.message,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
} 