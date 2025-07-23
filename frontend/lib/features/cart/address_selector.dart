import 'package:flutter/material.dart';
import 'package:client/core/services/shipping_service.dart';

class AddressSelector extends StatefulWidget {
  final TextEditingController addressController;

  const AddressSelector({Key? key, required this.addressController})
    : super(key: key);

  @override
  AddressSelectorState createState() => AddressSelectorState();
}

class AddressSelectorState extends State<AddressSelector> {
  List<dynamic> provinces = [];
  List<dynamic> districts = [];
  List<dynamic> wards = [];

  String? selectedProvince;
  String? selectedDistrict;
  String? selectedWard;

  final TextEditingController _detailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
  }

  Future<void> _fetchProvinces() async {
    try {
      final res = await ShippingService.getProvinces();
      setState(() => provinces = res);
      print("Danh sách provinces: $provinces");
    } catch (e) {
      print('Lỗi lấy provinces: $e');
    }
  }

  Future<void> _fetchDistricts(String provinceId) async {
    try {
      final res = await ShippingService.getDistricts(int.parse(provinceId));
      setState(() {
        districts = res;
        wards = [];
        selectedDistrict = null;
        selectedWard = null;
      });
      print("ProvinceId $provinceId -> districts: $districts");
    } catch (e) {
      print('Lỗi lấy districts: $e');
    }
  }

  Future<void> _fetchWards(String districtId) async {
    try {
      final res = await ShippingService.getWards(int.parse(districtId));
      setState(() {
        wards = res;
        selectedWard = null;
      });
      print("DistrictId $districtId -> wards: $wards");
    } catch (e) {
      print('Lỗi lấy wards: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chọn địa chỉ giao hàng'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TextField nhập số nhà / tên đường
            TextField(
              controller: _detailController,
              decoration: const InputDecoration(
                labelText: 'Số nhà / Tòa nhà , Tên đường',
                hintText: 'Ví dụ: 818 Sư Vạn Hạnh',
              ),
            ),
            const SizedBox(height: 10),

            // Dropdown chọn tỉnh/thành
            DropdownButtonFormField<String>(
              value: selectedProvince,
              hint: const Text('Chọn Tỉnh/TP'),
              isExpanded: true,
              items:
                  provinces.map<DropdownMenuItem<String>>((p) {
                    return DropdownMenuItem(
                      value: p['ProvinceID'].toString(),
                      child: Text(p['ProvinceName']),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() => selectedProvince = value);
                print("Selected Province: $selectedProvince");
                if (value != null) _fetchDistricts(value);
              },
            ),
            const SizedBox(height: 10),

            // Dropdown chọn quận/huyện
            if (districts.isNotEmpty)
              DropdownButtonFormField<String>(
                value: selectedDistrict,
                hint: const Text('Chọn Quận/Huyện'),
                isExpanded: true,
                items:
                    districts.map<DropdownMenuItem<String>>((d) {
                      return DropdownMenuItem(
                        value: d['DistrictID'].toString(),
                        child: Text(d['DistrictName']),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() => selectedDistrict = value);
                  print("Selected District: $selectedDistrict");
                  if (value != null) _fetchWards(value);
                },
              ),
            const SizedBox(height: 10),

            // Dropdown chọn phường/xã
            if (wards.isNotEmpty)
              DropdownButtonFormField<String>(
                value: selectedWard,
                hint: const Text('Chọn Phường/Xã'),
                isExpanded: true,
                items:
                    wards.map<DropdownMenuItem<String>>((w) {
                      return DropdownMenuItem(
                        value: w['WardCode'].toString(),
                        child: Text(w['WardName']),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() => selectedWard = value);
                  print("Selected Ward: $selectedWard");
                },
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (selectedDistrict != null && selectedWard != null) {
              widget.addressController.text =
                  '${_detailController.text}, '
                  '${_getName(wards, selectedWard, "WardCode", "WardName")}, '
                  '${_getName(districts, selectedDistrict, "DistrictID", "DistrictName")}, '
                  '${_getName(provinces, selectedProvince, "ProvinceID", "ProvinceName")}';

              print("Địa chỉ đã chọn: ${widget.addressController.text}");

              Navigator.of(
                context,
              ).pop({"districtId": selectedDistrict, "wardCode": selectedWard});
            } else {
              print("Vui lòng chọn đầy đủ địa chỉ!");
            }
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }

  /// Helper để lấy tên từ ID
  String _getName(List data, String? id, String keyId, String keyName) {
    if (id == null) return '';
    final match = data.firstWhere(
      (e) => e[keyId].toString() == id,
      orElse: () => {},
    );
    return match.isNotEmpty ? match[keyName] : '';
  }
}
