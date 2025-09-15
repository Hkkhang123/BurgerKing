import 'package:flutter/material.dart';
import 'package:client/core/utils/api_service.dart';
import 'package:get/get.dart';
import 'package:client/core/services/auth_controller.dart';
import 'address_selector.dart';

class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({Key? key}) : super(key: key);

  @override
  State<AddressManagementScreen> createState() =>
      _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  List<dynamic> addresses = [];
  bool isLoading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    // Lấy token từ AuthController qua GetX
    token = Get.find<AuthController>().getToken();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() => isLoading = true);
    try {
      final res = await ApiService.getAddresses(token!);
      setState(() {
        addresses = res;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _deleteAddress(String id) async {
    try {
      await ApiService.deleteAddress(id, token!);
      _fetchAddresses();
    } catch (e) {
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showAddAddressDialog() {
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController =
        TextEditingController(); // hiển thị địa chỉ đầy đủ
    String street = '', ward = '', district = '', city = '';
    bool isDefault = false;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Thêm địa chỉ mới'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên người nhận',
                      ),
                      validator:
                          (v) => v == null || v.isEmpty ? 'Nhập tên' : null,
                    ),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                      ),
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Nhập số điện thoại'
                                  : null,
                    ),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ đầy đủ',
                      ),
                      readOnly: true,
                      onTap: () async {
                        final result = await showDialog<Map<String, String>>(
                          context: context,
                          builder:
                              (_) => AddressSelector(
                                addressController: addressController,
                              ),
                        );

                        if (result != null) {
                          street = result['street'] ?? '';
                          ward = result['ward'] ?? '';
                          district = result['district'] ?? '';
                          city = result['city'] ?? '';
                        }
                      },
                      validator:
                          (v) => v == null || v.isEmpty ? 'Chọn địa chỉ' : null,
                    ),
                    CheckboxListTile(
                      value: isDefault,
                      onChanged: (v) => setState(() => isDefault = v ?? false),
                      title: const Text('Đặt làm mặc định'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await ApiService.addAddress({
                        'name': nameController.text,
                        'phone': phoneController.text,
                        'street': street,
                        'ward': ward,
                        'district': district,
                        'city': city,
                        'isDefault': isDefault,
                      }, token!);
                      Navigator.pop(context);
                      _fetchAddresses();
                    } catch (e) {
                      Get.snackbar(
                        'Lỗi',
                        e.toString(),
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Địa chỉ giao hàng')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : addresses.isEmpty
              ? const Center(child: Text('Chưa có địa chỉ nào'))
              : ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, i) {
                  final addr = addresses[i];
                  final fullAddress =
                      addr['fullAddress'] ??
                      '${addr['street'] ?? ''}, '
                          '${addr['ward'] ?? ''}, '
                          '${addr['district'] ?? ''}, '
                          '${addr['city'] ?? ''}';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        '${addr['name'] ?? ''} - ${addr['phone'] ?? ''}',
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fullAddress),
                          if (addr['isDefault'] == true)
                            const Text(
                              '(Mặc định)',
                              style: TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (addr['isDefault'] != true)
                            IconButton(
                              icon: const Icon(Icons.star_border),
                              tooltip: 'Đặt làm mặc định',
                              onPressed: () async {
                                try {
                                  await ApiService.updateAddress(addr['_id'], {
                                    'isDefault': true,
                                  }, token!);
                                  _fetchAddresses();
                                } catch (e) {
                                  Get.snackbar(
                                    'Lỗi',
                                    e.toString(),
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteAddress(addr['_id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAddressDialog,
        child: const Icon(Icons.add),
        tooltip: 'Thêm địa chỉ',
      ),
    );
  }
}
