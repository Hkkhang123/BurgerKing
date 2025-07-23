import 'dart:convert';
import 'package:http/http.dart' as http;

class ShippingService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/shipping';

  /// Lấy danh sách Tỉnh/TP
  static Future<List<dynamic>> getProvinces() async {
    final res = await http.get(Uri.parse('$baseUrl/provinces'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'];
    }
    throw Exception('Failed to load provinces');
  }

  /// Lấy danh sách Quận/Huyện theo ProvinceId
  static Future<List<dynamic>> getDistricts(int provinceId) async {
    final res = await http.get(Uri.parse('$baseUrl/districts/$provinceId'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'];
    }
    throw Exception('Failed to load districts');
  }

  /// Lấy danh sách Phường/Xã theo DistrictId
  static Future<List<dynamic>> getWards(int districtId) async {
    final res = await http.get(Uri.parse('$baseUrl/wards/$districtId'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'];
    }
    throw Exception('Failed to load wards');
  }

  /// Lấy Service ID hợp lệ từ GHN (trả về null nếu không có)
  static Future<int?> getAvailableServiceId({
    required int fromDistrict,
    required int toDistrict,
  }) async {
    print("=== Gọi getAvailableServiceId ===");
    print("fromDistrict: $fromDistrict");
    print("toDistrict: $toDistrict");

    final res = await http.post(
      Uri.parse('$baseUrl/available-services'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "shop_id": 197142,
        "from_district": fromDistrict,
        "to_district": toDistrict,
      }),
    );

    print("Response: ${res.body}");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)['data'];
      if (data != null && data.isNotEmpty) {
        return data[0]['service_id'];
      }
    }
    return null; // Không có dịch vụ
  }

  /// Tính phí vận chuyển
  static Future<int> calculateShippingFee({
    required int fromDistrict,
    required int toDistrict,
    required String toWard,
    required int weight,
    required int serviceId,
  }) async {
    final body = {
      "service_id": serviceId,
      "insurance_value": 500000,
      "coupon": null,
      "from_district_id": fromDistrict,
      "to_district_id": toDistrict,
      "to_ward_code": toWard,
      "height": 15,
      "length": 15,
      "weight": weight,
      "width": 15,
    };

    print("=== Gọi calculateShippingFee ===");
    print("Body: $body");

    final res = await http.post(
      Uri.parse('$baseUrl/calculate-fee'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print("Response: ${res.body}");

    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data']['total'];
    } else {
      throw Exception('Không tính được phí vận chuyển');
    }
  }
}
