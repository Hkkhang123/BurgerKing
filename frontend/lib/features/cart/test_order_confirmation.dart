import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'order_confirmation_screen.dart';

class TestOrderConfirmation extends StatelessWidget {
  const TestOrderConfirmation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Order Confirmation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.to(() => OrderConfirmationScreen(
                  orderId: 'test_order_123',
                  orderCode: 'ORD123456',
                  totalAmount: 150000,
                  paymentMethod: 'Thanh toán MoMo',
                  shippingAddress: {
                    'receiver': 'Nguyễn Văn A',
                    'phone': '0123456789',
                    'address': '123 Đường ABC, Quận 1',
                    'district': 'Quận 1',
                    'city': 'TP.HCM',
                  },
                  orderItems: [
                    {
                      'name': 'Burger King Whopper',
                      'quantity': 2,
                      'price': 75000,
                      'image': 'https://via.placeholder.com/100x100',
                    },
                    {
                      'name': 'Coca Cola',
                      'quantity': 1,
                      'price': 25000,
                      'image': 'https://via.placeholder.com/100x100',
                    },
                  ],
                  isPaymentSuccess: true,
                ));
              },
              child: const Text('Test Thanh toán thành công'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.to(() => OrderConfirmationScreen(
                  orderId: 'test_order_456',
                  orderCode: 'ORD789012',
                  totalAmount: 200000,
                  paymentMethod: 'Thanh toán khi nhận hàng',
                  shippingAddress: {
                    'receiver': 'Trần Thị B',
                    'phone': '0987654321',
                    'address': '456 Đường XYZ, Quận 2',
                    'district': 'Quận 2',
                    'city': 'TP.HCM',
                    'postalCode': '700000',
                  },
                  orderItems: [
                    {
                      'name': 'Chicken Burger',
                      'quantity': 1,
                      'price': 120000,
                      'image': 'https://via.placeholder.com/100x100',
                    },
                    {
                      'name': 'French Fries',
                      'quantity': 1,
                      'price': 45000,
                      'image': 'https://via.placeholder.com/100x100',
                    },
                    {
                      'name': 'Pepsi',
                      'quantity': 1,
                      'price': 35000,
                      'image': 'https://via.placeholder.com/100x100',
                    },
                  ],
                  isPaymentSuccess: false,
                ));
              },
              child: const Text('Test Thanh toán khi nhận hàng'),
            ),
          ],
        ),
      ),
    );
  }
} 